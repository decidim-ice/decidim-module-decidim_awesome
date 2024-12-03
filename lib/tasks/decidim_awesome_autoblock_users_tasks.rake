# frozen_string_literal: true

namespace :decidim_decidim_awesome do
  namespace :autoblock_users do
    desc "Performs autoblock users task"
    task run: :environment do
      Decidim::Organization.all.each do |organization|
        if (current_config = organization_config(organization)).blank?
          puts "\nSkipping #{organization.name}...\n"
          next
        end

        puts "\nRunning on #{organization.name}...\n"

        config_data = OpenStruct.new(current_config.value || {})
        config_form = Decidim::DecidimAwesome::Admin::UsersAutoblocksConfigForm.from_model(config_data).with_context(current_organization: organization)

        Decidim::DecidimAwesome::Admin::AutoblockUsers.call(config_form) do
          on(:ok) do |count, block_performed|
            if block_performed
              puts "\n✓ Process finished. Total users detected: #{count}. Block not performed.\n"
            else
              puts "\n✓ Process finished. Total users detected and blocked: #{count}.\n"
            end
          end

          on(:invalid) do |messages|
            puts "\n✗ Something has failed. Messages:\n"
            messages.each do |message|
              puts "* #{message}\n"
            end
          end
        end
      end
    end

    def organization_config(organization)
      Decidim::DecidimAwesome::AwesomeConfig.find_by(var: :users_autoblocks_config, organization:)
    end
  end
end
