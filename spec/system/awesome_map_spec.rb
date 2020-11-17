# frozen_string_literal: true

require "spec_helper"

describe "Show awesome map", type: :system do
  include_context "with a component"
  let(:manifest_name) { "awesome_map" }

  let!(:category) { create(:category, participatory_space: component.participatory_space) }
  let!(:subcategory) { create(:subcategory, parent: category, participatory_space: component.participatory_space) }
  let!(:user) { create :user, :confirmed, organization: organization }

  before do
    visit_component
  end

  it "shows the map" do
    within ".wrapper" do
      expect(page).to have_selector(".awesome-map")
      expect(page).to have_selector("#map")
    end
  end

  it "shows categories and colors" do
    within ".awesome-map" do
      expect(page.body).to have_content(".awesome_map-category_#{category.id}")
      expect(page.body).to have_content(".awesome_map-category_#{subcategory.id}")
    end
  end
end
