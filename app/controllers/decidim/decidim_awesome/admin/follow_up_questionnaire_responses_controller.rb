# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class FollowUpQuestionnaireResponsesController < DecidimAwesome::Admin::ApplicationController
        before_action :follow_up_questionnaire
        before_action :response, only: [:show, :edit, :update, :destroy]

        def index:; end

      end
    end
  end
end
