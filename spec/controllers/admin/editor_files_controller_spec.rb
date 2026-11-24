# frozen_string_literal: true

require "spec_helper"
require "decidim/decidim_awesome/test/shared_examples/html_code_editor_examples"

module Decidim::DecidimAwesome
  module Admin
    describe EditorFilesController do
      routes { Decidim::DecidimAwesome::AdminEngine.routes }

      let(:organization) { create(:organization, file_upload_settings:) }
      let(:file_upload_settings) { Decidim::OrganizationSettings.default(:upload) }
      let(:user) { create(:user, :confirmed, :admin, organization:) }
      let!(:html_code_editor) { create(:awesome_config, organization:, var: :html_code_editor, value: enabled) }
      let(:enabled) { true }
      let(:allowed_mime) { %w(image/jpeg image/png) }
      let(:file) { Decidim::Dev.test_file("city.jpeg", "image/jpeg") }
      let(:pdf) { Decidim::Dev.test_file("Exampledocument.pdf", "application/pdf") }
      let(:action) { post :create, params: { file: }, xhr: true }

      before do
        allow(Decidim::DecidimAwesome).to receive(:html_code_editor_allowed_mime).and_return(allowed_mime)
        request.env["decidim.current_organization"] = organization
        sign_in user, scope: :user
      end

      shared_examples "stores the file" do |content_type|
        it "returns the file address" do
          expect { action }.to change(EditorFile, :count).by(1)

          expect(response).to have_http_status(:success)
          expect(response.parsed_body["url"]).to include("/rails/active_storage/")
          expect(response.parsed_body["content_type"]).to eq(content_type)
        end
      end

      shared_examples "rejects the file" do
        it "returns the reason" do
          expect { action }.not_to change(EditorFile, :count)

          expect(response).to have_http_status(:unprocessable_content)
          expect(response.parsed_body["message"]).to be_present
        end
      end

      it_behaves_like "stores the file", "image/jpeg"
      it_behaves_like "needs the HTML code editor"

      context "when the content type is not in the list" do
        let(:file) { pdf }

        it_behaves_like "rejects the file"
      end

      context "when the content type is added to the list" do
        let(:allowed_mime) { %w(image/jpeg application/pdf) }
        let(:file) { pdf }

        it_behaves_like "stores the file", "application/pdf"

        context "and the organization does not accept it from admins" do
          let(:file_upload_settings) { Decidim::OrganizationSettings.default(:upload).deep_merge("allowed_content_types" => { "admin" => %w(image/*) }) }

          it_behaves_like "rejects the file"
        end
      end

      context "when the file pretends to be an image" do
        let(:file) { Rack::Test::UploadedFile.new(Decidim::Dev.asset("Exampledocument.pdf"), "image/jpeg", original_filename: "city.jpeg") }

        it_behaves_like "rejects the file"
      end

      context "when the list is empty" do
        let(:allowed_mime) { [] }

        it_behaves_like "rejects the file"
      end

      context "when there is no file" do
        let(:file) { nil }

        it_behaves_like "rejects the file"
      end
    end
  end
end
