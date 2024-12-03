# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class AutoblockUsers < Command
        include Decidim::TranslatableAttributes

        # Public: Initializes the command.
        #
        def initialize(form)
          @form = form
          @users_autoblocks = AwesomeConfig.find_or_initialize_by(var: :users_autoblocks, organization: current_organization)
          @current_config = AwesomeConfig.find_or_initialize_by(var: :users_autoblocks_config, organization: current_organization)
          @perform_block = @form.perform_block
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid, @form.errors.full_messages) if form.invalid?

          transaction do
            save_configuration!
            calculate_scores
            block_users! if perform_block && detected_users.exists?
            send_notification_to_admins! if detected_users.exists?
          end

          broadcast(:ok, detected_users.length, perform_block)
        rescue StandardError => e
          broadcast(:invalid, e.message)
        end

        private

        attr_reader :form, :users_autoblocks, :current_config, :perform_block

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

            Decidim::DecidimAwesome::UsersAutoblocksReportJob.perform_later(admin, detected_users.map { |user| user.id.to_s }, block_performed: perform_block)
          end
        end

        def detected_users
          @detected_users ||= begin
            threshold = current_config.value&.dig("threshold")
            if threshold.present?
              user_ids = @block_data.select { |item| item[:total_score] >= threshold }.map { |item| item[:id] }
              users_base_relation.where(organization: current_organization, id: user_ids)
            else
              Decidim::User.none
            end
          end
        end

        def calculate_scores
          exporter = Decidim::DecidimAwesome::UsersAutoblocksScoresExporter.new(users_base_relation)

          @export_path = exporter.export
          @block_data = exporter.data
        end

        def users_base_relation
          @users_base_relation ||= Decidim::User
                                   .where(organization: current_organization)
                                   .joins("LEFT JOIN decidim_authorizations ON decidim_authorizations.decidim_user_id = decidim_users.id")
                                   .where(decidim_authorizations: { granted_at: nil })
                                   .where.not(admin: true)
                                   .not_deleted
                                   .not_blocked
        end
      end
    end
  end
end
