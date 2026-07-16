# frozen_string_literal: true

require "spec_helper"

module Decidim
  module DecidimAwesome
    module Admin
      describe AwesomeAuthorizationPropertiesController do
        routes { Decidim::DecidimAwesome::AdminEngine.routes }

        let(:user) { create(:user, :confirmed, :admin, organization:) }
        let(:organization) { create(:organization, available_authorizations: ["awesome_authorization_handler"]) }

        before do
          request.env["decidim.current_organization"] = user.organization
          sign_in user, scope: :user
        end

        describe "GET #index" do
          context "when awesome_authorization_handler is enabled" do
            before do
              allow(Decidim::DecidimAwesome.config).to receive(:awesome_authorization_handler).and_return(true)
            end

            it "returns http success" do
              get(:index)
              expect(response).to have_http_status(:success)
            end

            it "renders the index template" do
              get(:index)
              expect(subject).to render_template(:index)
            end

            context "when properties are already stored" do
              let(:locale) { organization.default_locale.to_s }

              before do
                create(:awesome_config, organization:, var: :awesome_authorization_handler,
                                        value: { "name" => { locale => "Existing name" }, "explanation" => { locale => "Existing explanation" }, "extra" => "ignored" })
              end

              it "prefills the form with the stored values" do
                get(:index)

                expect(assigns(:form).name[locale]).to eq("Existing name")
                expect(assigns(:form).explanation[locale]).to eq("Existing explanation")
              end
            end
          end

          context "when user is not admin" do
            let(:user) { create(:user, :confirmed, organization:) }

            it "redirects" do
              get(:index)
              expect(response).to have_http_status(:found)
            end
          end
        end

        describe "POST #create" do
          let(:locale) { organization.default_locale.to_s }
          let(:params) do
            {
              awesome_authorization_properties: {
                "name_#{locale}" => "Organization groups",
                "explanation_#{locale}" => "Custom authorization description"
              }
            }
          end

          context "with valid params" do
            it "redirects to awesome authorizations page" do
              post :create, params: params

              expect(response).to have_http_status(:found)
              expect(response).to redirect_to(awesome_authorizations_path)
            end

            it "stores the properties in awesome config" do
              post :create, params: params

              expect(AwesomeConfig.find_by(organization:, var: :awesome_authorization_handler)&.value).to include(
                {
                  "name" => include(locale => "Organization groups"),
                  "explanation" => include(locale => "Custom authorization description")
                }
              )
            end

            it "removes blank fields from the stored config" do
              create(:awesome_config, organization:, var: :awesome_authorization_handler, value: { "name" => { locale => "Existing" } })

              post :create, params: {
                awesome_authorization_properties: {
                  "name_#{locale}" => "",
                  "explanation_#{locale}" => ""
                }
              }

              expect(AwesomeConfig.find_by(organization:, var: :awesome_authorization_handler)).to be_nil
            end
          end

          context "with invalid params" do
            let(:params) do
              {
                awesome_authorization_properties: {
                  "name_#{locale}" => "Organization groups",
                  "explanation_#{locale}" => "a" * 1001
                }
              }
            end

            it "renders index with errors" do
              post :create, params: params

              expect(response).to have_http_status(:ok)
              expect(response).to render_template(:index)
            end

            it "does not store the config" do
              post :create, params: params

              expect(AwesomeConfig.find_by(organization:, var: :awesome_authorization_handler)).to be_nil
            end
          end
        end
      end
    end
  end
end
