# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module LimitPendingAmendments
      extend ActiveSupport::Concern

      included do
        # rubocop:disable Rails/LexicallyScopedActionFilter
        before_action :limit_pending_amendments, only: [:new, :create]
        # rubocop:enable Rails/LexicallyScopedActionFilter

        def limit_pending_amendments
          return unless amendable&.amendments && amendable&.component&.settings.try(:limit_pending_amendments)
          return unless amendable.component.settings.try(:amendments_enabled)
          return unless amendable.component.current_settings.try(:amendment_creation_enabled)

          existing = amendable.amendments.where(state: :evaluating)
          return unless existing.count.positive?

          emendation = existing.first.emendation

          flash[:alert] = t("pending_limit_reached", scope: "decidim.decidim_awesome.amendments", emendation: translated_attribute(emendation.title))
          redirect_back(fallback_location: Decidim::ResourceLocatorPresenter.new(amendable).path)
        end
      end
    end
  end
end
