# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  module Admin
    describe ChecksController do
      routes { Decidim::DecidimAwesome::AdminEngine.routes }

      let(:user) { create(:user, :confirmed, :admin, organization:) }
      let(:organization) { create(:organization) }

      before do
        request.env["decidim.current_organization"] = user.organization
        sign_in user, scope: :user
      end

      shared_examples "valid decidim version" do
        it "is a valid Decidim version" do
          expect(controller.helpers.decidim_version_valid?).to be(true)
        end

        it "has a list of overrides" do
          expect(controller.helpers.overrides.count > 0).to be(true)
        end

        it "all overrides are valid" do
          skip "Fix this example after reenabling all overrides"

          controller.helpers.overrides.each do |_group, props|
            props.files.each do |file, _md5|
              expect(controller.helpers.valid?(props.spec, file)).not_to be_nil
            end
          end
        end
      end

      shared_examples "invalid decidim version" do
        it "is not a valid Decidim version" do
          expect(controller.helpers.decidim_version_valid?).to be(false)
        end

        it "has a list of overrides" do
          expect(controller.helpers.overrides.count > 0).to be(true)
        end
      end

      describe "GET #index" do
        it "returns http success" do
          get :index, params: {}
          expect(response).to have_http_status(:success)
        end

        it_behaves_like "valid decidim version"

        context "when other Decidim versions" do
          before do
            allow(Decidim).to receive(:version).and_return(version)
          end

          context "and is lower than supported" do
            let(:version) { "0.25.1" }

            it_behaves_like "invalid decidim version"
          end

          context "and is higher than supported" do
            let(:version) { "0.28" }

            it_behaves_like "invalid decidim version"
          end
        end
      end

      describe "GET #migrate_images" do
        it "returns http success" do
          post :migrate_images, params: {}
          expect(response).to have_http_status(:redirect)
        end
      end
    end
  end
end
