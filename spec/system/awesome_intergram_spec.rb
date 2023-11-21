# frozen_string_literal: true

require "spec_helper"

describe "Show intergram chat", type: :system do
  let!(:user) { create :user, :confirmed, organization: organization }
  let(:organization) { create :organization, available_locales: [:en] }

  let(:intergram_url) { "http://example.com/widget.js" }
  let(:intergram_for_admins) { true }
  let(:intergram_for_public) { true }
  let(:require_login) { false }
  let!(:config_public) { create(:awesome_config, organization: organization, var: :intergram_for_public, value: intergram_for_public) }
  let!(:config_admins) { create(:awesome_config, organization: organization, var: :intergram_for_admins, value: intergram_for_admins) }
  let!(:config_public_settings) { create(:awesome_config, organization: organization, var: :intergram_for_public_settings, value: settings) }
  let!(:config_admins_settings) { create(:awesome_config, organization: organization, var: :intergram_for_admins_settings, value: settings) }
  let(:settings) do
    {
      chat_id: "some-id",
      require_login: require_login,
      color: "some-color",
      use_floating_button: true,
      title_closed: "title-closed",
      title_open: "title-open",
      intro_message: "intro-message",
      auto_response: "auto-response",
      auto_no_response: "auto-no-response"
    }
  end

  before do
    stub_request(:get, /example\.com/).to_return(status: 200, body: "")
    Decidim::DecidimAwesome.config.intergram_url = intergram_url

    switch_to_host(organization.host)
    visit decidim.root_path
  end

  shared_examples "shows the chat" do |logged|
    it "has the script tag" do
      expect(page).to have_xpath("//script[@src='#{intergram_url}']", visible: :all)
    end

    it "has customized variables" do
      expect(page.body).to have_content('window.intergramId = "some-id";')
    end

    it "variables have been initialized" do
      expect(page.execute_script("return window.intergramId")).to eq("some-id")
      expect(page.execute_script("return window.intergramCustomizations.titleClosed")).to eq(settings[:title_closed])
      expect(page.execute_script("return window.intergramCustomizations.titleOpen")).to eq(settings[:title_open])
      expect(page.execute_script("return window.intergramCustomizations.introMessage")).to eq(settings[:intro_message])
      expect(page.execute_script("return window.intergramCustomizations.autoResponse")).to eq(settings[:auto_response])
      expect(page.execute_script("return window.intergramCustomizations.autoNoResponse")).to eq(settings[:auto_no_response])
    end

    it "sets visitor name" do
      if logged
        expect(page.execute_script("return window.intergramOnOpen.visitorName")).to eq(user.nickname)
      else
        expect(page.execute_script("return window.intergramOnOpen.visitorName")).to eq("")
      end
    end
  end

  shared_examples "do not show the chat" do
    it "do not have the script tag" do
      expect(page).not_to have_xpath("//script[@src='#{intergram_url}']", visible: :all)
    end

    it "has no customized variables" do
      expect(page.body).not_to have_content('window.intergramId = "some-id";')
    end

    it "no variables are initialized" do
      expect(page.execute_script("return window.intergramId")).to be_nil
    end
  end

  it_behaves_like "shows the chat", false

  if legacy_version?
    it "has the script tag in the head" do
      expect(page).to have_xpath("//head/script[@src='#{intergram_url}']", visible: :all)
    end
  else
    it "has the script tag in the body" do
      expect(page).to have_xpath("//body/script[@src='#{intergram_url}']", visible: :all)
    end
  end

  context "when login is required" do
    let(:require_login) { true }

    it_behaves_like "do not show the chat"

    context "and user is logged in" do
      before do
        login_as user, scope: :user
        visit decidim.root_path
      end

      it_behaves_like "shows the chat", true
    end
  end

  context "when public chat is disabled" do
    let(:intergram_for_public) { false }

    it_behaves_like "do not show the chat"

    context "and user is logged in" do
      before do
        login_as user, scope: :user
        visit decidim.root_path
      end

      it_behaves_like "do not show the chat"
    end
  end

  context "when is and admin" do
    let!(:user) { create(:user, :admin, :confirmed, organization: organization) }

    before do
      login_as user, scope: :user
      visit decidim_admin.root_path
    end

    it_behaves_like "shows the chat", true
    it "has the script tag in the head" do
      expect(page).to have_xpath("//head/script[@src='#{intergram_url}']", visible: :all)
    end

    context "and admin chat is disabled" do
      let(:intergram_for_admins) { false }

      it_behaves_like "do not show the chat"
    end
  end
end
