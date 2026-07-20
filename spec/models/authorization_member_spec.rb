# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  describe AuthorizationMember do
    subject { authorization_member }

    let(:authorization_group) { create(:awesome_authorization_group) }
    let(:authorization_member) { create(:awesome_authorization_member, authorization_group:) }

    it { is_expected.to be_valid }

    it "has an authorization group associated" do
      expect(authorization_member.authorization_group).to eq(authorization_group)
    end

    it "has an email" do
      expect(authorization_member.email).to be_present
    end

    it "normalizes email to lowercase" do
      member = create(:awesome_authorization_member, email: "TEST@EXAMPLE.COM")
      expect(member.email).to eq("test@example.com")
    end

    it "normalizes email to strip whitespace" do
      member = create(:awesome_authorization_member, email: "  test@example.com  ")
      expect(member.email).to eq("test@example.com")
    end

    context "when email is invalid" do
      it "is not valid" do
        member = build(:awesome_authorization_member, email: "invalid-email")
        expect(member).not_to be_valid
      end
    end

    context "when email is not unique within the same group" do
      before { create(:awesome_authorization_member, authorization_group:, email: "test@example.com") }

      it "is not valid" do
        member = build(:awesome_authorization_member, authorization_group:, email: "test@example.com")
        expect(member).not_to be_valid
      end

      it "is valid with same email in different group" do
        other_group = create(:awesome_authorization_group)
        member = build(:awesome_authorization_member, authorization_group: other_group, email: "test@example.com")
        expect(member).to be_valid
      end
    end

    context "when email uniqueness is case-insensitive" do
      before { create(:awesome_authorization_member, authorization_group:, email: "test@example.com") }

      it "is not valid with different case" do
        member = build(:awesome_authorization_member, authorization_group:, email: "TEST@EXAMPLE.COM")
        expect(member).not_to be_valid
      end
    end

    describe "ransack search" do
      let!(:member) { create(:awesome_authorization_member, authorization_group:, email: "findme@example.org") }
      let!(:other_member) { create(:awesome_authorization_member, authorization_group:, email: "other@example.org") }

      it "allows filtering members by email" do
        expect(described_class.ransack(email_cont: "findme").result).to contain_exactly(member)
      end

      it "exposes no associations for filtering" do
        expect(described_class.ransackable_associations).to be_empty
      end
    end

    describe "#group_authorized?" do
      let(:organization) { authorization_group.organization }
      let(:user) { create(:user, :confirmed, organization:, email: authorization_member.email) }

      context "when member has no authorization" do
        it "returns false" do
          expect(authorization_member.group_authorized?(authorization_group)).to be(false)
        end
      end

      context "when authorization metadata includes the group id as a string" do
        before do
          user
          create(
            :authorization,
            user:,
            name: "awesome_authorization_handler",
            metadata: { "groups" => [authorization_group.id.to_s] }
          )
        end

        it "returns true" do
          expect(authorization_member.group_authorized?(authorization_group)).to be(true)
        end
      end

      context "when authorization metadata does not include the group id" do
        before do
          user
          create(
            :authorization,
            user:,
            name: "awesome_authorization_handler",
            metadata: { "groups" => ["other-group"] }
          )
        end

        it "returns false" do
          expect(authorization_member.group_authorized?(authorization_group)).to be(false)
        end
      end
    end
  end
end
