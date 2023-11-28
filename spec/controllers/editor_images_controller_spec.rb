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
        allow_images_in_small_editor: in_small,
        allow_images_in_full_editor: in_full,
        allow_images_in_markdown_editor: in_markdown
      }
    end
    let(:in_proposals) { true }
    let(:in_small) { true }
    let(:in_full) { true }
    let(:in_markdown) { true }
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

      context "when there's no file" do
        # TODO: remove nil when diching 0.26 support
        let(:image) { legacy_version? ? nil : upload_test_file(Decidim::Dev.test_file("invalid.jpeg", "image/jpeg")) }

        it "returns failure" do
          post(:create, params:)
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    describe "POST #create" do
      include_examples "uploads image"

      context "when all config vars are false" do
        let(:in_proposals) { false }
        let(:in_small) { false }
        let(:in_full) { false }
        let(:in_markdown) { false }

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
        let(:in_markdown) { false }

        it "returns no permissions" do
          post(:create, params:)
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end
end
