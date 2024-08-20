# frozen_string_literal: true

require "decidim/decidim_awesome/version"

module Decidim
  module DecidimAwesome
    module Admin
      # System compatibility analyzer
      class MaintenanceController < DecidimAwesome::Admin::ApplicationController
        include NeedsAwesomeConfig
        include MaintenanceContext
        include Decidim::Admin::Filterable
        include ActionView::Helpers::DateHelper

        helper ConfigConstraintsHelpers
        helper_method :collection, :resource, :present, :time_ago

        before_action do
          enforce_permission_to :edit_config, :private_data, private_data:
        end

        def show
          respond_to do |format|
            format.json do
              render json: private_data_finder.for(params[:resources].to_s.split(",")).map { |resource| present(resource) }
            end
            format.all do
              render :show
            end
          end
        end

        def destroy_private_data
          if private_data && private_data.total.to_i.positive?
            Decidim::ActionLogger.log("destroy_private_data", current_user, resource, nil, count: private_data.total)

            Lock.new(current_organization).get!(resource)
            DestroyPrivateDataJob.set(wait: 1.second).perform_later(resource)
          end
          redirect_to decidim_admin_decidim_awesome.maintenance_path("private_data"),
                      notice: I18n.t("destroying_private_data", scope: "decidim.decidim_awesome.admin.maintenance.private_data", title: present_private_data(resource).name)
        end

        private

        def resource
          @resource ||= Component.find_by(id: params[:resource_id])
        end

        def private_data
          @private_data ||= present_private_data(resource) if resource
        end

        def collection
          filtered_collection
        end

        def base_query
          private_data_finder.query
        end

        def present(resource)
          present_private_data(resource)
        end

        def private_data_finder
          @private_data_finder ||= PrivateDataFinder.new
        end

        def time_ago
          @time_ago ||= time_ago_in_words(Time.current - Decidim::DecidimAwesome.private_data_expiration_time)
        end
      end
    end
  end
end
