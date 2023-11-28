# frozen_string_literal: true

require "spec_helper"

describe "Hacked menus" do
  let(:organization) { create(:organization) }
  let!(:participatory_process) { create(:participatory_process, organization:) }
  let!(:config) { create(:awesome_config, organization:, var: :menu, value: menu) }
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
    visit decidim_participatory_processes.participatory_processes_path
    find_by_id("main-dropdown-summary").hover
  end

  shared_examples "has active link" do |text|
    it "has only one active link" do
      within "#breadcrumb-main-dropdown-desktop .menu-bar__main-dropdown__menu" do
        expect(page).to have_css("li.active", count: 1)
      end
    end

    it "active link containts text" do
      within "#breadcrumb-main-dropdown-desktop .menu-bar__main-dropdown__menu .active" do

        expect(page).to have_content(text)
      end
    end
  end

  it "renders the hacked menu" do
    within "#breadcrumb-main-dropdown-desktop .menu-bar__main-dropdown__menu" do
      expect(page).not_to have_content("Home")
      expect(page).to have_content("Processes")
      expect(page).to have_content("Help")
      expect(page).to have_content("A new beggining")
      expect(page).to have_content("Blog")
    end
  end

  it "renders in the proper order" do
    within "#breadcrumb-main-dropdown-desktop .menu-bar__main-dropdown__menu li:nth-child(1)" do
      expect(page).to have_content("Processes")
    end
    within "#breadcrumb-main-dropdown-desktop .menu-bar__main-dropdown__menu li:nth-child(2)" do
      expect(page).to have_content("Help")
    end
    within "#breadcrumb-main-dropdown-desktop .menu-bar__main-dropdown__menu li:nth-child(3)" do
      expect(page).to have_content("Blog")
    end
    within "#breadcrumb-main-dropdown-desktop .menu-bar__main-dropdown__menu li:last-child" do
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
      expect(find("#breadcrumb-main-dropdown-desktop .menu-bar__main-dropdown__menu li:nth-child(3) a")["data-remote"]).to eq("true")
      expect(find("#breadcrumb-main-dropdown-desktop .menu-bar__main-dropdown__menu li:nth-child(3) a")[:target]).to eq("_blank")
      expect(find("#breadcrumb-main-dropdown-desktop .menu-bar__main-dropdown__menu li:last-child a")["data-remote"]).not_to eq("true")
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
        visibility:
      }
    end

    it "renders the item" do
      within "#breadcrumb-main-dropdown-desktop .menu-bar__main-dropdown__menu" do
        expect(page).to have_content("A new beggining")
      end
    end

    context "when hidden" do
      let(:visibility) { "hidden" }

      it "do not show the menu item" do
        within "#breadcrumb-main-dropdown-desktop .menu-bar__main-dropdown__menu" do
          expect(page).not_to have_content("A new beggining")
        end
      end
    end

    context "when logged" do
      let(:visibility) { "logged" }

      it "do not show the menu item" do
        within "#breadcrumb-main-dropdown-desktop .menu-bar__main-dropdown__menu" do
          expect(page).not_to have_content("A new beggining")
        end
      end
    end

    context "when non logged" do
      let(:visibility) { "non_logged" }

      it "do not show the menu item" do
        within "#breadcrumb-main-dropdown-desktop .menu-bar__main-dropdown__menu" do
          expect(page).to have_content("A new beggining")
        end
      end
    end

    context "when user is logged" do
      let!(:user) { create(:user, :confirmed, organization:) }

      before do
        switch_to_host(organization.host)
        login_as user, scope: :user
        visit decidim_participatory_processes.participatory_processes_path
        find_by_id("main-dropdown-summary").hover
      end

      context "when hidden" do
        let(:visibility) { "hidden" }

        it "do not show the menu item" do
          within "#breadcrumb-main-dropdown-desktop .menu-bar__main-dropdown__menu" do
            expect(page).not_to have_content("A new beggining")
          end
        end
      end

      context "when logged" do
        let(:visibility) { "logged" }

        it "do not show the menu item" do
          within "#breadcrumb-main-dropdown-desktop .menu-bar__main-dropdown__menu" do
            expect(page).to have_content("A new beggining")
          end
        end
      end

      context "when non logged" do
        let(:visibility) { "non_logged" }

        it "do not show the menu item" do
          within "#breadcrumb-main-dropdown-desktop .menu-bar__main-dropdown__menu" do
            expect(page).not_to have_content("A new beggining")
          end
        end
      end

      context "when only verified user", with_authorization_workflows: ["dummy_authorization_handler"] do
        let!(:authorization) { create(:authorization, granted_at: Time.zone.now, user:, name: "dummy_authorization_handler") }
        let(:visibility) { "verified_user" }

        before do
          switch_to_host(organization.host)
          login_as user, scope: :user
          visit decidim_participatory_processes.participatory_processes_path
          find_by_id("main-dropdown-summary").hover
        end

        context "when user is verified" do
          it "shows the item" do
            within "#breadcrumb-main-dropdown-desktop .menu-bar__main-dropdown__menu" do
              expect(page).to have_content("A new beggining")
            end
          end
        end

        context "when user is not verified" do
          let(:authorization) { nil }

          it "shows the item" do
            within "#breadcrumb-main-dropdown-desktop .menu-bar__main-dropdown__menu" do
              expect(page).not_to have_content("A new beggining")
            end
          end
        end

        context "when verification is expired" do
          let!(:authorization) { create(:authorization, granted_at: 3.months.ago, user:, name: "dummy_authorization_handler") }

          it "shows the item" do
            within "#breadcrumb-main-dropdown-desktop .menu-bar__main-dropdown__menu" do
              expect(page).not_to have_content("A new beggining")
            end
          end
        end
      end

      describe "active" do
        let!(:component) { create(:proposal_component, participatory_space: participatory_process) }
        let!(:participatory_process2) { create(:participatory_process, organization:) }
        let!(:component2) { create(:proposal_component, participatory_space: participatory_process2) }
        let(:menu) do
          [
            {
              url: "/processes",
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
            find_by_id("main-dropdown-summary").hover
          end

          it_behaves_like "has active link", "Processes"
        end

        context "when visiting a process in a custom link" do
          before do
            visit decidim_participatory_processes.participatory_process_path(participatory_process.slug)
            find_by_id("main-dropdown-summary").hover
          end

          it_behaves_like "has active link", "A single process"
        end

        context "when visiting a sublink of a process in a custom link" do
          before do
            visit main_component_path(component)
            find_by_id("main-dropdown-summary").hover
          end

          it_behaves_like "has active link", "A single process"
        end

        context "when visiting a process not in a custom link" do
          before do
            visit decidim_participatory_processes.participatory_process_path(participatory_process2.slug)
            find_by_id("main-dropdown-summary").hover
          end

          it_behaves_like "has active link", "Processes"
        end

        context "when visiting a sublink of a process not in a custom link" do
          before do
            visit main_component_path(component2)
            find_by_id("main-dropdown-summary").hover
          end

          it_behaves_like "has active link", "Processes"
        end
      end

      context "when menu is :disabled" do
        let(:disabled_features) { [:menu] }

        it "renders the normal menu" do
          within "#breadcrumb-main-dropdown-desktop .menu-bar__main-dropdown__menu" do
            expect(page).to have_content("Home")
            expect(page).to have_content("Processes")
            expect(page).to have_content("Help")
            expect(page).not_to have_content("A new beggining")
            expect(page).not_to have_content("Blog")
          end
        end

        it_behaves_like "has active link", "Processes"

        context "when visiting another page" do
          before do
            visit decidim.pages_path
            find_by_id("main-dropdown-summary").hover
          end

          it_behaves_like "has active link", "Help"
        end
      end
    end
  end
end
