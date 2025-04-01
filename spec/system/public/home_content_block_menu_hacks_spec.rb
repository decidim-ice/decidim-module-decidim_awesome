# frozen_string_literal: true

require "spec_helper"

describe "Hacked home content block menu" do
  let(:organization) { create(:organization) }
  let!(:participatory_process) { create(:participatory_process, organization:) }
  let!(:config) { create(:awesome_config, organization:, var: :home_content_block_menu, value: menu) }
  let(:menu) { [overridden, added] }
  let(:overridden) do
    {
      url: "/processes",
      label: {
        "en" => "Mastering projects"
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
  let!(:menu_content_block) { create(:content_block, organization:, manifest_name: :global_menu, scope_name: :homepage) }

  before do
    disabled_features.each do |feature|
      allow(Decidim::DecidimAwesome.config).to receive(feature).and_return(:disabled)
    end

    switch_to_host(organization.host)
    visit decidim.root_path
  end

  it "renders the hacked menu" do
    within "#home__menu" do
      expect(page).to have_no_content("Processes")
      expect(page).to have_content("Mastering projects")
      expect(page).to have_content("Blog")
    end
  end

  it "renders in the proper order" do
    within "#home__menu div.home__menu-element:nth-child(1)" do
      expect(page).to have_content("Blog")
    end
    within "#home__menu div.home__menu-element:last-child" do
      expect(page).to have_content("Mastering projects")
    end
  end

  describe "visibility" do
    let(:visibility) { "default" }
    let(:overriden) do
      {
        url: "/processes",
        label: {
          "en" => "Mastering projects"
        },
        position: 10,
        visibility:
      }
    end

    it "renders the item" do
      within "#home__menu" do
        expect(page).to have_content("Mastering projects")
      end
    end

    context "when hidden" do
      let(:visibility) { "hidden" }

      it "do not show the menu item" do
        within "#home__menu" do
          expect(page).to have_no_content("Mastering projects")
        end
      end
    end

    context "when logged" do
      let(:visibility) { "logged" }

      it "do not show the menu item" do
        within "#home__menu" do
          expect(page).to have_no_content("Mastering projects")
        end
      end
    end

    context "when non logged" do
      let(:visibility) { "non_logged" }

      it "do not show the menu item" do
        within "#home__menu" do
          expect(page).to have_content("Mastering projects")
        end
      end
    end

    context "when user is logged" do
      let!(:user) { create(:user, :confirmed, organization:) }

      before do
        switch_to_host(organization.host)
        login_as user, scope: :user
        visit decidim.root_path
      end

      context "when hidden" do
        let(:visibility) { "hidden" }

        it "do not show the menu item" do
          within "#home__menu" do
            expect(page).to have_no_content("Mastering projects")
          end
        end
      end

      context "when logged" do
        let(:visibility) { "logged" }

        it "do not show the menu item" do
          within "#home__menu" do
            expect(page).to have_content("Mastering projects")
          end
        end
      end

      context "when non logged" do
        let(:visibility) { "non_logged" }

        it "do not show the menu item" do
          within "#home__menu" do
            expect(page).to have_no_content("Mastering projects")
          end
        end
      end

      context "when only verified user", with_authorization_workflows: ["dummy_authorization_handler"] do
        let!(:authorization) { create(:authorization, granted_at: Time.zone.now, user:, name: "dummy_authorization_handler") }
        let(:visibility) { "verified_user" }

        before do
          switch_to_host(organization.host)
          login_as user, scope: :user
          visit decidim.root_path
        end

        context "when user is verified" do
          it "shows the item" do
            within "#home__menu" do
              expect(page).to have_content("Mastering projects")
            end
          end
        end

        context "when user is not verified" do
          let(:authorization) { nil }

          it "shows the item" do
            within "#home__menu" do
              expect(page).to have_no_content("Mastering projects")
            end
          end
        end

        context "when verification is expired" do
          let!(:authorization) { create(:authorization, granted_at: 3.months.ago, user:, name: "dummy_authorization_handler") }

          it "shows the item" do
            within "#home__menu" do
              expect(page).to have_no_content("Mastering projects")
            end
          end
        end
      end

      context "when menu is :disabled" do
        let(:disabled_features) { [:home_content_block_menu] }

        it "renders the normal menu" do
          within "#home__menu" do
            expect(page).to have_content("Processes")
            expect(page).to have_no_content("Mastering projects")
            expect(page).to have_no_content("Blog")
          end
        end
      end
    end
  end
end
