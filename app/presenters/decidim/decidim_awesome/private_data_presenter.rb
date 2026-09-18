# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class PrivateDataPresenter < SimpleDelegator
      include Decidim::TranslatableAttributes
      include ActionView::Helpers::DateHelper
      include ActionView::Helpers::TagHelper

      def name
        @name ||= "#{translated_attribute(participatory_space.title)} / #{translated_attribute(super)}"
      end

      def path
        @path ||= Decidim::EngineRouter.main_proxy(self).root_path
      end

      def total
        @total ||= private_bodies.count.to_s
      end

      def last_date
        @last_date ||= private_bodies.maximum(:private_body_updated_at)
      end

      def time_ago
        I18n.t("decidim.decidim_awesome.admin.private_data.private_data.time_ago", time: time_ago_in_words(last_date)) if last_date
      end

      def destroyable?
        return false unless last_date

        last_date < DecidimAwesome.private_data_expiration_time.ago
      end

      def locked?
        Decidim::DecidimAwesome::Lock.new(organization).locked?(__getobj__)
      end

      def as_json(_options = nil)
        {
          id:,
          name:,
          path:,
          total:,
          last_date:,
          time_ago:,
          locked: locked?,
          done:
        }
      end

      def done
        return content_tag("span", "", class: "loading-spinner primary") if locked?

        return if destroyable?
        return if last_date

        I18n.t("decidim.decidim_awesome.admin.private_data.private_data.done")
      end

      private

      def private_bodies
        ProposalExtraField.with_deleted
                          .where(proposal: Decidim::Proposals::Proposal.with_deleted.where(component: __getobj__))
                          .where.not(private_body: nil)
      end
    end
  end
end
