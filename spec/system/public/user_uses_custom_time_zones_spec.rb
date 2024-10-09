# frozen_string_literal: true

require "spec_helper"

describe "User uses custom time zones" do
  let(:organization) { create(:organization, time_zone:) }
  let(:user) { create(:user, :confirmed, organization:, extended_data:) }
  let(:component) { create(:meeting_component, :published, organization:) }
  let!(:meeting) { create(:meeting, :published, component:, start_time:) }
  let(:time_zone) { "Azores" }
  let(:extended_data) { { "some_variable" => "Some value" } }
  let(:enable_user_time_zone) { true }
  let(:start_time) { Date.current + 29.hours }

  before do
    allow(Decidim::DecidimAwesome.config).to receive(:[]).and_call_original
    allow(Decidim::DecidimAwesome.config).to receive(:[]).with(:user_timezone).and_return(enable_user_time_zone)
    allow(Decidim::DecidimAwesome.config).to receive(:to_h).and_return(Decidim::DecidimAwesome.config.to_h.merge({ user_timezone: enable_user_time_zone }))

    allow(Decidim::DecidimAwesome).to receive(:user_timezone).and_return(enable_user_time_zone)
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim.meetings_directory_path
  end

  it "allows to change the time zone" do
    within ".card__list-metadata" do
      expect(page).to have_content("05:00 AM +00")
    end
    visit decidim.account_path
    expect(page).to have_select("user_user_time_zone", selected: "(GMT-01:00) Azores")
    fill_in "Your name", with: "John Willson"
    select "(GMT-10:00) Hawaii", from: "user_user_time_zone"
    click_button "Update account"
    expect(page).to have_content("Your account was successfully updated.")
    expect(page).to have_select("user_user_time_zone", selected: "(GMT-10:00) Hawaii")
    visit decidim.meetings_directory_path
    within ".card__list-metadata" do
      expect(page).to have_content("19:00 PM HST")
    end
    expect(user.reload.name).to eq("John Willson")
    expect(user.extended_data["some_variable"]).to eq("Some value")
    expect(user.extended_data["time_zone"]).to eq("Hawaii")
  end

  context "when the user time zone is disabled" do
    let(:enable_user_time_zone) { false }
    let(:extended_data) { { "user_timezone" => "Hawaii" } }

    it "does not allow to change the time zone" do
      within ".card__list-metadata" do
        expect(page).to have_content("05:00 AM +00")
      end
      visit decidim.account_path
      expect(page).not_to have_select("user_user_time_zone")
      fill_in "Your name", with: "John Willson"
      click_button "Update account"
      expect(user.reload.name).to eq("John Willson")
    end
  end
end
