# frozen_string_literal: true

require "spec_helper"

describe "Custom styles", type: :system do
  let(:organization) { create :organization }
  let!(:participatory_process) { create :participatory_process, organization: organization }
  let!(:config) { create :awesome_config, organization: organization, var: :scoped_styles, value: styles }
  let(:config_helper) { create :awesome_config, organization: organization, var: :scoped_style_bar }
  let(:styles) do
    {
      "bar" => "body {background: red;}"
    }
  end

  before do
    switch_to_host(organization.host)
    visit decidim.root_path
  end

  shared_examples "extra css is added" do
    it "css is present" do
      expect(page.body).to have_content("body {background: red;}")
    end

    it "css is applied" do
      expect(page.execute_script("return window.getComputedStyle($('body')[0]).backgroundColor")).to eq("rgb(255, 0, 0)")
    end
  end

  shared_examples "no extra css is added" do
    it "css is no present" do
      expect(page.body).not_to have_content("body {background: red;}")
    end

    it "css is not applyied" do
      expect(page.execute_script("return window.getComputedStyle($('body')[0]).backgroundColor")).to eq("rgb(250, 250, 250)")
    end
  end

  context "when there are custom styles" do
    it_behaves_like "extra css is added"
  end

  context "when there are empty css boxes" do
    let(:styles) do
      {}
    end

    it_behaves_like "no extra css is added"
  end

  context "when constraints are present" do
    let!(:constraint) { create(:config_constraint, awesome_config: config_helper, settings: settings) }
    let(:settings) do
      {}
    end

    before do
      visit decidim.root_path
    end

    context "when there are custom styles" do
      it_behaves_like "extra css is added"
    end

    context "and there are no custom styles" do
      let(:styles) do
        {}
      end

      it_behaves_like "no extra css is added"
    end

    context "and custom styles are scoped" do
      let(:settings) do
        { "participatory_space_manifest" => "participatory_processes" }
      end

      context "and page do not match the scope" do
        it_behaves_like "no extra css is added"
      end

      context "and page matches the scope" do
        before do
          click_link "Processes"
        end

        it_behaves_like "extra css is added"
      end
    end
  end
end
