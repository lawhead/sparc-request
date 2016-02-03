require 'rails_helper'
module Dashboard
  module Protocols
    class IndexPage < SitePrism::Page
      set_url '/dashboard/protocols'

      section :filters, '#filterrific_form' do
        element :search_field, '#filterrific_search_query'
        element :archived_checkbox, '#filterrific_show_archived'
        element :apply_filter_button, '#apply-filter-button'
        element :status_select, 'div.status-select button'
        elements :status_options, 'div.status-select li'
        element :my_protocols_checkbox, '#filterrific_for_identity_id'
        element :my_admin_organizations_checkbox, '#filterrific_for_admin'
        element :core_select, 'div.core-select button'
        elements :core_options, 'div.core-select li'
        element :reset_link, '#reset_filters_link'

        def select_status(status)
          status_select.click
          status_options.select { |so| so.text == status.capitalize }.first.click
        end

        def select_core(core)
          core_select.click
          core_options.select { |so| so.text == core.capitalize }.first.click
        end

        def selected_core
          core_select['title']
        end
      end

      sections :protocols, '#filterrific_results tr.protocols_index_row' do
        element :id_field, 'td.id'
        element :short_title_field, 'td.title'
        element :primary_pi_field, 'td.pis'
        element :requests_button, 'td.requests button'
        element :archive_button, 'td.archive button'

        def id
          id_field.text
        end

        def short_title
          short_title_field.text
        end

        def primary_pis
          primary_pi_field.text
        end
      end

      def displayed_protocol_ids
        protocols.map { |p| p.root_element['data-protocol-id'].to_i }
      end

      section :requests_modal, '#requests-modal' do
        element :title, '.modal-header h4'
        sections :service_requests, '.panel.service-request-info' do
          element :pretty_ssr_id, 'td.pretty-ssr-id'
        end
      end
    end
  end
end
