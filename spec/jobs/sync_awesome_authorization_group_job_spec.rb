# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  describe SyncAwesomeAuthorizationGroupJob do
    let(:organization) { create(:organization, available_authorizations: ["awesome_authorization_handler"]) }
    let(:authorization_group) { create(:awesome_authorization_group, organization: organization) }

    describe "#perform" do
      context "when a member user should be granted" do
        let(:user) { create(:user, :confirmed, organization: organization, email: "member@example.org") }
        let!(:authorization_member) { create(:awesome_authorization_member, authorization_group: authorization_group, email: user.email) }

        it "creates or updates the awesome authorization" do
          expect do
            described_class.perform_now(authorization_group.id)
          end.to change { Decidim::Authorization.find_by(user: user, name: "awesome_authorization_handler")&.granted? }
            .from(nil).to(true)
        end
      end

      context "when a previously granted user is no longer a member" do
        let(:user) { create(:user, :confirmed, organization: organization, email: "old_member@example.org") }
        let!(:authorization) { create(:authorization, :granted, user: user, name: "awesome_authorization_handler", metadata: { "groups" => { authorization_group.id.to_s => authorization_group.name } }) }

        it "removes the awesome authorization" do
          expect do
            described_class.perform_now(authorization_group.id)
          end.to change { Decidim::Authorization.where(user: user, name: "awesome_authorization_handler").count }.from(1).to(0)
        end
      end
    end
  end
end
