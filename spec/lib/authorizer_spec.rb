# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  describe Authorizer do
    subject { described_class.new(user, admin_authorizations) }
    let(:organization) { create(:organization, available_authorizations:) }
    let(:available_authorizations) { [:dummy_authorization_handler, :another_dummy_authorization_handler, :id_documents] }
    let(:user) { create(:user, organization:) }
    let(:admin_authorizations) { %w(dummy_authorization_handler another_dummy_authorization_handler) }
    let!(:exising_authorization) { create(:authorization, :pending, user:, name: "id_documents") }

    shared_examples "an authorization's hash" do |granted, pending|
      it "returns the authorization's hash" do
        expect(subject.authorizations).to eq([
                                               {
                                                 name: "dummy_authorization_handler",
                                                 fullname: "Example authorization",
                                                 granted:,
                                                 pending:,
                                                 managed: true
                                               },
                                               {
                                                 name: "another_dummy_authorization_handler",
                                                 fullname: "Another example authorization",
                                                 granted: nil,
                                                 pending: false,
                                                 managed: true
                                               },
                                               {
                                                 name: "id_documents",
                                                 fullname: "Identity documents",
                                                 granted: false,
                                                 pending: true,
                                                 managed: false
                                               }
                                             ])
      end
    end

    it_behaves_like "an authorization's hash", nil, false

    context "when authorizations exist" do
      let!(:authorization) { create(:authorization, user:, name: "dummy_authorization_handler") }

      it_behaves_like "an authorization's hash", true, false
    end

    context "when authorization is pending" do
      let!(:authorization) { create(:authorization, :pending, user:, name: "dummy_authorization_handler") }

      it_behaves_like "an authorization's hash", false, true
    end

    context "when admin_authorizations contains non registered handlers" do
      let(:available_authorizations) { [:dummy_authorization_handler] }

      it "returns only the available authorizations" do
        expect(subject.authorizations).to eq([
                                               {
                                                 name: "dummy_authorization_handler",
                                                 fullname: "Example authorization",
                                                 granted: nil,
                                                 pending: false,
                                                 managed: true
                                               }
                                             ])
      end
    end
  end
end
