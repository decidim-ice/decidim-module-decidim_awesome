# frozen_string_literal: true

require "spec_helper"

describe "Show awesome iframe", type: :system do
  include_context "with a component"
  let(:manifest_name) { "awesome_iframe" }

  let!(:user) { create :user, :confirmed, organization: organization }
  let(:settings) do
    {
      iframe: iframe,
      remove_margins: remove_margins,
      viewport_width: viewport_width
    }
  end

  let(:iframe) { '<iframe src="https://test.test"></iframe>' }
  let(:remove_margins) { false }
  let(:viewport_width) { false }

  before do
    component.update!(settings: settings)
    visit_component
  end

  it "shows the iframe wrapper" do
    within ".wrapper" do
      expect(page).to have_selector(".awesome-iframe")
    end
  end

  it "shows the iframe" do
    within ".awesome-iframe" do
      expect(page).to have_selector("iframe")
    end
  end

  context "when remove_margins is enabled" do
    let(:remove_margins) { true }

    it "removes the css margin" do
      expect(page).to have_selector(".wrapper")
    end
  end

  context "when viewport_width is enabled" do
    let(:viewport_width) { true }

    it "adds the .row class" do
      within ".wrapper" do
        expect(page).to have_selector(".awesome-iframe.row")
      end
    end
  end
end
