# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  describe UtilsController do
    routes { Decidim::DecidimAwesome::Engine.routes }

    let(:organization) { create(:organization) }

    before do
      request.env["decidim.current_organization"] = organization
    end

    describe "#form_builder_i18n" do
      let(:lang) { "ca-ES" }
      let(:file_path) { Decidim::DecidimAwesome::Engine.root.join("app/packs/src/vendor/form_builder_langs/ca-ES.lang") }

      it "renders the form builder i18n file" do
        get :form_builder_i18n, params: { locale: lang }
        expect(response).to have_http_status(:ok)
        expect(response.body).to eq(File.read(file_path))
      end

      context "when locale is simple" do
        let(:lang) { "ca/ca.lang" }

        it "renders the form builder i18n file" do
          get :form_builder_i18n, params: { locale: lang }
          expect(response).to have_http_status(:ok)
          expect(response.body).to eq(File.read(file_path))
        end
      end

      context "when the file does not exist" do
        let(:lang) { "nonexistent" }

        it "renders the default file" do
          get :form_builder_i18n, params: { locale: lang }
          expect(response).to have_http_status(:ok)
          expect(response.body).to eq(File.read(Decidim::DecidimAwesome::Engine.root.join("app/packs/src/vendor/form_builder_langs/en-US.lang")))
        end
      end
    end
  end
end
