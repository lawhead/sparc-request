# Copyright © 2011-2022 MUSC Foundation for Research Development~
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

require 'rails_helper'

RSpec.describe 'SPARCCWF::APIv1', type: :request do
  describe 'GET /api/v1/sub_service_requests.json' do
    let!(:sub_service_requests) { create_list(:sub_service_request_without_validations, 5, :with_organization) }

    context 'request for :shallow records' do
      before { send_api_get_request(resource: 'sub_service_requests', depth: 'shallow') }

      it 'should respond with an array of shallow sub_service_requests' do
        expect(response.status).to eq(200)
        expect(JSON.parse(response.body)['sub_service_requests']).to eq(
          sub_service_requests.map{ |ssr| { 
            'sparc_id'      => ssr.id,
            'callback_url'  => ssr.remote_service_callback_url
          }}
        )
      end
    end

    context 'request for :full records' do
      before { send_api_get_request(resource: 'sub_service_requests', depth: 'full') }

      it 'should respond with an array of sub_service_requests and their attributes' do
        expect(response.status).to eq(200)
        expect(JSON.parse(response.body)['sub_service_requests']).to eq(
          sub_service_requests.map{ |ssr| 
            ssr.attributes.
            except('id', 'created_at', 'updated_at', 'deleted_at', 'submitted_at', 'protocol_id', 'current_user_id', 'synch_to_fulfillment').
            merge({ 
              'sparc_id'      => ssr.id,
              'callback_url'  => ssr.remote_service_callback_url,
              'grand_total'   => ssr.grand_total,
              'status'        => ssr.formatted_status
            })
          }
        )
      end
    end

    context 'request for :full_with_shallow_reflections records' do
      before { send_api_get_request(resource: 'sub_service_requests', depth: 'full_with_shallow_reflections') }

      it 'should respond with an array of sub_service_requests and their attributes and their shallow reflections' do
        expect(response.status).to eq(200)
        expect(JSON.parse(response.body)['sub_service_requests']).to eq(
          sub_service_requests.map{ |ssr| 
            ssr.attributes.
            except('id', 'created_at', 'updated_at', 'deleted_at', 'submitted_at', 'protocol_id', 'current_user_id', 'synch_to_fulfillment').
            merge({ 
              'sparc_id'          => ssr.id,
              'callback_url'      => ssr.remote_service_callback_url,
              'grand_total'       => ssr.grand_total,
              'status'            => ssr.formatted_status,
              'line_items'        => [],
              'service_request'   => nil
            })
          }
        )
      end
    end
  end
end
