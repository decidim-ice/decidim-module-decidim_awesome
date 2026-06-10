# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module AutoModeration
      module Actions
        class ModerateAndHide
          def initialize(resource, options = {})
            @object = resource
            @options = options
          end

          def execute
            tool = Decidim::ModerationTools.new(@object, admin)
            begin
              tool.create_report!(reason: "spam", details: "This content has been automatically moderated and hidden.")
              tool.hide!
            rescue ActiveRecord::RecordInvalid
              # Most likely is a "Validation failed: User has already been taken"
              # Continue with updating the report count
            end
            tool.update_report_count!
            tool.update_reported_content!
          end

          def admin
            organization = @object.organization
            @options["admin"] || Decidim::User.where(admin: true, organization:).first
          end
        end
      end
    end
  end
end
