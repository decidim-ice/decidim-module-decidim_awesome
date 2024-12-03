# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    # A custom mailer to notify Decidim users
    # that they have been reported
    class UsersAutoblocksReportMailer < ApplicationMailer
      def notify(admin, detected_user_ids, block_performed: true)
        @admin = admin
        @detected_user_ids = detected_user_ids
        @organization = admin.organization
        @justification = current_config["block_justification_message"]
        @block_performed = block_performed
        add_report_attachment
        with_user(admin) do
          mail(to: admin.email, subject: I18n.t(
            block_performed ? "subject_performed" : "subject_calculated",
            organization_name: @organization.name,
            scope: "decidim.decidim_awesome.users_autoblocks_report_mailer.notify"
          ))
        end
      end

      private

      def current_config
        @current_config ||= AwesomeConfig.find_by(var: :users_autoblocks_config, organization: @organization)&.value || {}
      end

      def add_report_attachment
        calculations_path = File.join(Rails.application.root, Decidim::DecidimAwesome::UsersAutoblocksScoresExporter::DATA_FILE_PATH)
        return unless File.exist?(calculations_path)

        calculations = CSV.read(calculations_path, headers: true, col_sep: ";")

        filtered_calculations = calculations.select { |row| @detected_user_ids.include?(row["id"]) }
        data = Decidim::Exporters::CSV.new(filtered_calculations).export

        filename = @block_performed ? "blocked_users.csv" : "detected_users.csv"
        attachments[filename] = data.read
      end
    end
  end
end
