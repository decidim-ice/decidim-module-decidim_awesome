# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class MigrateLegacyImagesJob < ApplicationJob
      queue_as :default

      def perform(organization_id, mappings = [], logger = Rails.logger)
        @organization_id = organization_id
        @routes_mappings = mappings
        @logger = logger

        migrate_all!
        transform_images_urls
      end

      private

      attr_reader :routes_mappings, :logger

      def migrate_all!
        Decidim::CarrierWaveMigratorService.migrate_attachment!(
          klass: Decidim::DecidimAwesome::EditorImage,
          cw_attribute: "image",
          cw_uploader: Decidim::Cw::DecidimAwesome::ImageUploader,
          as_attribute: "file",
          logger: @logger,
          routes_mappings: routes_mappings
        )
      end

      def transform_images_urls
        mappings = routes_mappings.map do |mapping|
          klass, id = mapping[:instance].split("#")
          next unless klass == "Decidim::DecidimAwesome::EditorImage"

          instance = Decidim::DecidimAwesome::EditorImage.find_by(id: id)

          next if instance.blank?

          mapping.merge!(instance: instance)
        end.compact

        editor_images_available_attributes.each do |model, attributes|
          model.all.each do |item|
            attributes.each do |attribute|
              item.update(attribute => rewrite_value(item.send(attribute), mappings))
            end
          end
          @logger.info "Updated model #{model.name} (attributes: #{attributes.join(", ")})"
        end
      end

      def rewrite_value(value, mappings)
        if value.is_a?(Hash)
          value.transform_values do |nested_value|
            rewrite_value(nested_value, mappings)
          end
        else
          parser = Decidim::DecidimAwesome::ContentParsers::EditorImagesParser.new(value, routes_mappings: mappings)
          parser.rewrite
        end
      end

      def editor_images_available_attributes
        {
          "Decidim::Accountability::Result" => %w(description),
          "Decidim::Proposals::Proposal" => %w(body answer cost_report execution_period),
          "Decidim::Votings::Voting" => %w(description),
          "Decidim::Elections::Question" => %w(description),
          "Decidim::Elections::Answer" => %w(description),
          "Decidim::Elections::Election" => %w(description),
          "Decidim::Initiative" => %w(description answer),
          "Decidim::InitiativesType" => %w(description extra_fields_legal_information),
          "Decidim::Assembly" => %w(short_description description purpose_of_action composition internal_organisation announcement closing_date_reason special_features),
          "Decidim::Forms::Questionnaire" => %w(description tos),
          "Decidim::Forms::Question" => %w(description),
          "Decidim::Organization" => %w(welcome_notification_body admin_terms_of_service_body description highlighted_content_banner_short_description id_documents_explanation_text),
          "Decidim::StaticPage" => %w(content),
          "Decidim::ContextualHelpSection" => %w(content),
          "Decidim::Category" => %w(description),
          "Decidim::Blogs::Post" => %w(body),
          "Decidim::Pages::Page" => %w(body),
          "Decidim::Sortitions::Sortition" => %w(additional_info witnesses cancel_reason),
          "Decidim::Consultations::Question" => %w(title question_context what_is_decided instructions),
          "Decidim::Consultation" => %w(description),
          "Decidim::Debates::Debate" => %w(description instructions information_updates conclusions),
          "Decidim::Budgets::Budget" => %w(description),
          "Decidim::Budgets::Project" => %w(description),
          "Decidim::ConferenceSpeaker" => %w(short_bio),
          "Decidim::Conferences::RegistrationType" => %w(description),
          "Decidim::Conference" => %w(short_description description objectives registration_terms),
          "Decidim::ParticipatoryProcessGroup" => %w(description),
          "Decidim::ParticipatoryProcess" => %w(short_description description announcement),
          "Decidim::ParticipatoryProcessStep" => %w(description),
          "Decidim::Meetings::AgendaItem" => %w(description),
          "Decidim::Meetings::Meeting" => %w(registration_terms description registration_email_custom_content closing_report)
        }.each_with_object({}) do |(main_model, attributes), hash|
          hash[main_model.constantize] = attributes
        rescue NameError
          hash
        end
      end
    end
  end
end
