# frozen_string_literal: true

require "spec_helper"
require "decidim/decidim_awesome/test/shared_examples/editor_examples"

describe "Admin edits proposals" do
  let(:organization) { create(:organization, available_locales: [:en]) }
  let!(:user) { create(:user, :admin, :confirmed, organization:) }
  let(:date) { Time.current }
  let!(:stamp) { ActiveHashcash::Stamp.create!(ip_address: "10.0.0.1", request_path: "/users/sign_in", counter: "123", rand: "asdf", resource: "localhost", bits: 20, date:, ext: "", version: 1) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_decidim_awesome.config_path(:surveys)
  end

  it "has hashcash disabled" do
    expect(page).to have_unchecked_field("Enable the Hashcash bot protection for new users (sign up)")
    expect(page).to have_unchecked_field("Enable the Hashcash bot protection for existing users (login)")
  end

  it "has a maintenance menu" do
    click_on "Hashcash stamps"

    expect(page).to have_content("Maintenance tools: Hashcash stamps")
    within ".table-list" do
      expect(page).to have_content("Created at")
      expect(page).to have_content("IP address")
      expect(page).to have_content("Request path")
      expect(page).to have_content("Bits")
      expect(page).to have_content(date.strftime("%Y-%m-%d %H:%M"))
      expect(page).to have_content("10.0.0.1")
      expect(page).to have_content("/users/sign_in")
      expect(page).to have_content("20")

      click_on date.strftime("%Y-%m-%d %H:%M")
    end

    expect(page).to have_content("Created at")
    expect(page).to have_content("IP address")
    expect(page).to have_content("Request path")
    expect(page).to have_content("Bits")
    expect(page).to have_content("Resource")
    expect(page).to have_content("Context")
  end

  it "has a IP address list" do
    click_on "Hashcash stamps"
    click_on "View IP addresses"

    within ".table-list" do
      expect(page).to have_content("IP address")
      expect(page).to have_content("Hashcash stamps")
      expect(page).to have_content("10.0.0.1")
      expect(page).to have_content("1")
      click_on "10.0.0.1"
    end

    expect(page).to have_content(date.strftime("%Y-%m-%d %H:%M"))
  end
end
