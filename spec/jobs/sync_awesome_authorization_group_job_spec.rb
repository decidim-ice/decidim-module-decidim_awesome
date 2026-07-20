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

      context "when a user belongs to two groups and is removed from one" do
        let(:user) { create(:user, :confirmed, organization: organization, email: "shared@example.org") }
        let(:other_group) { create(:awesome_authorization_group, organization: organization) }
        let!(:member_in_synced_group) { create(:awesome_authorization_member, authorization_group: authorization_group, email: user.email) }
        let!(:member_in_other_group) { create(:awesome_authorization_member, authorization_group: other_group, email: user.email) }
        let!(:authorization) do
          create(
            :authorization,
            :granted,
            user: user,
            name: "awesome_authorization_handler",
            metadata: {
              "groups" => {
                authorization_group.id.to_s => authorization_group.name,
                other_group.id.to_s => other_group.name
              }
            }
          )
        end

        before do
          member_in_synced_group.destroy!
        end

        it "keeps the authorization and removes the synced group from metadata" do
          expect do
            described_class.perform_now(authorization_group.id)
          end.not_to(change { Decidim::Authorization.where(user: user, name: "awesome_authorization_handler").count })

          authorization.reload
          expect(authorization.metadata["groups"].keys).to contain_exactly(other_group.id.to_s)
        end
      end
    end
  end
end
