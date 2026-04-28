# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
    module ModerationActions
        describe ModerateAndHide do
            subject { described_class.new(resource) }

            let!(:resource) { create(:comment) }
            let(:organization) { resource.author.organization }
            let!(:admin) { create(:user, :confirmed, :admin, organization:) }

            it "moderates the resource" do
                expect do
                    subject.execute
                end.to change { resource.reports.count }.from(0).to(1)

                expect(resource.moderation.hidden_at).not_to be_nil
            end
        end
    end
end