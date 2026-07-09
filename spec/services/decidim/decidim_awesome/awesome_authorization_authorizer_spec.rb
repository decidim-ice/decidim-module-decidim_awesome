# frozen_string_literal: true

require "spec_helper"

module Decidim
  module DecidimAwesome
    describe AwesomeAuthorizationAuthorizer do
      subject { described_class.new(authorization, options, component, nil).authorize }

      let(:organization) { create(:organization, available_authorizations: ["awesome_authorization_handler"]) }
      let(:component) { create(:proposal_component, organization:) }
      let(:user) { create(:user, organization:) }
      let(:authorization) do
        create(
          :authorization,
          :granted,
          user:,
          name: "awesome_authorization_handler",
          metadata: {
            "groups" => {
              "12" => { "en" => "Board members" },
              "34" => { "en" => "Staff" }
            }
          }
        )
      end
      let(:options) { {} }

      context "when no group restriction is configured" do
        it "authorizes the action" do
          expect(subject).to eq([:ok, {}])
        end
      end

      context "when restriction includes at least one user group" do
        let(:options) { { "awesome_authorization_groups" => "99,12" } }

        it "authorizes the action" do
          expect(subject).to eq([:ok, {}])
        end
      end

      context "when restriction does not match user groups" do
        let(:options) { { "awesome_authorization_groups" => "99,100" } }

        it "marks the authorization as unauthorized" do
          status, data = subject

          expect(status).to eq(:unauthorized)
          expect(data[:fields]).to include("awesome_authorization_groups" => "Board members, Staff")
        end
      end
    end
  end
end
