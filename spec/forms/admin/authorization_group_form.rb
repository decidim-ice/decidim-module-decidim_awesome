# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  module Admin
    describe AuthorizationGroupForm do
      subject { described_class.from_params(attributes).with_context(current_organization: organization) }

      let(:organization) { create(:organization) }
      let(:attributes) do
        {
          authorization_handlers:,
          authorization_handlers_names:,
          authorization_handlers_options:,
          force_authorization_help_text:
        }
      end

      let(:authorization_handlers) do
        {
          "dummy_authorization_handler" => {}
        }
      end

      let(:authorization_handlers_names) { ["dummy_authorization_handler"] }
      let(:authorization_handlers_options) { { "dummy_authorization_handler" => "some values" } }
      let(:force_authorization_help_text) do
        {
          "en" => "Help text in English",
          "ca" => "Text d'ajuda en català"
        }
      end

      context "when everything is OK" do
        it { is_expected.to be_valid }

        it "returns verification settings" do
          expect(subject.verification_settings).to eq(
            authorization_handlers: {
              "dummy_authorization_handler" => { options: "some values" }
            },
            force_authorization_help_text: {
              "en" => "Help text in English",
              "ca" => "Text d'ajuda en català"
            }
          )
        end

        context "when other parameters" do
          let(:force_authorization_help_text) do
            {}
          end

          it "returns updated verification settings" do
            expect(subject.verification_settings).to eq(
              authorization_handlers: {
                "dummy_authorization_handler" => { options: "some values" }
              },
              force_authorization_help_text: {}
            )
          end
        end
      end
    end
  end
end
