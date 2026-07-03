# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  describe AwesomeAuthorizationHandler do
    subject { described_class.from_params(params) }

    let(:params) { {} }
    let(:organization) { create(:organization) }
    let(:user) { create(:user, :confirmed, organization:) }
    let(:authorization_group) { create(:awesome_authorization_group, organization:) }

    before do
      subject.user = user
    end

    it "is a Decidim::AuthorizationHandler" do
      expect(subject).to be_a(Decidim::AuthorizationHandler)
    end

    context "when user does not belong to any group" do
      it "is not valid" do
        expect(subject).not_to be_valid
      end

      it "has an error message" do
        subject.valid?
        expect(subject.errors[:base]).to include(I18n.t("decidim.decidim_awesome.awesome_authorization_handler.errors.user_not_in_group", email: user.email))
      end
    end

    context "when user belongs to a group" do
      before do
        create(:awesome_authorization_member, authorization_group:, email: user.email)
      end

      it "is valid" do
        expect(subject).to be_valid
      end

      it "has a unique_id" do
        expect(subject.unique_id).to eq(user.id.to_s)
      end

      it "has metadata with groups" do
        expect(subject.metadata[:groups]).to be_a(Hash)
        expect(subject.metadata[:groups].keys).to include(authorization_group.id.to_s)
      end
    end

    context "when user belongs to multiple groups" do
      let(:another_group) { create(:awesome_authorization_group, organization:) }

      before do
        create(:awesome_authorization_member, authorization_group:, email: user.email)
        create(:awesome_authorization_member, authorization_group: another_group, email: user.email)
      end

      it "is valid" do
        expect(subject).to be_valid
      end

      it "has metadata with all groups" do
        expect(subject.metadata[:groups].keys).to include(authorization_group.id.to_s, another_group.id.to_s)
      end
    end

    context "when user email is case-insensitive match" do
      before do
        create(:awesome_authorization_member, authorization_group:, email: user.email.upcase)
      end

      it "is valid" do
        expect(subject).to be_valid
      end
    end
  end
end
