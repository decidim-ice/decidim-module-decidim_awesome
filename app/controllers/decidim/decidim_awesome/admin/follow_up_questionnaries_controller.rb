# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class FollowUpQuestionnariesController < DecidimAwesome::Admin::ApplicationController
        include NeedsAwesomeConfig

        before_action do
          enforce_permission_to :edit_config, :follow_up_questionnaries
        end

        def index; end

        def new
          @form = form(FollowUpQuestionnaryForm).instance
        end
      end
    end
  end
end
