# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class AwesomeAuthorizationMembersForm < Decidim::Form
        include Decidim::HasUploadValidations
        include Decidim::ProcessesFileLocally

        attribute :remove_previous_members, Boolean
        attribute :emails, String
        attribute :file, Decidim::Attributes::Blob

        validates :file, file_content_type: { allow: ["text/csv"] }

        def data
          @data ||= process_data do |text|
            extract_emails_from_text(text)
          end
        end

        def process_data
          if file.present?
            text = process_file_locally(file) do |file_path|
              File.read(file_path)
            end
            yield text
          else
            yield emails.to_s
          end
        end

        def authorization_group
          context[:authorization_group]
        end

        private

        def extract_emails_from_text(text)
          text.split(/[\s,;]+/).map { |email| email.strip.downcase }.grep(URI::MailTo::EMAIL_REGEXP)
        end
      end
    end
  end
end
