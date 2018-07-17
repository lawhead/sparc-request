# Copyright © 2011-2018 MUSC Foundation for Research Development
# All rights reserved.

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
# disclaimer in the documentation and/or other materials provided with the distribution.

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

class VisitGroup < ApplicationRecord
  self.per_page = Visit.per_page

  include RemotelyNotifiable
  include Comparable

  audited
  belongs_to :arm
  
  has_many :visits, :dependent => :destroy
  has_many :line_items_visits, through: :visits
  
  acts_as_list scope: :arm

  after_create :build_visits, if: Proc.new { |vg| vg.arm.present? }
  after_create :increment_visit_count, if: Proc.new { |vg| vg.arm.present? && vg.arm.visit_count < vg.arm.visit_groups.count }
  before_destroy :decrement_visit_count, if: Proc.new { |vg| vg.arm.present? && vg.arm.visit_count >= vg.arm.visit_groups.count  }

  validates :name, presence: true
  validates :position, presence: true
  validates :window_before,
            :window_after,
            presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :day, presence: true, numericality: { only_integer: true }

  validate :day_must_be_in_order

  default_scope { order(:position) }

  def <=> (other_vg)
    return unless other_vg.respond_to?(:day)
    self.day <=> other_vg.day
  end

  def self.admin_day_multiplier
    5
  end

  def insertion_name
    "Before #{name}" + (day.present? ? " (Day #{day})" : "")
  end

  ### audit reporting methods ###

  def audit_label audit
    "#{arm.name} #{name}"
  end

  def audit_field_value_mapping
    {"arm_id" => "Arm.find(ORIGINAL_VALUE).name"}
  end

  ### end audit reporting methods ###

  def any_visit_quantities_customized?(service_request)
    visits.any? { |visit| ((visit.quantities_customized?) && (visit.line_items_visit.line_item.service_request_id == service_request.id)) }
  end

  def per_patient_subtotals
    self.visits.sum{ |v| v.cost || 0.00 }
  end

  def in_order?
    day_must_be_in_order
  end
    
  private

  def build_visits
    self.arm.line_items_visits.each do |liv|
      self.visits.create(line_items_visit: liv)
    end
  end

  def increment_visit_count
    self.arm.increment!(:visit_count)
  end

  def decrement_visit_count
    self.arm.decrement!(:visit_count)
  end

  def day_must_be_in_order
    unless day.blank?
      already_there = arm.visit_groups.find_by(position: position) || arm.visit_groups.find_by(id: id)
      last_persisted_pos = arm.visit_groups.last.try(:position) || 0

      # determine neighbors that will be after save
      left_neighbor, right_neighbor =
        if id.nil? # inserting new record
          if position.nil? # insert as last
            [arm.visit_groups.last, nil]
          elsif position <= last_persisted_pos # inserting before
            [already_there.try(:higher_item), already_there]
          end
        else # moving present record
          if already_there.try(:id) == id # not changing position, get our neighbors
            [higher_item, lower_item]
          else # position must be changing
            if already_there.position < changed_attributes[:position]
              [already_there.try(:higher_item), already_there]
            else
              [already_there, already_there.try(:lower_item)]
            end
          end
        end

      if left_neighbor.try(:id) == id
        left_neighbor = nil
      end

      unless day > (left_neighbor.try(:day) || day - 1) && day < (right_neighbor.try(:day) || day + 1)
        errors.add(:day, 'must be in order')
      end
    end
  end
end
