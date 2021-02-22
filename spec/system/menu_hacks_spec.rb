# frozen_string_literal: true

require "spec_helper"

describe "Hacked menus", type: :system do
  let(:organization) { create :organization }
  let!(:participatory_process) { create :participatory_process, organization: organization }
  let!(:config) { create :awesome_config, organization: organization, var: :menu, value: menu }
  let(:menu) { [overriden, added] }
  let(:overriden) do
    {
      url: "/",
      label: {
        "en" => "A new beggining"
      },
      position: 10
    }
  end
  let(:added) do
    {
      url: "http://external.blog",
      label: {
        "en" => "Blog"
      },
      position: 9
    }
  end

  before do
    switch_to_host(organization.host)
    visit decidim.root_path
  end

  it "renders the hacked menu" do
    within ".main-nav" do
      expect(page).not_to have_content("Home")
      expect(page).to have_content("Processes")
      expect(page).to have_content("Help")
      expect(page).to have_content("A new beggining")
      expect(page).to have_content("Blog")
    end
  end

  it "renders in the proper order" do
    within ".main-nav li:nth-child(1)" do
      expect(page).to have_content("Processes")
    end
    within ".main-nav li:nth-child(2)" do
      expect(page).to have_content("Assemblies")
    end
    within ".main-nav li:nth-child(3)" do
      expect(page).to have_content("Help")
    end
    within ".main-nav li:nth-child(4)" do
      expect(page).to have_content("Blog")
    end
    within ".main-nav li:last-child" do
      expect(page).to have_content("A new beggining")
    end
  end

  context "when opens in a new window" do
    let(:added) do
      {
        url: "http://external.blog",
        label: {
          "en" => "Blog"
        },
        position: 9,
        target: "_blank"
      }
    end

    it "has target blank" do
      expect(find(".main-nav li:nth-child(4) a")[:class]).to include("external-link-container")
      expect(find(".main-nav li:nth-child(4) a")[:target]).to eq("_blank")
      expect(find(".main-nav li:last-child a")[:class]).not_to include("external-link-container")
    end
  end

  describe "visibility" do
    let(:visibility) { "default" }
    let(:overriden) do
      {
        url: "/",
        label: {
          "en" => "A new beggining"
        },
        position: 10,
        visibility: visibility
      }
    end

    it "renders the item" do
      within ".main-nav" do
        expect(page).to have_content("A new beggining")
      end
    end

    context "when hidden" do
      let(:visibility) { "hidden" }

      it "do not show the menu item" do
        within ".main-nav" do
          expect(page).not_to have_content("A new beggining")
        end
      end
    end

    context "when logged" do
      let(:visibility) { "logged" }

      it "do not show the menu item" do
        within ".main-nav" do
          expect(page).not_to have_content("A new beggining")
        end
      end
    end

    context "when non logged" do
      let(:visibility) { "non_logged" }

      it "do not show the menu item" do
        within ".main-nav" do
          expect(page).to have_content("A new beggining")
        end
      end
    end

    context "when user is logged" do
      let!(:user) { create(:user, :confirmed, organization: organization) }

      before do
        switch_to_host(organization.host)
        login_as user, scope: :user
        visit decidim.root_path
      end

      context "when hidden" do
        let(:visibility) { "hidden" }

        it "do not show the menu item" do
          within ".main-nav" do
            expect(page).not_to have_content("A new beggining")
          end
        end
      end

      context "when logged" do
        let(:visibility) { "logged" }

        it "do not show the menu item" do
          within ".main-nav" do
            expect(page).to have_content("A new beggining")
          end
        end
      end

      context "when non logged" do
        let(:visibility) { "non_logged" }

        it "do not show the menu item" do
          within ".main-nav" do
            expect(page).not_to have_content("A new beggining")
          end
        end
      end
    end
  end
end
