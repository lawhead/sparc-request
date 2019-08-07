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

module DocumentsHelper
  def new_document_button(opts={})
    unless in_dashboard? && !opts[:permission]
      url = in_dashboard? ? new_dashboard_document_path(protocol_id: opts[:protocol_id]) : new_document_path(srid: opts[:srid])

      link_to url, remote: true, class: 'btn btn-success', title: t('documents.tooltips.new'), data: { toggle: 'tooltip' } do
        icon('fas', 'plus mr-2') + t('documents.new')
      end
    end
  end

  def display_document_title(document, opts)
    if in_dashboard? && !opts[:permission]
      document.file_name
    else
      link_to document.document_file_name, document.document.url, target: :blank
    end
  end

  def document_actions(document, opts={})
    [
      edit_document_button(document, opts),
      delete_document_button(document, opts)
    ].join('')
  end

  def edit_document_button(document, opts={})
    unless in_dashboard? && !opts[:permission]
      url = in_dashboard? ? edit_dashboard_document_path(document) : edit_document_path(srid: opts[:srid])

      link_to icon('far', 'edit'), url, remote: true, class: "btn btn-warning mr-1"
    end
  end

  def delete_document_button(document, opts={})
    unless in_dashboard? && !opts[:permission]
      url = in_dashboard? ? dashboard_document_path(document) : document_path(srid: opts[:srid])

      link_to icon('fas', 'trash-alt'), url, method: :delete,  remote: true, class: "btn btn-danger", data: { confirm_swal: 'true' }
    end
  end

  def document_file_types_as_string
    Document::SUPPORTED_FILE_TYPES.map(&:source).map{ |d| d.gsub('\\', '').gsub('$', '').gsub('?', '') }.join(' ')
  end

  def document_org_access_collection(document)
    default_select = action_name == 'new' ? document.protocol.organizations.ids : document.sub_service_requests.pluck(:organization_id)

    options_from_collection_for_select(document.protocol.organizations.distinct.order(:name), :id, :name, default_select)
  end
end
