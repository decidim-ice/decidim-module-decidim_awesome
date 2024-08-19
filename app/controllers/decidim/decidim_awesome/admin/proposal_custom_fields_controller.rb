# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      # Global configuration controller
      class ProposalCustomFieldsController < DecidimAwesome::Admin::ConfigController
        def create
          CreateProposalCustomField.call(current_organization, config_var) do
            on(:ok) do |key|
              flash[:notice] = I18n.t("config.create_proposal_custom_field.success", key: key, scope: "decidim.decidim_awesome.admin")
            end

            on(:invalid) do |message|
              flash[:alert] = I18n.t("config.create_proposal_custom_field.error", error: message, scope: "decidim.decidim_awesome.admin")
            end
          end

          redirect_to decidim_admin_decidim_awesome.config_path(config_var)
        end

        def destroy
          DestroyProposalCustomField.call(params[:key], current_organization, config_var) do
            on(:ok) do |key|
              flash[:notice] = I18n.t("config.destroy_proposal_custom_field.success", key: key, scope: "decidim.decidim_awesome.admin")
            end

            on(:invalid) do |message|
              flash[:alert] = I18n.t("config.destroy_proposal_custom_field.error", error: message, scope: "decidim.decidim_awesome.admin")
            end
          end

          redirect_to decidim_admin_decidim_awesome.config_path(config_var)
        end

        private

        def config_var
          return :proposal_private_custom_fields if params[:private] == "true"

          :proposal_custom_fields
        end
      end
    end
  end
end
