# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  describe EditorImagesController do
    routes { Decidim::DecidimAwesome::Engine.routes }

    let(:user) { create(:user, :confirmed, :admin, organization:) }
    let(:organization) { create(:organization) }
    let(:config) do
      {
        allow_images_in_proposals: in_proposals,
        allow_videos_in_editors: in_small,
        allow_images_in_editors: in_full
      }
    end
    let(:in_proposals) { true }
    let(:in_small) { true }
    let(:in_full) { true }
    let(:params) do
      {
        image:,
        path: "/somepath"
      }
    end
    let(:image) do
      Rack::Test::UploadedFile.new(
        Decidim::Dev.test_file("city.jpeg", "image/jpeg"),
        "image/jpeg"
      )
    end

    before do
      allow(controller).to receive(:awesome_config).and_return(config)
      request.env["decidim.current_organization"] = user.organization
      sign_in user, scope: :user
    end

    shared_examples "uploads image" do
      context "when everything is ok" do
        it "redirects as success success" do
          post(:create, params:)
          expect(response).to have_http_status(:success)
        end
      end

      context "when file is not valid" do
        let(:invalid_params) { { image: invalid_image } }
        let(:invalid_image) { upload_test_file(Decidim::Dev.test_file("Exampledocument.pdf", "application/pdf")) }

        it "does not create an editor image and returns an error message" do
          expect do
            post :create, params: invalid_params
          end.not_to(change(Decidim::EditorImage, :count))

          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.body).to include("Error uploading image")
        end
      end
    end

    describe "POST #create" do
      include_examples "uploads image"

      context "when all config vars are false" do
        let(:in_proposals) { false }
        let(:in_small) { false }
        let(:in_full) { false }

        it "returns no permissions" do
          post(:create, params:)
          expect(response).to have_http_status(:success)
        end
      end
    end

    context "when user is not admin" do
      let(:user) { create(:user, :confirmed, organization:) }

      include_examples "uploads image"

      context "when all config vars are false" do
        let(:in_proposals) { false }
        let(:in_small) { false }
        let(:in_full) { false }

        it "returns no permissions" do
          post(:create, params:)
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end
end
