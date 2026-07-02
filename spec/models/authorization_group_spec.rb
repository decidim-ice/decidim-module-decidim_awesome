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

    describe "#granted_count" do
      it "returns 0 by default" do
        expect(authorization_group.granted_count).to eq(0)
      end

      context "when users are authorized" do
        let(:user) { create(:user, :confirmed, organization:, email: "test@example.com") }

        before do
          create(:awesome_authorization_member, authorization_group:, email: "test@example.com")
          create(:authorization, user:, name: "awesome_authorization_handler")
        end

        it "returns the count of authorized users" do
          expect(authorization_group.granted_count).to eq(1)
        end
      end
    end

    describe "#granted" do
      it "returns an authorization query" do
        expect(authorization_group.granted).to be_a(ActiveRecord::Relation)
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
          create(:authorization, user:, name: "awesome_authorization_handler")
        end

        it "returns true" do
          expect(authorization_group.synced?).to be true
        end
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
