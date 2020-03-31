# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  module Admin
    describe EditorImagesController, type: :controller do
      routes { Decidim::DecidimAwesome::AdminEngine.routes }

      let(:user) { create(:user, :confirmed, :admin, organization: organization) }
      let(:organization) { create(:organization) }
      let(:config) do
        {
          allow_images_in_full_editor: false,
          allow_images_in_small_editor: false
        }
      end
      let(:params) do
        {
          image: image,
          path: "/somepath"
        }
      end
      let(:image) { fixture_file_upload(Decidim::Dev.test_file("city.jpeg", "image/jpeg")) }

      before do
        request.env["decidim.current_organization"] = user.organization
        request.env["decidim_awesome.current_config"] = config
        sign_in user, scope: :user
      end

      describe "POST #create" do
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
      end
    end
  end
end
