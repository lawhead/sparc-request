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

# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$(document).ready ->
  Sparc.associated_users = {
    display_dependencies :
      '#project_role_role' :
        'primary-pi'              : ['.era_commons_name', '.subspecialty']
        pi                        : ['.era_commons_name', '.subspecialty']
        'co-investigator'         : ['.era_commons_name', '.subspecialty']
        'faculty-collaborator'    : ['.era_commons_name', '.subspecialty']
        consultant                : ['.era_commons_name', '.subspecialty']
        "staff-scientist"         : ['.era_commons_name', '.subspecialty']
        postdoc                   : ['.era_commons_name', '.subspecialty']
        mentor                    : ['.era_commons_name', '.subspecialty']
        other                     : ['.role_other']
      '#identity_credentials' :
        other          : ['.credentials_other']

    ready: ->
      $(document).on 'click', '.associated-user-button', ->
        if $(this).data('permission')
          $.ajax
            method: 'get'
            url: '/portal/associated_users/new.js'
            data:
              protocol_id: $(this).data('protocol-id')
          # $('.add-associated-user-dialog').dialog('open')
          # $('#add-user-form #protocol_id').val($(this).data('protocol_id'))
        else
          $('.permissions-dialog').dialog('open')
          $('.permissions-dialog .text').html('Edit.')

      $('.user_credentials').attr('name', 'user[credentials_other]') if $('.user_credentials').val() == 'other'
      $('.user_credentials').live 'change', ->
        Sparc.associated_users.redoCredentials()

      # Set the rights if the role is 'pi' or 'business-grants-manager'
      # and disable all other radio buttons if 'pi'
      $(document).on 'change', '#project_role_role', ->
        role = $(this).val()
        if role == 'pi' or role == 'primary-pi' or role == 'business-grants-manager'
          $('#project_role_project_rights_none').attr('disabled', true)
          $('#project_role_project_rights_view').attr('disabled', true)
          $('#project_role_project_rights_request').attr('disabled', true)
          $('#project_role_project_rights_approve').attr('checked', true)
        else
          $('.rights_radios input').attr('disabled', false)

      $(document).on 'click', '.edit-associated-user-button', (event) ->
        event.stopPropagation()
        if $(this).data('permission')
          console.log('hey')
          pr_id = $(this).data('pr-id')
          sub_service_request_id = $(this).data('sub-service-request-id')
          $.ajax
            method: 'get'
            url: "/portal/associated_users/#{pr_id}/edit.js"
            data:
              protocol_id: $(this).data('protocol-id')
              identity_id: $(this).data('user-id')
              sub_service_request_id: sub_service_request_id
            error: (request, status, error) ->
              console.log(request)
              console.log(status)
              console.log(error)
        else
          $('.permissions-dialog').dialog('open')
          $('.permissions-dialog .text').html('Edit.')

      $(document).on 'click', '.delete-associated-user-button', ->
        if $(this).data('permission')
          adminUsersList         = $(".admin#users")
          current_user_id        = parseInt($('#current_user_id').val(), 10)
          current_user_role      = $(this).data('current-user-role')
          protocol_id            = $(this).data('protocol-id')
          sub_service_request_id = $(this).data('sub-service-request-id')
          pr_id                  = $(this).data('pr-id')
          user_id                = $(this).data('user-id')
          user_role              = $(this).data('user-role')
          confirm_message        = if current_user_id == user_id then 'This action will remove you from the project. Are you sure?' else 'Are you sure?'
          alert_message1         = I18n["protocol_information"]["require_primary_pi_message"]
          cannot_remove_pi       = (current_user_role == 'primary-pi' or user_role == 'primary-pi')

          if cannot_remove_pi
            alert(alert_message1)
          else
            if confirm(confirm_message)
              # Seems like the only way to pass parameters when performing a DELETE ajax
              # request is through the URL.
              $.ajax
                dataType: 'script'
                type: 'delete'
                url: if sub_service_request_id then "/portal/associated_users/#{pr_id}?sub_service_request_id=#{sub_service_request_id}" else "/portal/associated_users/#{pr_id}"
                success: ->
                  if sub_service_request_id
                    # Nothing
                  else
                    # console.log(JSON.stringify(current_user_id))
                    # console.log(JSON.stringify(user_id))
                    if parseInt(current_user_id, 10) == parseInt(user_id, 10)
                      $(".protocol-information-panel-#{protocol_id}").fadeOut(1500)
                    else
                      Sparc.protocol.renderProtocolAccordionTab(protocol_id)

        else
          $('.permissions-dialog').dialog('open')
          $('.permissions-dialog .text').html('Edit.')

      $(document).on 'change', '#associated_user_role', ->
        roles_to_hide = ['', 'grad-research-assistant', 'undergrad-research-assistant', 'research-assistant-coordinator', 'technician', 'general-access-user', 'business-grants-manager', 'other']
        role = $(this).val()
        if role == 'other' then $('.role_other').show() else $('.role_other').hide()
        # if role == '' then Sparc.associated_users.validateRolePresence(role) else Sparc.associated_users.noProblems()
        if roles_to_hide.indexOf(role) >= 0
          $('.commons_name').hide()
          $('.subspecialty').hide()
        else
          $('.commons_name').show()
          $('.subspecialty').show()

      Sparc.associated_users.create_edit_associated_user_dialog()
      Sparc.associated_users.create_add_associated_user_dialog()

    create_add_associated_user_dialog: () ->
      $('.add-associated-user-dialog').dialog
        autoOpen: false
        dialogClass: "add_user_dialog_box"
        title: 'Add an Authorized User'
        width: 750
        modal: true
        resizable: false
        buttons:
          'Submit':
            id: 'add_authorized_user_submit_button'
            text: 'Submit'
            click: ->
              $("#new_project_role").submit()
          'Cancel':
            id: 'add_authorized_user_cancel_button'
            text: 'Cancel'
            click: ->
              $(this).dialog('close')
              $("#errorExplanation").remove()
        open: ->
          Sparc.associated_users.reset_fields()
          $('.dialog-form input,.dialog-form select').attr('disabled',true)
          # $('.ui-dialog .ui-dialog-buttonpane button:contains(Submit)').filter(":visible").attr('disabled',true).addClass('button-disabled')
        close: ->
          Sparc.associated_users.reset_fields()

    create_edit_associated_user_dialog: () ->
      $('.edit-associated-user-dialog').dialog
        autoOpen: false
        dialogClass: "edit_user_dialog_box"
        title: 'Edit an Authorized User'
        width: 750
        modal: true
        resizable: false
        buttons:
          'Submit':
            id: 'edit_authorized_user_submit_button'
            text: 'Submit'
            click: ->
              form = $(".edit-associated-user-dialog").children('form')
              $('#edit_authorized_user_submit_button').attr('disabled', true)
              form.submit()
          'Cancel':
            id: 'edit_authorized_user_cancel_button'
            text: 'Cancel'
            click: ->
              $(this).dialog("close")
              $("#errorExplanation").remove()
        open: ->
          $('#edit_authorized_user_submit_button').attr('disabled', false)
          $('#associated_user_role').change()
        close: ->
          Sparc.associated_users.reset_fields()

    reset_fields: () ->
      $('.errorExplanation').html('').hide()
      $('.hidden').hide()
      $('#epic_access').hide()
      $('.add-associated-user-dialog input').val('')
      $('.add-associated-user-dialog select').prop('selectedIndex', 0)
      $('.add-associated-user-dialog #epic_access input').prop('checked', false)
      $('.add-associated-user-dialog .rights_radios input').prop('checked', false)

    createTip: (element) ->
      if $('#tip').length == 0
        $('<div>').
          html('<span>Drag and drop this item within a project to add.</span><span class="arrow"></span>').
          attr('id', 'tip').
          css({ left: element.pageX + 30, top: element.pageY - 16 }).
          appendTo('body').fadeIn(2000)
      else null

    disableSubmitButton: (containing_text, change_to) ->
      button = $(".ui-dialog .ui-dialog-buttonpane button:contains(#{containing_text})")
      button.html("<span class='ui-button-text'>#{change_to}</span>")
        .attr('disabled',true)
        .addClass('button-disabled')

    enableSubmitButton: (containing_text, change_to) ->
      button = $(".ui-dialog .ui-dialog-buttonpane button:contains(#{containing_text})")
      button.html("<span class='ui-button-text'>#{change_to}</span>")
        .attr('disabled',false)
        .removeClass('button-disabled')
      button.attr('disabled',false)

    validateRolePresence: (role) ->
      role_validation = $('#user-role-validation-message')
      role_validation.show()
      Sparc.associated_users.disableSubmitButton("Submit", "Submit")
  }
