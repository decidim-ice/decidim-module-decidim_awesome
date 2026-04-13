# frozen_string_literal: true

require "spec_helper"

describe "Cookie management" do
  let(:organization) { create(:organization, available_locales: [:en]) }

  before do
    switch_to_host(organization.host)
    visit decidim.root_path
    click_link_or_button "Cookie settings"
  end

  it "shows the cookie settings modal" do
    expect(page).to have_css("#dc-modal-content")
    expect(page).to have_content("Cookie settings")
    expect(page).to have_content("Accept all")
    expect(page).to have_content("Save settings")
  end

  it "shows the default cookies if no editions are made" do
    expect(page).to have_content("Essential")
    expect(page).to have_content("Preferences")
    expect(page).to have_content("Analytics and statistics")
    expect(page).to have_content("Marketing")
  end

  it "shows the default cookie items if no editions are made" do
    find('[data-id="essential"]').click
    expect(page).to have_content("decidim-consent")
    expect(page).to have_content("_session_id")
    expect(page).to have_content("Stores information about the cookies allowed by the user on this website")
    expect(page).to have_content("Expiration")
  end

  it "allows accepting all cookies" do
    click_link_or_button "Accept all"
    expect(page).to have_no_css("#dc-modal-content")
  end

  it "allows saving custom cookie settings" do
    click_link_or_button "Save settings"
    expect(page).to have_no_css("#dc-modal-content")
  end

  context "when there are custom cookie categories" do
    let(:var_name) { :cookie_management }
    let!(:config) { create(:awesome_config, organization:, var: var_name, value: { galleta: { "slug" => "galleta", "title" => { "en" => "Galleta" }, "description" => { "en" => "We use galletas to improve your experience on our site." }, "mandatory" => false, "visibility" => "visible", "edited" => true, "items" => {} } }) }

    before do
      visit decidim.root_path
      click_link_or_button "Cookie settings"
    end

    it "shows the custom cookie category" do
      expect(page).to have_content("Galleta")
      find('[data-id="galleta"]').click
      expect(page).to have_content("We use galletas to improve your experience on our site.")
      expect(page).to have_content("galleta")
    end
  end
end
