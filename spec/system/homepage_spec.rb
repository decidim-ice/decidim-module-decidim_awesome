# frozen_string_literal: true

require "spec_helper"
require "decidim/decidim_awesome/test/shared_examples/config_examples"

describe "Visit the home page", type: :system, perform_enqueued: true do
  let(:organization) { create :organization, available_locales: [:en] }

  before do
    switch_to_host(organization.host)
    visit decidim.root_path
  end

  it "renders the home page" do
    expect(page).to have_content("Home")
  end

  include_examples "javascript config vars"
end
