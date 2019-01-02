# Copyright © 2011-2018 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

class PermissibleValue < ApplicationRecord
  belongs_to :parent, :class_name => 'PermissibleValue'

  scope :available, -> {
    where(is_available: true)
  }

  scope :unavailable, -> {
    where(is_available: false)
  }

  # Get the first PermissibleValue value using a category and key
  def self.get_value(category, key)
    PermissibleValue.where(category: category, key: key).first.try(:value)
  end

  # Get an array of PermissibleValue keys with the given category
  def self.get_key_list(category, default=nil)
    unless default.nil?
      PermissibleValue.available.where(category: category, default: default).order(:sort_order).pluck(:key)
    else
      PermissibleValue.available.where(category: category).order(:sort_order).pluck(:key)
    end
  end

  # Get a hash of PermissibleValue keys as the keys and values as the values
  def self.get_hash(category, default=nil)
    unless default.nil?
      Hash[PermissibleValue.available.where(category: category, default: default).order(:sort_order).pluck(:key, :value)]
    else
      Hash[PermissibleValue.available.where(category: category).order(:sort_order).pluck(:key, :value)]
    end
  end

  # Get a hash of PermissibleValue values as the keys and keys as the values
  def self.get_inverted_hash(category, default=nil)
    unless default.nil?
      Hash[PermissibleValue.available.where(category: category, default: default).order(:sort_order).pluck(:value, :key)]
    else
      Hash[PermissibleValue.available.where(category: category).order(:sort_order).pluck(:value, :key)]
    end
  end
end
