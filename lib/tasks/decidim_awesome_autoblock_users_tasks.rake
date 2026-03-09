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
          puts "\nSkipping Organization: #{current_organization.id} - #{translated_attribute(current_organization.name)}...\n"
          next
        end

        puts "\nRunning on Organization: #{current_organization.id} - #{translated_attribute(current_organization.name)}...\n"

        admin_for_org = Decidim::User.where(admin: true, organization: current_organization).first
        if admin_for_org.blank?
          puts "\n✗ No admin found for organization.\n"
          next
        end

        run_job(admin_for_org, perform_block)
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
          puts "\nSkipping Organization: #{current_organization.id} - #{translated_attribute(current_organization.name)}...\n"
          next
        end

        puts "\nRunning on Organization: #{current_organization.id} - #{translated_attribute(current_organization.name)}...\n"

        run_job(current_user, true)
      end
    end

    def run_job(admin, perform_block)
      result = Decidim::DecidimAwesome::UsersAutoblocksBlockJob.perform_now(admin, perform_block:)

      if result[:error]
        puts "\n✗ Something has failed. Error: #{result[:error]}\n"
      elsif result[:block_performed]
        puts "\n✓ Process finished. Total users detected and blocked: #{result[:count]}.\n"
      else
        puts "\n✓ Process finished. Total users detected: #{result[:count]}. Block not performed.\n"
      end
    end

    def organization_config(organization)
      Decidim::DecidimAwesome::AwesomeConfig.find_by(var: :users_autoblocks_config, organization:)
    end
  end
end
