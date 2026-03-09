# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class AutoblockUsers < Command
        include Decidim::TranslatableAttributes

        def initialize(organization, current_user, perform_block: true)
          @organization = organization
          @current_user = current_user
          @perform_block = perform_block
          @current_config = AwesomeConfig.find_or_initialize_by(var: :users_autoblocks_config, organization:)
          @users_autoblocks = AwesomeConfig.find_or_initialize_by(var: :users_autoblocks, organization:)
        end

        # Executes the command. Broadcasts these events:
        #
        # - `:ok` when everything is valid
        # - `:invalid` if we couldn't proceed
        #
        # Returns nothing
        def call
          return broadcast(:invalid, "No threshold configured") if threshold.blank?

          scores_data
          return broadcast(:invalid, "No scores file found") if @scores_counts.blank?

          if detected_users.any?
            mark_users_for_autoblock!
            send_notification_to_admins!
            block_users! if perform_block
          end

          broadcast(:ok, detected_users.count, perform_block)
        rescue StandardError => e
          broadcast(:invalid, e.message)
        end

        private

        attr_reader :organization, :current_user, :perform_block, :current_config, :result

        def mark_users_for_autoblock!
          notify_autoblock = notify_blocked_users?

          detected_users.find_in_batches do |group|
            group.each do |user|
              extended_data = user.extended_data || {}
              next if extended_data && user.extended_data["notify_autoblock"] == notify_autoblock

              user.update_attribute(:extended_data, extended_data.merge("autoblock" => true, "notify_autoblock" => notify_autoblock)) # rubocop:disable Rails/SkipsModelValidations
            end
          end

          @detected_users = nil
        end

        def block_users!
          message = block_justification_message

          detected_users.find_in_batches do |group|
            group.each do |user|
              create_report!(user)
              check_user_validation!(user)

              block_form = Decidim::Admin::BlockUserForm.from_model(user).with_context(current_organization: @organization, current_user:)
              I18n.with_locale(user.locale || @organization.default_locale) do
                block_form.justification = translated_attribute(message)
              end
              block_form.hide = true

              Decidim::Admin::BlockUser.call(block_form) do
                on(:invalid) do
                  raise "User could not be blocked"
                end
              end
            end
          end
        end

        def block_justification_message
          if notify_blocked_users?
            current_config.value&.dig("block_justification_message")
          else
            default_block_justification_message
          end
        end

        def default_block_justification_message
          I18n.t("decidim.decidim_awesome.admin.users_autoblocks.config_form.default_block_justification_message")
        end

        def notify_blocked_users?
          return if current_config.value.blank?

          current_config.value["notify_blocked_users"]
        end

        def create_report!(user)
          moderation = UserModeration.find_or_create_by!(user:)

          return if UserReport.exists?(moderation:, user:)

          UserReport.create!(
            moderation:,
            user:,
            reason: "does_not_belong",
            details: "Autoblock"
          )

          moderation.increment!(:report_count)
        end

        def check_user_validation!(user)
          return if user.valid?

          user.nickname = Decidim::User.nicknamize("user_blocked_#{SecureRandom.alphanumeric(8)}", @organization.id)

          user.save!
        end

        def send_notification_to_admins!
          @organization.admins.each do |admin|
            next unless admin.email_on_moderations

            Decidim::DecidimAwesome::UsersAutoblocksReportJob.perform_later(admin, detected_users.map { |user| user.id.to_s }, block_performed: perform_block)
          end
        end

        def detected_users
          @detected_users ||= if threshold.present?
                                user_ids = @data.select { |row| row["total_score"].to_f >= threshold }.map { |row| row["id"] }
                                users_base_relation.where(id: user_ids)
                              else
                                Decidim::User.none
            end
        end

        def scores_data
          load_calculations
        end

        def config_exists?
          AwesomeConfig.exists?(var: :users_autoblocks_config, organization: @organization)
        end

        def load_calculations
          @scores_counts = {}
          return unless config_exists?
          return if calculations_blob.blank?

          calculations_blob.open do |file|
            calculations = CSV.read(file.path, headers: true, col_sep: ";")

            rules_headers = calculations.headers.grep(/ - \d+/)
            counts = rules_headers.index_with { |rule_header| calculations.count { |row| row[rule_header].to_i.positive? } }

            @threshold_detected_cases = calculations.count { |row| row["total_score"].to_i >= threshold }
            @scores_counts = counts.transform_keys { |k| k.split(" - ").last.to_i }
            @data = calculations
          end
        end

        def calculations_blob
          @calculations_blob ||= ActiveStorage::Blob.where(filename: "#{@organization.id}-#{Decidim::DecidimAwesome::UsersAutoblocksScoresExporter::DATA_FILE_KEY}").last
        end

        def threshold
          @threshold ||= current_config.value&.dig("threshold")&.to_f
        end

        def users_base_relation
          @users_base_relation ||= Decidim::User
                                   .where(organization:)
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
