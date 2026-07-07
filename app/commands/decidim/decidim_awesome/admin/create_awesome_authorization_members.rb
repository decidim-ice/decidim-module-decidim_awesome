# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class CreateAwesomeAuthorizationMembers < Command
        # Public: Initializes the command.
        #
        # form - The form object containing the authorization group and emails.
        def initialize(form)
          @form = form
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when all members were added or already existed.
        # - :invalid if some members could not be created.
        #
        # Returns nothing.
        def call
          authorization_group.members.destroy_all if form.remove_previous_members

          previous_members_count = authorization_group.members.count
          authorization_group.members.insert_all( # rubocop:disable Rails/SkipsModelValidations
            form.data.map { |email| { email: email.strip.downcase } },
            unique_by: :index_auth_members_group_email
          )
          created_count = authorization_group.members.count - previous_members_count

          if created_count.zero? && form.remove_previous_members.blank?
            return broadcast(:invalid,
                             I18n.t("decidim.decidim_awesome.admin.awesome_authorization_users.update.empty"))
          end

          broadcast(:ok, created_count)
        rescue StandardError => e
          broadcast(:invalid, e.message)
        end

        private

        attr_reader :form

        def authorization_group
          form.authorization_group
        end
      end
    end
  end
end
