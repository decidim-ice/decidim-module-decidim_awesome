# frozen_string_literal: true

require "spec_helper"
require "decidim/decidim_awesome/test/shared_examples/html_code_editor_examples"

module Decidim::DecidimAwesome
  module Admin
    describe EditorPreviewsController do
      render_views
      routes { Decidim::DecidimAwesome::AdminEngine.routes }

      let(:organization) { create(:organization) }
      let(:user) { create(:user, :confirmed, :admin, organization:) }
      let!(:html_code_editor) { create(:awesome_config, organization:, var: :html_code_editor, value: enabled) }
      let(:enabled) { true }
      let(:action) { post :create, params: { content: "<style>.hero { color: red; }</style><figure>A caption</figure><script>alert(1)</script>" }, xhr: true }

      before do
        request.env["decidim.current_organization"] = organization
        sign_in user, scope: :user
      end

      it "renders the content without the tags that are not allowed" do
        action

        expect(response).to have_http_status(:success)
        expect(response.body).to include("<style>.hero { color: red; }</style>", "A caption")
        expect(response.body).not_to include("<figure>", "<script>")
      end

      it_behaves_like "needs the HTML code editor"
    end
  end
end
