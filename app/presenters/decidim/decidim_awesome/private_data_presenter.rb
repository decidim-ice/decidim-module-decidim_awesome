# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class PrivateDataPresenter < SimpleDelegator
      include Decidim::TranslatableAttributes

      def name
        @name ||= "#{translated_attribute(participatory_space.title)} / #{translated_attribute(super)}"
      end

      def path
        @path ||= Decidim::EngineRouter.main_proxy(self).root_path
      end

      def total
        @total ||= Decidim::Proposals::Proposal.joins(:extra_fields)
                                               .where(component: self, extra_fields: { private_body: nil })
                                               .count
      end

      def last_date
        @last_date ||= Decidim::Proposals::Proposal.joins(:extra_fields)
                                                   .where(component: self, extra_fields: { private_body: nil })
                                                   .order(private_body_updated_at: :desc)
                                                   .first
                                                   .created_at
      end
    end
  end
end
