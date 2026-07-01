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

    describe "#user_count" do
      it "returns the count of authorization members" do
        create(:awesome_authorization_member, authorization_group:)
        create(:awesome_authorization_member, authorization_group:)
        expect(authorization_group.user_count).to eq(2)
      end

      it "returns 0 when no members" do
        expect(authorization_group.user_count).to eq(0)
      end
    end

    describe "#authorized_count" do
      it "returns 0 by default" do
        expect(authorization_group.authorized_count).to eq(0)
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
