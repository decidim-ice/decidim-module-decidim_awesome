# frozen_string_literal: true

task("decidim_decidim_awesome:autoblock_users:run_block").clear
task("decidim_decidim_awesome:autoblock_users:run_scheduled_block").clear

namespace :decidim_decidim_awesome do
  namespace :autoblock_users do
    desc "Performs autoblock users task"
    task :run_block, [:admin_email, :perform_block] => :environment do |_task, args|
      current_user = Decidim::User.where(admin: true).find_by(email: args.admin_email)
      perform_block = args.perform_block == "true"

      raise "A valid admin email is required to run this task" if current_user.blank?

      Decidim::Organization.find_each do |current_organization|
        if (current_config = organization_config(current_organization)).blank?
          puts "\nSkipping #{current_organization.name}...\n"
          next
        end

        puts "\nRunning on #{current_organization.name}...\n"

        config_data = OpenStruct.new(current_config.value || {})
        config_form = Decidim::DecidimAwesome::Admin::UsersAutoblocksConfigForm.from_model(config_data).with_context(current_organization:, current_user:)
        config_form.perform_block = perform_block
        config_form.block_justification_message = config_form.default_block_justification_message if config_form.block_justification_message.blank?

        run_command(config_form)
      end
    end

    desc "Performs scheduled autoblock users tasks on organizations where settings allows it"
    task run_scheduled_block: :environment do
      Decidim::Organization.find_each do |current_organization|
        current_config = organization_config(current_organization)
        current_user = nil
        skip_organization = current_config.blank?

        unless skip_organization
          perform_task = current_config.value&.dig("allow_performing_block_from_a_task")
          current_user = Decidim::User.where(admin: true, organization: current_organization).find_by(id: current_config.value&.dig("admin_id"))

          skip_organization = !perform_task || current_user.blank?
        end

        if skip_organization
          puts "\nSkipping #{current_organization.name}...\n"
          next
        end

        puts "\nRunning on #{current_organization.name}...\n"

        config_data = OpenStruct.new(current_config.value || {})
        config_form = Decidim::DecidimAwesome::Admin::UsersAutoblocksConfigForm.from_model(config_data).with_context(current_organization:, current_user:)
        config_form.perform_block = true
        config_form.block_justification_message = config_form.default_block_justification_message if config_form.block_justification_message.blank?

        run_command(config_form)
      end
    end

    def run_command(config_form)
      Decidim::DecidimAwesome::Admin::AutoblockUsers.call(config_form) do
        on(:ok) do |count, block_performed|
          if block_performed
            puts "\n✓ Process finished. Total users detected and blocked: #{count}.\n"
          else
            puts "\n✓ Process finished. Total users detected: #{count}. Block not performed.\n"
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

    def organization_config(organization)
      Decidim::DecidimAwesome::AwesomeConfig.find_by(var: :users_autoblocks_config, organization:)
    end
  end
end
