# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  describe AuthorizationGroup do
    subject { authorization_group }

    let(:organization) { create(:organization) }
    let(:authorization_group) { create(:awesome_authorization_group, organization:) }

    it { is_expected.to be_valid }

    it "has an organization associated" do
      expect(authorization_group.organization).to eq(organization)
    end

    it "has a name" do
      expect(authorization_group.name).to be_present
    end

    it "has a purpose" do
      expect(authorization_group.purpose).to be_present
    end

    describe "#members_count" do
      it "returns the count of authorization members" do
        create(:awesome_authorization_member, authorization_group:)
        create(:awesome_authorization_member, authorization_group:)
        expect(authorization_group.members_count).to eq(2)
      end

      it "returns 0 when no members" do
        expect(authorization_group.members_count).to eq(0)
      end
    end

    describe "#granted_in_group_count" do
      it "returns 0 by default" do
        expect(authorization_group.granted_in_group_count).to eq(0)
      end

      context "when users are authorized" do
        let(:user) { create(:user, :confirmed, organization:, email: "test@example.com") }

        before do
          create(:awesome_authorization_member, authorization_group:, email: "test@example.com")
          create(
            :authorization,
            user:,
            name: "awesome_authorization_handler",
            metadata: { "groups" => [authorization_group.id.to_s] }
          )
        end

        it "returns the count of authorized users" do
          expect(authorization_group.granted_in_group_count).to eq(1)
        end
      end

      context "when multiple groups exist" do
        let(:other_group) { create(:awesome_authorization_group, organization:) }
        let(:user1) { create(:user, :confirmed, organization:, email: "test1@example.com") }
        let(:user2) { create(:user, :confirmed, organization:, email: "test2@example.com") }

        before do
          create(:awesome_authorization_member, authorization_group:, email: user1.email)
          create(:awesome_authorization_member, authorization_group: other_group, email: user2.email)
          create(:authorization, user: user1, name: "awesome_authorization_handler", metadata: { "groups" => [authorization_group.id.to_s] })
          create(:authorization, user: user2, name: "awesome_authorization_handler", metadata: { "groups" => [other_group.id.to_s] })
        end

        it "does not leak counts across groups" do
          expect(authorization_group.granted_in_group_count).to eq(1)
          expect(other_group.granted_in_group_count).to eq(1)
        end
      end
    end

    describe "#authorizations_in_group" do
      it "returns authorizations for the current group" do
        expect(authorization_group.authorizations_in_group).to be_empty
      end
    end

    describe "#users" do
      let(:user) { create(:user, :confirmed, organization:, email: "test@example.com") }

      before do
        create(:awesome_authorization_member, authorization_group:, email: user.email)
      end

      it "returns users matching member emails" do
        expect(authorization_group.users).to include(user)
      end
    end

    describe "#users_count" do
      let(:user) { create(:user, :confirmed, organization:, email: "test@example.com") }

      before do
        create(:awesome_authorization_member, authorization_group:, email: user.email)
      end

      it "returns the count of users matching member emails" do
        expect(authorization_group.users_count).to eq(1)
      end
    end

    describe "#synced?" do
      let(:user) { create(:user, :confirmed, organization:, email: "test@example.com") }

      context "when no users are authorized" do
        before do
          create(:awesome_authorization_member, authorization_group:, email: user.email)
        end

        it "returns false" do
          expect(authorization_group.synced?).to be false
        end
      end

      context "when all users are authorized" do
        before do
          create(:awesome_authorization_member, authorization_group:, email: user.email)
          create(
            :authorization,
            user:,
            name: "awesome_authorization_handler",
            metadata: { "groups" => [authorization_group.id.to_s] }
          )
        end

        it "returns true" do
          expect(authorization_group.synced?).to be true
        end
      end

      context "when users are authorized but not for this group" do
        before do
          create(:awesome_authorization_member, authorization_group:, email: user.email)
          create(:authorization, user:, name: "awesome_authorization_handler", metadata: { "groups" => ["9999"] })
        end

        it "returns false" do
          expect(authorization_group.synced?).to be false
        end
      end
    end

    describe ".sync_user_authorization" do
      let(:user) { create(:user, :confirmed, organization:, email: "test@example.com") }

      context "when the user belongs to a group" do
        before { create(:awesome_authorization_member, authorization_group:, email: user.email) }

        it "grants the authorization with the group in metadata" do
          expect { described_class.sync_user_authorization(user) }.to change(Decidim::Authorization, :count).by(1)

          authorization = Decidim::Authorization.find_by(user:, name: "awesome_authorization_handler")
          expect(authorization.metadata["groups"]).to include(authorization_group.id.to_s)
        end
      end

      context "when the user belongs to no group" do
        let!(:authorization) { create(:authorization, user:, name: "awesome_authorization_handler", metadata: { "groups" => [authorization_group.id.to_s] }) }

        it "revokes the existing authorization" do
          expect { described_class.sync_user_authorization(user) }.to change(Decidim::Authorization, :count).by(-1)
          expect(Decidim::Authorization.find_by(user:, name: "awesome_authorization_handler")).to be_nil
        end
      end
    end

    describe "#reset_caches!" do
      it "recalculates memoized counters" do
        expect(authorization_group.members_count).to eq(0)
        create(:awesome_authorization_member, authorization_group:)

        expect { authorization_group.reset_caches! }.to change(authorization_group, :members_count).from(0).to(1)
      end
    end

    context "when authorization group is destroyed" do
      let!(:member) { create(:awesome_authorization_member, authorization_group:) }

      it "destroys the authorization members" do
        expect { authorization_group.destroy }.to change(Decidim::DecidimAwesome::AuthorizationMember, :count).by(-1)
      end
    end
  end
end
