# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  describe EditorImagesController, type: :controller do
    routes { Decidim::DecidimAwesome::Engine.routes }

    let(:user) { create(:user, :confirmed, :admin, organization: organization) }
    let(:organization) { create(:organization) }
    let(:config) do
      {}
    end
    let(:params) do
      {
        image: image,
        path: "/somepath"
      }
    end
    let(:image) { fixture_file_upload(Decidim::Dev.test_file("city.jpeg", "image/jpeg")) }

    before do
      allow(controller).to receive(:awesome_config).and_return(config)
      request.env["decidim.current_organization"] = user.organization
      request.env["decidim_awesome.current_config"] = config
      sign_in user, scope: :user
    end

    shared_examples "uploads image" do |config_var|
      let(:config) do
        {
          config_var => true
        }
      end

      context "when everything is ok" do
        it "redirects as success success" do
          get :create, params: params
          expect(response).to have_http_status(:success)
        end
      end

      context "when there's no file" do
        let(:image) { nil }

        it "returns failure" do
          get :create, params: params
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context "when #{config_var} is false" do
        let(:config) do
          {
            config_var => false
          }
        end

        it "returns no permissions" do
          get :create, params: params
          expect(response).to have_http_status(:redirect)
        end
      end
    end

    describe "POST #create" do
      include_examples "uploads image", :allow_images_in_small_editor
      include_examples "uploads image", :allow_images_in_full_editor
    end

    context "when user is not admin" do
      let(:user) { create(:user, :confirmed, organization: organization) }

      include_examples "uploads image", :allow_images_in_proposals
    end
  end
end
