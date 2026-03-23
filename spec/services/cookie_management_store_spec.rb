# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  describe CookieManagementStore do
    let(:available_locales) { %w(en ca pt-BR) }
    let(:organization) { create(:organization, available_locales:) }

    before do
      allow(Decidim).to receive(:available_locales).and_return available_locales
      allow(I18n.config).to receive(:enforce_available_locales).and_return(false)
    end

    describe "#categories" do
      it "merges the config categories with the Decidim defaults" do
        config = {
          "essential" => {
            "slug" => "essential",
            "mandatory" => false,
            "visibility" => "visible",
            "title" => { "en" => "Essential edited", "ca" => "Essencials", "pt-BR" => "Essenciais editado" },
            "description" => { "en" => "Description for essential category", "ca" => "Descripció de la categoria essencial", "pt-BR" => "Descrição da categoria essencial" }
          },
          "custom-category" => {
            "slug" => "custom-category",
            "mandatory" => false,
            "visibility" => "hidden",
            "title" => { "en" => "Custom Category", "ca" => "Categoria Personalitzada", "pt-BR" => "Categoria Personalizada" },
            "description" => { "en" => "Description for custom category", "ca" => "Descripció de la categoria personalitzada", "pt-BR" => "Descrição da categoria personalizada" }
          }
        }
        store = CookieManagementStore.new(organization, config)

        expect(store.categories).to include("essential")
        expect(store.categories["essential"]["title"]["en"]).to eq("Essential edited")
        expect(store.categories["essential"]["title"]["pt-BR"]).to eq("Essenciais editado")
        expect(store.categories["essential"]["mandatory"]).to be_blank
        expect(store.categories["essential"]["visibility"]).to eq("visible")
        expect(store.categories["essential"]["blocked"]).to be_truthy
        expect(store.categories["essential"]["default"]).to be_truthy

        expect(store.categories).to include("custom-category")
        expect(store.categories["custom-category"]["title"]["en"]).to eq("Custom Category")
        expect(store.categories["custom-category"]["description"]["pt-BR"]).to eq("Descrição da categoria personalizada")
        expect(store.categories["custom-category"]["visibility"]).to eq("hidden")
        expect(store.categories["custom-category"]["mandatory"]).to be_blank
        expect(store.categories["custom-category"]["blocked"]).to be_blank
        expect(store.categories["custom-category"]["default"]).to be_blank
      end

      it "returns Decidim defaults if no config is provided" do
        organization = create(:organization, available_locales: [:en])
        allow(Decidim).to receive(:consent_categories).and_return([
                                                                    { slug: :analytics, mandatory: true, items: [{ name: :google_analytics, type: :cookie }] }
                                                                  ])
        store = CookieManagementStore.new(organization)

        expect(store.categories).to have_key("analytics")
        expect(store.categories["analytics"]["items"]).to have_key("google_analytics")
      end
    end
  end
end
