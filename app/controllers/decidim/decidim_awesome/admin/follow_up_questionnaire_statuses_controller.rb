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

        def edit
          @form = form(FollowUpQuestionnaireStatusForm).from_model(status)
        end

        def update; end

        def destroy; end

        private

        def follow_up_questionnaire
          @follow_up_questionnaire ||= begin
            id = params[:follow_up_questionnaire_id]
            id.present? ? OpenStruct.new(id:) : OpenStruct.new(id: nil)
          end
        end

        def status
          @status ||= OpenStruct.new(
            id: params[:id],
            follow_up_questionnaire_id: follow_up_questionnaire.id,
            name: nil,
            color: nil
          )
        end
      end
    end
  end
end
