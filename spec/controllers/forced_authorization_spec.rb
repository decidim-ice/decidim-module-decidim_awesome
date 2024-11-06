# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  class TestController < Decidim::ApplicationController
    def index
      render plain: "OK"
    end
  end

  describe ApplicationController do
    routes { Decidim::DecidimAwesome::Engine.routes }
    before do
      Decidim::DecidimAwesome::Engine.routes.draw do
        get "index" => "test#index"
      end
      allow(controller).to receive(:root_path).and_return("/")
      request.env["decidim.current_organization"] = organization
      sign_in user
    end

    let(:organization) { create(:organization, available_authorizations: ["dummy_authorization_handler"]) }
    let(:user) { create(:user, :confirmed, organization:) }
    let(:force_authorization_after_login) { %w(dummy_authorization_handler) }
    let!(:awesome_config) { create(:awesome_config, organization:, var: :force_authorization_after_login, value: force_authorization_after_login) }

    shared_examples "forbids access" do
      it "redirects to the required authorizations page" do
        get :index
        expect(response).to have_http_status(:found)
        expect(response).to redirect_to("/decidim_awesome#{required_authorizations_path(redirect_url: "/index")}")
      end
    end

    shared_examples "allows access" do
      it "allows the controller" do
        get :index
        expect(response).to have_http_status(:ok)
        expect(response.body).to eq("OK")
      end
    end

    shared_examples "redirects to login" do
      it "redirects to the login page" do
        get :index
        expect(response).to have_http_status(:found)
        expect(response).to redirect_to("/users/sign_in")
      end
    end

    shared_examples "handles authorization" do
      describe "GET #index" do
        context "when the user is not authorized" do
          it_behaves_like "forbids access"

          context "when the user is not logged in" do
            before do
              sign_out user
            end

            it_behaves_like "allows access"
          end

          context "when the user is blocked" do
            let(:user) { create(:user, :confirmed, :blocked, organization:) }

            it_behaves_like "allows access"
          end

          context "when the user is not confirmed" do
            let(:user) { create(:user, organization:) }

            it_behaves_like "redirects to login"
          end

          context "when the controller is allowed" do
            before do
              allow_any_instance_of(Decidim::DecidimAwesome::Config).to receive(:defaults).and_return({ force_authorization_allowed_controller_names: ["test"] }) # rubocop:disable RSpec/AnyInstance
            end

            it_behaves_like "allows access"
          end
        end

        context "when the user is authorized" do
          let!(:authorization) { create(:authorization, user:, name: "dummy_authorization_handler") }

          it_behaves_like "allows access"
        end
      end
    end

    describe TestController do
      it_behaves_like "handles authorization", :index
    end
  end
end
