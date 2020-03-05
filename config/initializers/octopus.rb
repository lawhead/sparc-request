# Copyright © 2011-2019 MUSC Foundation for Research Development
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

# See https://github.com/thiagopradi/octopus/issues/426

module Octopus
  class << self
    def disable!
      @@enabled = false
    end

    def enable!
      @@enabled = true
    end

    def enabled_with_additional_check?
      enabled_without_additional_check? && @@enabled
    end
    alias_method :enabled_without_additional_check?, :enabled?
    alias_method :enabled?, :enabled_with_additional_check?

    def shards
      config[Rails.env]['shards']
    end

    def load_shards!
      University.eager_load(:database).all.each{ |u| Databases::ConnectionService.new(u).call if u.database }
    end
  end

  module Model
    module InstanceMethods
      alias_method :init_with_base, :init_with

      # This method has to be patched in order to load sharded objects during
      # delayed jobs
      def init_with(coder)
        obj = super

        if obj.current_shard
          return obj
        else
          return init_with_base
        end
      end
    end
  end
end

Octopus.enable!

if ActiveRecord::Base.connection.table_exists?('universities')
  Octopus.load_shards!
end
