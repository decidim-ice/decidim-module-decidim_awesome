# frozen_string_literal: true

require "spec_helper"

module Decidim
  module System
    describe UpdateOrganization do
      let(:form) do
        UpdateOrganizationForm.new(params)
      end
      let(:organization) { create(:organization, name: { en: "My organization" }) }
      let(:available_authorizations) do
        [:example_authorization, :another_example_authorization]
      end
      let(:awesome_admins_available_authorizations) do
        []
      end

      let(:command) { described_class.new(organization.id, form) }

      let(:from_label) { "Decide Gotham" }
      let(:params) do
        {
          name: "Gotham City",
          host: "decide.example.org",
          secondary_hosts: "foo.example.org\r\n\r\nbar.example.org",
          force_users_to_authenticate_before_access_organization: false,
          users_registration_mode: "existing",
          available_authorizations:,
          awesome_admins_available_authorizations:,
          file_upload_settings: {}
        }
      end

      it "updates the organization with no awesome vars" do
        expect { command.call }.to broadcast(:ok)
        organization = Decidim::Organization.last
        expect(organization.host).to eq("decide.example.org")
        expect(Decidim::DecidimAwesome::AwesomeConfig.count).to eq(0)
      end

      context "when authorizations are provided" do
        let(:awesome_admins_available_authorizations) do
          [:example_authorization]
        end

        it "updates organization with awesome vars" do
          expect { command.call }.to broadcast(:ok)
          organization = Decidim::Organization.last
          expect(organization.host).to eq("decide.example.org")
          expect(Decidim::DecidimAwesome::AwesomeConfig.count).to eq(1)
          expect(Decidim::DecidimAwesome::AwesomeConfig.last.value).to eq(["example_authorization"])
        end
      end
    end
  end
end
