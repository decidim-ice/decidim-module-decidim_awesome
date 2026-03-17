# frozen_string_literal: true

require "spec_helper"

describe "Rich Text content block on homepage" do
  let(:organization) { create(:organization) }
  let!(:content_block) { create(:content_block, organization:, manifest_name: :awesome_rich_text, scope_name: :homepage, settings:) }
  let(:settings) { { "title" => { "en" => "Welcome Section" }, "columns" => columns_data } }
  let(:columns_data) { [{ "body" => { "en" => "<p>Hello from the homepage</p>" } }] }

  before do
    switch_to_host(organization.host)
  end

  it "displays a single column with a title" do
    visit decidim.root_path
    expect(page).to have_content("Welcome Section")
    expect(page).to have_content("Hello from the homepage")
  end

  context "with multiple columns" do
    let(:columns_data) do
      [
        { "body" => { "en" => "<p>Column one</p>" } },
        { "body" => { "en" => "<p>Column two</p>" } },
        { "body" => { "en" => "<p>Column three</p>" } }
      ]
    end

    it "renders all columns" do
      visit decidim.root_path
      expect(page).to have_content("Column one")
      expect(page).to have_content("Column two")
      expect(page).to have_content("Column three")
    end
  end

  context "when title is not set" do
    let(:settings) { { "columns" => columns_data } }

    it "does not display a heading" do
      visit decidim.root_path
      expect(page).to have_no_content("Welcome Section")
      expect(page).to have_content("Hello from the homepage")
    end
  end

  context "when all columns are empty" do
    let(:columns_data) { [{ "body" => { "en" => "" } }] }

    it "does not render the section" do
      visit decidim.root_path
      expect(page).to have_no_css("#awesome-rich-text-#{content_block.id}")
    end
  end

  context "with restrict_videos" do
    let(:columns_data) { [{ "body" => { "en" => '<p>Watch:</p><iframe src="http://example.com/video"></iframe>' }, "restrict_videos" => true }] }

    context "when not logged in" do
      it "shows login button instead of video" do
        visit decidim.root_path
        expect(page).to have_no_css("iframe")
        expect(page).to have_content("Sign in to watch this video")
      end
    end

    context "when logged in" do
      let!(:user) { create(:user, :confirmed, organization:) }

      it "does not show login placeholder" do
        login_as user, scope: :user
        visit decidim.root_path
        expect(page).to have_no_content("Sign in to watch this video")
      end
    end
  end

  context "with restrict_links" do
    let(:columns_data) { [{ "body" => { "en" => '<p>Click <a href="http://example.com">here</a></p>' }, "restrict_links" => true }] }

    context "when not logged in" do
      it "shows links without href" do
        visit decidim.root_path
        expect(page).to have_content("here")
        expect(page).to have_no_link("here", href: "http://example.com")
      end
    end

    context "when logged in" do
      let!(:user) { create(:user, :confirmed, organization:) }

      it "shows full links" do
        login_as user, scope: :user
        visit decidim.root_path
        expect(page).to have_link("here", href: "http://example.com")
      end
    end
  end
end
