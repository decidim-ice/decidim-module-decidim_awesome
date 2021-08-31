# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe User do
    subject { user }

    let(:user) { create(:user) }

    it { is_expected.to be_valid }

    shared_examples "not admin" do
      it "user respond to admin overrides" do
        expect(User).to respond_to(:awesome_admins_for_current_scope, :awesome_potential_admins)
        expect(User.awesome_admins_for_current_scope).to be_blank
        expect(User.awesome_potential_admins).to be_blank
      end

      it "user is not admin" do
        expect(subject.admin).to be_blank
        expect(subject).not_to be_admin
      end
    end

    shared_examples "is admin" do
      it "user is admin" do
        expect(subject.admin).to be_truthy
        expect(subject).to be_admin
      end
    end

    context "when list is an empty array" do
      before do
        User.awesome_admins_for_current_scope = []
      end

      it_behaves_like "not admin"
    end

    context "when list is nil" do
      before do
        User.awesome_admins_for_current_scope = nil
      end

      it_behaves_like "not admin"
    end

    context "when user is already an admin" do
      let(:user) { create(:user, :admin) }

      it_behaves_like "is admin"
    end

    context "when admin is listed in the current scope" do
      before do
        User.awesome_admins_for_current_scope = [user.id]
      end

      it_behaves_like "is admin"
    end
  end
end
