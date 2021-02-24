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
  let(:disabled_features) { [] }

  before do
    disabled_features.each do |feature|
      allow(Decidim::DecidimAwesome.config).to receive(feature).and_return(:disabled)
    end

    switch_to_host(organization.host)
    visit decidim.root_path
  end

  shared_examples "has active link" do |text|
    it "has only one active link" do
      within ".main-nav" do
        expect(page).to have_css(".main-nav__link--active", count: 1)
      end
    end

    it "active link containts text" do
      within ".main-nav .main-nav__link--active" do
        expect(page).to have_content(text)
      end
    end
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

  describe "active" do
    let!(:component) { create(:proposal_component, participatory_space: participatory_process) }
    let!(:participatory_process2) { create :participatory_process, organization: organization }
    let!(:component2) { create(:proposal_component, participatory_space: participatory_process2) }
    let(:menu) do
      [
        {
          url: "/",
          label: {
            "en" => "A new beggining"
          },
          position: 1
        },
        {
          url: "/processes/#{participatory_process.slug}",
          label: {
            "en" => "A single process"
          },
          position: 2
        }
      ]
    end

    it_behaves_like "has active link", "A new beggining"

    context "when visiting all processes list" do
      before do
        visit decidim_participatory_processes.participatory_processes_path
      end

      it_behaves_like "has active link", "Processes"
    end

    context "when visiting a process in a custom link" do
      before do
        visit decidim_participatory_processes.participatory_process_path(participatory_process.slug)
      end

      it_behaves_like "has active link", "A single process"
    end

    context "when visiting a sublink of a process in a custom link" do
      before do
        visit main_component_path(component)
      end

      it_behaves_like "has active link", "A single process"
    end

    context "when visiting a process not in a custom link" do
      before do
        visit decidim_participatory_processes.participatory_process_path(participatory_process2.slug)
      end

      it_behaves_like "has active link", "Processes"
    end

    context "when visiting a sublink of a process not in a custom link" do
      before do
        visit main_component_path(component2)
      end

      it_behaves_like "has active link", "Processes"
    end
  end

  context "when menu is :disabled" do
    let(:disabled_features) { [:menu] }

    it "renders the normal menu" do
      within ".main-nav" do
        expect(page).to have_content("Home")
        expect(page).to have_content("Processes")
        expect(page).to have_content("Help")
        expect(page).not_to have_content("A new beggining")
        expect(page).not_to have_content("Blog")
      end
    end

    it_behaves_like "has active link", "Home"

    context "when visiting another page" do
      before do
        visit decidim_participatory_processes.participatory_processes_path
      end

      it_behaves_like "has active link", "Processes"
    end
  end
end
