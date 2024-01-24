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
          return unless amendable&.amendments && amendable&.component&.settings&.limit_pending_amendments

          existing = amendable.amendments.where(state: :evaluating)
          return unless existing.count.positive?

          existing_amendable = existing.first.amendable

          link = helpers.link_to(translated_attribute(existing_amendable.title), Decidim::ResourceLocatorPresenter.new(existing_amendable).path)
          flash[:alert] = t("pending_limit_reached_html", scope: "decidim.decidim_awesome.amendments", amendment: link).html_safe
          redirect_back(fallback_location: Decidim::ResourceLocatorPresenter.new(amendable).path)
        end
      end
    end
  end
end
