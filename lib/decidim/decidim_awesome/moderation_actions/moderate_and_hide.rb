# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module ModerationActions
      class ModerateAndHide
        def initialize(resource, options = {})
          @object = resource
          @options = options
        end

        def execute
          tool = Decidim::ModerationTools.new(@object, admin)
          tool.create_report!(reason: "spam", details: "This content has been automatically moderated and hidden.")
          tool.hide!
          tool.update_report_count!
          tool.update_reported_content!
        end

        def admin
          @options["admin"] || Decidim::User.where(admin: true).first
        end
      end
    end
  end
end
