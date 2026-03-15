# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module BlockUserMailerOverride
      extend ActiveSupport::Concern

      def notify(user, justification)
        return if user.extended_data["autoblock"] && !user.extended_data["notify_autoblock"]

        with_user(user) do
          @user = user
          @organization = user.organization
          @justification = translated_attribute(justification)
          subject = I18n.t(
            "decidim.block_user_mailer.notify.subject",
            organization_name: translated_attribute(@organization.name),
            justification: @justification
          )

          mail(to: user.email, subject:)
        end
      end
    end
  end
end
