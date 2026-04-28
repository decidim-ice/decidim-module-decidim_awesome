# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
    include ActiveJob::TestHelper
    
    describe "Trigger of moderation processor job" do
        let(:comment) { create(:comment) }
        let(:proposal) { create(:proposal) }
        let(:survey) { create(:survey) }

        before do
            ActiveJob::Base.queue_adapter = :test
        end


        it "enqueues the ModerationProcessorJob when the event of a message creation is sent" do
            expect {
                ActiveSupport::Notifications.publish(
                "decidim.comments.create_comment:after",
                resource: comment
                )
            }.to have_enqueued_job(ModerationProcessorJob).with(comment).on_queue("default")
        end

        it "enqueues the ModerationProcessorJob when the event of a message update is sent" do
            expect {
                ActiveSupport::Notifications.publish(
                "decidim.comments.update_comment:after",
                resource: comment
                )
            }.to have_enqueued_job(ModerationProcessorJob).with(comment).on_queue("default")
        end

        it "enqueues the ModerationProcessorJob when the event of a proposal creation is sent" do
            expect {
                ActiveSupport::Notifications.publish(
                "decidim.proposals.create_proposal:after",
                resource: proposal
                )
            }.to have_enqueued_job(ModerationProcessorJob).with(proposal).on_queue("default")
        end

        it "enqueues the ModerationProcessorJob when the event of a proposal update is sent" do
            expect {
                ActiveSupport::Notifications.publish(
                "decidim.proposals.update_proposal:after",
                resource: proposal
                )
            }.to have_enqueued_job(ModerationProcessorJob).with(proposal).on_queue("default")
        end

        it "does not enqueue the ModerationProcessorJob when the event of an unrelated model is sent" do
            expect {
                ActiveSupport::Notifications.publish(
                "decidim.surveys.create_survey:after",
                resource: survey
                )
            }.not_to have_enqueued_job(ModerationProcessorJob)
        end
    end
end