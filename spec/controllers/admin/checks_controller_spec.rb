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
            let(:version) { "0.29" }

            it_behaves_like "invalid decidim version"
          end
        end
      end

      describe "awesome version checking" do
        let(:current_version) { "0.14.1" }
        let(:github_releases) do
          [
            { "tag_name" => "v0.14.2", "draft" => false, "prerelease" => false },
            { "tag_name" => "v0.14.1", "draft" => false, "prerelease" => false },
            { "tag_name" => "v0.13.5", "draft" => false, "prerelease" => false }
          ]
        end

        before do
          allow(Rails.cache).to receive(:fetch).and_call_original
          allow(Rails.cache).to receive(:fetch).with("decidim_awesome_latest_version", expires_in: 1.hour).and_yield
        end

        describe "#awesome_version" do
          it "returns the current version" do
            expect(controller.helpers.awesome_version).to eq(Decidim::DecidimAwesome::VERSION)
          end
        end

        describe "#awesome_latest_version" do
          context "when GitHub API returns releases" do
            let(:faraday_response) { double(success?: true, body: github_releases.to_json) }

            before do
              allow(Faraday).to receive(:get).with("https://api.github.com/repos/decidim-ice/decidim-module-decidim_awesome/releases")
                                             .and_return(faraday_response)
            end

            it "returns the latest version for the current minor" do
              expect(controller.helpers.awesome_latest_version).to eq("0.14.2")
            end

            it "filters out drafts and prereleases" do
              releases_with_draft = github_releases + [{ "tag_name" => "v0.14.3", "draft" => true, "prerelease" => false }]
              allow(faraday_response).to receive(:body).and_return(releases_with_draft.to_json)

              expect(controller.helpers.awesome_latest_version).to eq("0.14.2")
            end

            it "only checks current minor version" do
              releases_with_newer_minor = [{ "tag_name" => "v0.15.0", "draft" => false, "prerelease" => false }] + github_releases
              allow(faraday_response).to receive(:body).and_return(releases_with_newer_minor.to_json)

              expect(controller.helpers.awesome_latest_version).to eq("0.14.2")
            end
          end

          context "when GitHub API fails" do
            let(:faraday_response) { double(success?: false) }

            before do
              allow(Faraday).to receive(:get).and_return(faraday_response)
            end

            it "returns nil" do
              expect(controller.helpers.awesome_latest_version).to be_nil
            end
          end

          context "when an error occurs" do
            before do
              allow(Faraday).to receive(:get).and_raise(StandardError.new("Network error"))
              allow(Rails.logger).to receive(:error)
            end

            it "returns nil" do
              expect(controller.helpers.awesome_latest_version).to be_nil
            end

            it "logs the error" do
              controller.helpers.awesome_latest_version
              expect(Rails.logger).to have_received(:error).with(/Failed to fetch latest Decidim Awesome version/)
            end
          end
        end

        describe "#awesome_version_outdated?" do
          context "when latest version is available" do
            before do
              allow(controller.helpers).to receive(:awesome_latest_version).and_return("0.14.2")
            end

            it "returns true when current version is older" do
              expect(controller.helpers.awesome_version_outdated?).to be(true)
            end
          end

          context "when on latest version" do
            before do
              allow(controller.helpers).to receive(:awesome_latest_version).and_return(Decidim::DecidimAwesome::VERSION)
            end

            it "returns false" do
              expect(controller.helpers.awesome_version_outdated?).to be(false)
            end
          end

          context "when latest version cannot be determined" do
            before do
              allow(controller.helpers).to receive(:awesome_latest_version).and_return(nil)
            end

            it "returns false" do
              expect(controller.helpers.awesome_version_outdated?).to be(false)
            end
          end
        end
      end
    end
  end
end
