# Copyright © 2011 MUSC Foundation for Research Development
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

module AssociatedUsersHelper
  # Returns div.form-group for Authorized User forms.
  # name - Sets label text from t(:authorized_users)[:form_fields][name.to_sym]
  #        Also used in form helpers.
  # classes - HTML classes to add to form-group.
  # label - Override localized label text.
  def user_form_group(form: nil, name:, classes: [], label: nil)
    form_group_classes = %w(row form-group) + [classes]
    label_class = 'col-lg-3 control-label'
    label_text = label || t(:authorized_users)[:form_fields][name.to_sym]
    label = if form
              form.label(name, label_text, class: label_class)
            else
              content_tag(:label, label_text, class: label_class)
            end
    input_container = content_tag(:div, class: 'col-lg-9') { yield }
    content_tag(:div,
                label + input_container,
                class: form_group_classes)
  end

  # Generates state for portion of Authorized User form concerned with their
  # professional organizations.
  # professional_organization - Last professional organization selected in form.
  #   Pass a falsy value for initial state.
  def professional_organization_state(professional_organization)
    if professional_organization
      {
        dont_submit_selected: professional_organization.parents,
        submit_selected: professional_organization,
        dont_submit_unselected: professional_organization.children
      }
    else
      {
        dont_submit_selected: [],
        submit_selected: nil,
        dont_submit_unselected: ProfessionalOrganization.where(parent_id: nil)
      }
    end
  end

  # Generate a dropdown for choosing a professional organization.
  # choices_from - If a ProfessionalOrganization, returns a select populated
  #   with it (as selected option) and its siblings. Otherwise, choices_from
  #   should be a collection of ProfessionalOrganizations to be presented as
  #   options.
  def professional_organization_dropdown(form: nil, choices_from:)
    select_class = 'form-control selectpicker'
    prompt = t(:authorized_users)[:form_fields][:select_one]
    if choices_from.kind_of?(ProfessionalOrganization)
      options = options_from_collection_for_select(choices_from.self_and_siblings.order(:name), 'id', 'name', choices_from.id)
      select_id = "select-pro-org-#{choices_from.org_type}"
    else
      options = options_from_collection_for_select(choices_from.order(:name), 'id', 'name')
      select_id = "select-pro-org-#{choices_from.first.org_type}"
    end

    if form
      form.select(:professional_organization_id,
                  options,
                  { include_blank: prompt },
                  class: select_class,
                  id: select_id)
    else
      select_tag(nil,
                 options,
                 include_blank: prompt,
                 class: select_class,
                 id: select_id)
    end
  end

  # Convert ProfessionalOrganization's org_type to a label for Authorized Users
  # form.
  def org_type_label(professional_organization)
    professional_organization.org_type.capitalize + ":"
  end

  def authorized_users_edit_button(project_role)
    content_tag(:button,
      raw(
        content_tag(:span, '', class: 'glyphicon glyphicon-edit', aria: { hidden: 'true' })
      ),
      type: 'button', data: { project_role_id: project_role.id },
      class: "btn btn-warning actions-button edit-associated-user-button"
    )
  end

  def authorized_users_delete_button(project_role, current_user)
    content_tag(:button,
      raw(
        content_tag(:span, '', class: 'glyphicon glyphicon-remove', aria: { hidden: 'true' })
      ),
      type: 'button', data: { project_role_id: project_role.id, identity_role: project_role.role, identity_id: project_role.identity_id },
      class: "btn btn-danger actions-button delete-associated-user-button",
      disabled: project_role.identity_id == current_user.id
    )
  end
end
