# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe User do
    subject { user }

    let(:user) { create(:user) }

    it { is_expected.to be_valid }

    it "user respond to admin overridees" do
      expect(User).to respond_to(:awesome_admins_for_current_scope, :awesome_potential_admins)
      expect(User.awesome_admins_for_current_scope).to be_nil
      expect(User.awesome_potential_admins).to be_nil
    end

    it "user is not admin by default" do
      expect(subject.admin).to be_nil
      expect(subject).not_to be_admin
    end

    context "when admin is listed in the current scope" do
      before do
        User.awesome_admins_for_current_scope = [user.id]
      end

      it "user is admin" do
        expect(subject.admin).to be_truthy
        expect(subject).to be_admin
      end
    end
  end
end
