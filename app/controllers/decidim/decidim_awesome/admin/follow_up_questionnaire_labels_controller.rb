# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class FollowUpQuestionnaireLabelsController < DecidimAwesome::Admin::ApplicationController
        before_action :follow_up_questionnaire
        before_action :label, only: [:edit, :update, :destroy]

        def index; end
        def new; end
        def create; end
        def edit; end
        def update; end
        def destroy; end
      end
    end
  end
end
