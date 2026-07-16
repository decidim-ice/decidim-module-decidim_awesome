# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  module Admin
    describe UpdateAwesomeAuthorizationProperties do
      subject { described_class.new(form) }

      let(:organization) { create(:organization) }
      let(:context) do
        {
          current_user: create(:user, organization:),
          current_organization: organization
        }
      end
      let(:locale) { organization.default_locale.to_s }
      let(:params) do
        {
          name: { locale => "Organization groups" },
          explanation: { locale => "Custom authorization description" }
        }
      end
      let(:form) do
        AwesomeAuthorizationPropertiesForm.from_params(params).with_context(context)
      end

      context "when valid" do
        it "broadcasts :ok and stores properties" do
          expect { subject.call }.to broadcast(:ok)

          expect(AwesomeConfig.find_by(organization:, var: :awesome_authorization_handler)&.value).to include(
            "name" => include(locale => "Organization groups"),
            "explanation" => include(locale => "Custom authorization description")
          )
        end
      end

      context "when empty values" do
        let(:params) do
          {
            name: { locale => "" },
            explanation: { locale => "" }
          }
        end

        let!(:config) do
          create(:awesome_config, organization:, var: :awesome_authorization_handler, value: { "name" => { locale => "Existing" } })
        end

        it "broadcasts :ok and removes existing config" do
          expect { subject.call }.to broadcast(:ok)
          expect(AwesomeConfig.find_by(organization:, var: :awesome_authorization_handler)).to be_nil
        end
      end

      context "when invalid" do
        let(:params) do
          {
            name: { locale => "Organization groups" },
            explanation: { locale => "a" * 1001 }
          }
        end

        it "broadcasts :invalid" do
          expect { subject.call }.to broadcast(:invalid)
          expect(AwesomeConfig.find_by(organization:, var: :awesome_authorization_handler)).to be_nil
        end
      end

      context "when name is too long" do
        let(:params) { { name: { locale => "a" * 256 }, explanation: { locale => "Custom authorization description" } } }

        it "broadcasts :invalid and stores nothing" do
          expect { subject.call }.to broadcast(:invalid)
          expect(AwesomeConfig.find_by(organization:, var: :awesome_authorization_handler)).to be_nil
        end
      end

      context "when the config cannot be saved" do
        before { allow(AwesomeConfig).to receive(:find_or_initialize_by).and_raise(ActiveRecord::RecordNotSaved.new("boom")) }

        it "broadcasts :invalid with the error message" do
          expect { subject.call }.to broadcast(:invalid, "boom")
        end
      end
    end
  end
end
