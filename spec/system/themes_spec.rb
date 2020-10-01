# frozen_string_literal: true

require "spec_helper"

describe "Visit the home page", type: :system do
  let(:organization) { create :organization, host: hostname }
  let(:organization2) { create :organization, host: "another.lvh.me" }

  shared_examples "themes are included in the tenant" do
    context "when visiting organization with a theme" do
      before do
        switch_to_host(organization.host)
        visit decidim.root_path
      end

      it "adds the css link" do
        expect(page).to have_xpath("//link[contains(@href, '/assets/#{hostname}')]", visible: :all)
      end

      it "applies the style" do
        expect(page.execute_script("return window.getComputedStyle($('body')[0]).backgroundColor")).to eq("rgb(1, 2, 3)")
      end
    end

    context "when visiting organization without a theme" do
      before do
        switch_to_host(organization2.host)
        visit decidim.root_path
      end

      it "do not add the css link" do
        expect(page).not_to have_xpath("//link[contains(@href, '/assets/#{hostname}')]", visible: :all)
      end

      it "do not apply the style" do
        expect(page.execute_script("return window.getComputedStyle($('body')[0]).backgroundColor")).not_to eq("rgb(1, 2, 3)")
      end
    end
  end

  context "when using a css stylesheet" do
    let(:hostname) { "css.lvh.me" }

    it_behaves_like "themes are included in the tenant"
  end

  context "when using a scss stylesheet" do
    let(:hostname) { "scss.lvh.me" }

    it_behaves_like "themes are included in the tenant"
  end

  context "when using a scss.erb stylesheet" do
    let(:hostname) { "erb.lvh.me" }

    it_behaves_like "themes are included in the tenant"
  end
end
