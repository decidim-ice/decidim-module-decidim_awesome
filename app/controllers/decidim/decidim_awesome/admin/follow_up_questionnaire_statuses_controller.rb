# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class FollowUpQuestionnaireStatusesController < DecidimAwesome::Admin::ApplicationController
        before_action :follow_up_questionnaire
        before_action :status, only: [:edit, :update, :destroy]

        def index; end

        def new
          @form = form(FollowUpQuestionnaireStatusForm).instance
        end

        def create; end
        def edit; end
        def update; end
        def destroy; end
      end
    end
  end
end
