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

require 'rails_helper'

RSpec.describe 'User edits a pending subsidy', js: true do
  let_there_be_lane

  fake_login_for_each_test

  before :each do
    institution = create(:institution, name: "Institution")
    provider    = create(:provider, name: "Provider", parent: institution)
    program     = create(:program, :with_subsidy_map, name: "Program", parent: provider, process_ssrs: true)
    service     = create(:service, name: "Service", abbreviation: "Service", organization: program)
    @protocol   = create(:protocol_federally_funded, type: 'Study', primary_pi: jug2)
    @sr         = create(:service_request_without_validations, status: 'first_draft', protocol: @protocol)
    ssr         = create(:sub_service_request_without_validations, service_request: @sr, organization: program, status: 'first_draft')
                  create(:line_item, service_request: @sr, sub_service_request: ssr, service: service)
                  create(:arm, protocol: @protocol, visit_count: 1)
    program.subsidy_map.update_attributes(max_dollar_cap: 100, max_percentage: 100)
    @subsidy    = create(:pending_subsidy, sub_service_request: ssr)
  end

  context 'and clicks the edit button' do
    scenario 'and sees the subsidy modal' do
      visit service_subsidy_service_request_path(srid: @sr.id)
      wait_for_javascript_to_finish

      find('.edit-subsidy-button').click
      wait_for_javascript_to_finish

      expect(page).to have_selector(".modal-dialog", text: "Edit Subsidy Pending Approval", visible: true)
    end

    context 'and fills out the form and submits' do
      scenario 'and sees the updated pending subsidy' do
        visit service_subsidy_service_request_path(srid: @sr.id)
        wait_for_javascript_to_finish

        find('.edit-subsidy-button').click
        wait_for_javascript_to_finish

        fill_in 'pending_subsidy_percent_subsidy', with: '3.14'

        click_button I18n.t(:actions)[:save]
        wait_for_javascript_to_finish

        expect(@subsidy.reload.percent_subsidy).to eq(0.0314)
      end
    end
  end
end
