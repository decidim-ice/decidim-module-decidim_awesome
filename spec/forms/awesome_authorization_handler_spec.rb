# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  describe AwesomeAuthorizationHandler do
    subject { described_class.from_params(params) }

    let(:params) { {} }
    let(:user) { create(:user, :confirmed) }

    before do
      subject.user = user
    end

    it "is not valid" do
      expect(subject).not_to be_valid
    end

    it "has an error message" do
      subject.valid?
      expect(subject.errors[:base]).to include("is invalid")
    end

    it "is a Decidim::AuthorizationHandler" do
      expect(subject).to be_a(Decidim::AuthorizationHandler)
    end
  end
end
