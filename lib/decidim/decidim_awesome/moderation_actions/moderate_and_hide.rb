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
                    tool = Decidim::ModerationTools.new(@resource, admin)
                    transaction do
                        tool.create_report(reason: "Automated moderation action: Moderate and Hide", details: "This content has been automatically moderated and hidden.")
                        tool.hide!
                        #tool.send_notification_to_author
                        tool.update_report_count
                        tool.update_reported_content!
                    end
                end

                def admin
                    @options["admin"] || Decidim::User.where(admin: true).first
                end
            end
        end
    end
end