# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class AutoblockUsers < Command
        # Public: Initializes the command.
        #
        def initialize(form)
          @form = form
          @users_autoblocks = AwesomeConfig.find_or_initialize_by(var: :users_autoblocks, organization: current_organization)
          @current_config = AwesomeConfig.find_or_initialize_by(var: :users_autoblocks_config, organization: current_organization)
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          transaction do
            save_configuration!
            calculate_scores
            if detected_users.exists?
              block_users!
              send_notification_to_admins!
            end
          end

          broadcast(:ok, detected_users.count)
        rescue StandardError => e
          broadcast(:invalid, e.message)
        end

        private

        attr_reader :form, :users_autoblocks, :current_config

        delegate :current_organization, :current_user, to: :form

        def save_configuration!
          current_config.value = form.to_params
          current_config.save
        end

        def block_users!
          detected_users.each do |user|
            create_report!(user)

            block_form = Decidim::Admin::BlockUserForm.from_model(user).with_context(current_organization:, current_user:)
            I18n.with_locale(user.locale || current_organization.default_locale || "en") do
              block_form.justification = translated_attribute(current_config.value["block_justification_message"])
            end
            block_form.hide = true

            Decidim::Admin::BlockUser.call(block_form) do
              on(:invalid) do
                raise "User could not be blocked"
              end
            end
          end
        end

        def create_report!(user)
          moderation = UserModeration.find_or_create_by!(user:)

          UserReport.create!(
            moderation:,
            user:,
            reason: "does_not_belong",
            details: "Autoblock"
          )

          moderation.update!(report_count: moderation.report_count + 1)
        end

        def send_notification_to_admins!
          current_organization.admins.each do |admin|
            next unless admin.email_on_moderations

            Decidim::DecidimAwesome::UsersAutoblocksReportJob.perform_later(admin, detected_users.map { |user| user.id.to_s })
          end
        end

        def detected_users
          @detected_users ||= begin
            threshold = current_config.value&.dig("threshold")
            if threshold.present?
              user_ids = @block_data.select { |item| item[:total] >= threshold }.map { |item| item[:id] }
              Decidim::User.where(organization: current_organization, id: user_ids)
            else
              Decidim::User.none
            end
          end
        end

        def calculate_scores
          exporter = Decidim::DecidimAwesome::UsersAutoblocksScoresExporter.new(Decidim::User.where(blocked: false))

          @export_path = exporter.export
          @block_data = exporter.data
        end
      end
    end
  end
end
