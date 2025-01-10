# frozen_string_literal: true

require "spec_helper"

module Decidim::System
  describe CreateOrganization do
    describe "call" do
      let(:form) do
        RegisterOrganizationForm.new(params)
      end
      let(:command) { described_class.new(form) }

      let(:available_authorizations) do
        [:example_authorization, :another_example_authorization]
      end
      let(:awesome_admins_available_authorizations) do
        []
      end

      let(:from_label) { "Decide Gotham" }
      let(:params) do
        {
          name: "Gotham City",
          host: "decide.example.org",
          secondary_hosts: "foo.example.org\r\n\r\nbar.example.org",
          reference_prefix: "JKR",
          organization_admin_name: "Fiorello Henry La Guardia",
          organization_admin_email: "f.laguardia@example.org",
          available_locales: ["en"],
          default_locale: "en",
          users_registration_mode: "enabled",
          force_users_to_authenticate_before_access_organization: "false",
          available_authorizations:,
          awesome_admins_available_authorizations:,
          file_upload_settings: {}
        }
      end

      it "creates an organization with no awesome vars" do
        expect { command.call }.to broadcast(:ok)
        organization = Decidim::Organization.last
        expect(translated(organization.name)).to eq("Gotham City")
        expect(organization.host).to eq("decide.example.org")
        expect(Decidim::DecidimAwesome::AwesomeConfig.count).to eq(0)
      end

      context "when authorizations are provided" do
        let(:awesome_admins_available_authorizations) do
          [:example_authorization]
        end

        it "creates an organization with awesome vars" do
          expect { command.call }.to broadcast(:ok)
          organization = Decidim::Organization.last
          expect(translated(organization.name)).to eq("Gotham City")
          expect(organization.host).to eq("decide.example.org")
          expect(Decidim::DecidimAwesome::AwesomeConfig.count).to eq(1)
          expect(Decidim::DecidimAwesome::AwesomeConfig.last.value).to eq(["example_authorization"])
        end
      end
    end
  end
end
