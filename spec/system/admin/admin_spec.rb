# frozen_string_literal: true

require "spec_helper"
require "decidim/decidim_awesome/test/shared_examples/config_examples"

describe "Visit the admin page" do
  let(:organization) { create(:organization, rich_text_editor_in_public_views: rte_enabled) }
  let!(:admin) { create(:user, :admin, :confirmed, organization: organization) }
  let(:rte_enabled) { true }
  let(:disabled_features) { [] }
  let(:version_original) { Decidim.version }
  let(:version) { version_original }

  before do
    allow(Decidim).to receive(:version).and_return(version)
    disabled_features.each do |feature|
      allow(Decidim::DecidimAwesome.config).to receive(feature).and_return(:disabled)
    end
    Decidim::MenuRegistry.destroy(:awesome_admin_menu)
    Decidim::DecidimAwesome::Menu.instance_variable_set(:@menus, nil)
    Decidim::DecidimAwesome::Menu.register_awesome_admin_menu!
    switch_to_host(organization.host)
    login_as admin, scope: :user
    visit decidim_admin.root_path
    click_link_or_button "Decidim awesome"
  end

  it_behaves_like "javascript config vars"

  context "when manages tweaks" do
    it "renders the admin page" do
      expect(page).to have_content("Decidim Awesome")
    end
  end

  context "when visiting system compatibility" do
    before do
      click_link_or_button "System Compatibility"
    end

    it "renders the page" do
      expect(page).to have_content(/System Compatibility Checks/i)
      expect(page).not_to have_xpath("//span[@class='fill-alert']")
      expect(page).to have_xpath("//span[@class='fill-success']")
    end

    context "and header is overriden" do
      let(:version) { "0.11" }

      it "detects missing css" do
        within ".decidim-version" do
          expect(page).to have_xpath("//span[@class='fill-alert']", count: 1)
        end
      end
    end
  end

  context "when visiting editor hacks" do
    context "when editor hacks are enabled" do
      before do
        click_link_or_button "Editor Hacks"
      end

      it_behaves_like "has menu link", "editors"

      it "renders the page" do
        expect(page).to have_content(/Tweaks for Editor Hacks/i)
      end
    end

    context "when editor hacks are disabled" do
      let(:disabled_features) do
        [:allow_images_in_full_editor, :allow_images_in_small_editor, :allow_videos_in_editors]
      end

      it_behaves_like "do not have menu link", "editors"
    end
  end

  context "when visiting surveys hacks" do
    context "when survey hacks are enabled" do
      before do
        click_link_or_button "Surveys & Forms"
      end

      it_behaves_like "has menu link", "surveys"

      it "renders the page" do
        expect(page).to have_content(/Tweaks for surveys/i)
      end
    end

    context "when survey hacks are disabled" do
      let(:disabled_features) { [:auto_save_forms] }

      it_behaves_like "do not have menu link", "surveys"
    end
  end

  context "when visiting proposal hacks" do
    context "when proposal hacks are enabled" do
      before do
        click_link_or_button "Proposals Hacks"
      end

      it_behaves_like "has menu link", "proposals"

      it "renders the page" do
        expect(page).to have_content(/Tweaks for proposals/i)
        expect(page).to have_content("Customize sorting options for the proposals list")
        expect(page).to have_content("User input validations for the \"title\" field")
        expect(page).to have_content("User input validations for the \"body\" field")
      end

      context "and additional_proposal_sortings is disabled" do
        let(:disabled_features) { [:additional_proposal_sortings] }

        it "renders the page" do
          expect(page).not_to have_content("Customize sorting options for the proposals list")
        end
      end

      context "and rich text editor for participants is disabled" do
        let(:rte_enabled) { false }

        it "renders the page" do
          expect(page).to have_content(/Tweaks for proposals/i)
          expect(page).not_to have_content("\"Rich text editor for participants\" is enabled")
        end
      end

      context "when all title validators are disabled" do
        let(:disabled_features) { [:validate_title_min_length, :validate_title_max_caps_percent, :validate_title_max_marks_together, :validate_title_start_with_caps] }

        it "does not show title options" do
          expect(page).not_to have_content("User input validations for the \"title\" field")
          expect(page).to have_content("User input validations for the \"body\" field")
        end
      end

      context "when all body validators are disabled" do
        let(:disabled_features) { [:validate_body_min_length, :validate_body_max_caps_percent, :validate_body_max_marks_together, :validate_body_start_with_caps] }

        it "does not show body options" do
          expect(page).to have_content("User input validations for the \"title\" field")
          expect(page).not_to have_content("User input validations for the \"body\" field")
        end
      end
    end

    context "when some proposals hacks are disabled" do
      [:allow_images_in_proposals, :validate_title_min_length, :validate_title_max_caps_percent, :validate_title_max_marks_together, :validate_title_start_with_caps, :validate_body_min_length, :validate_body_max_caps_percent, :validate_body_max_marks_together, :validate_body_start_with_caps].each do |var|
        let(:disabled_features) { [var] }

        it_behaves_like "has menu link", "proposals"
      end
    end

    context "when all proposals hacks are disabled" do
      let(:disabled_features) { [:allow_images_in_proposals, :validate_title_min_length, :validate_title_max_caps_percent, :validate_title_max_marks_together, :validate_title_start_with_caps, :validate_body_min_length, :validate_body_max_caps_percent, :validate_body_max_marks_together, :validate_body_start_with_caps] }

      it_behaves_like "do not have menu link", "proposals"
    end
  end

  context "when visiting live chat" do
    context "when livechat hacks are enabled" do
      before do
        click_link_or_button "Live Chat"
      end

      it_behaves_like "has menu link", "livechat"

      it "renders the page" do
        expect(page).to have_content(/Tweaks for Live Chat/i)
      end
    end

    context "when livechat hacks are disabled" do
      let(:disabled_features) { [:intergram_for_admins, :intergram_for_public] }

      it_behaves_like "do not have menu link", "livechat"
    end
  end

  context "when visiting CSS tweaks" do
    context "when scoped styles are enabled" do
      before do
        click_link_or_button "Custom Styles"
      end

      it_behaves_like "has menu link", "styles"

      it "renders the page" do
        expect(page).to have_content(/Tweaks for Custom Styles/i)
      end
    end

    context "when scoped styles are disabled" do
      let(:disabled_features) { [:scoped_styles] }

      it_behaves_like "do not have menu link", "styles"
    end
  end

  context "when visiting Menu hacks" do
    context "when menu_hacks are enabled" do
      let(:disabled_features) { [] }

      before do
        click_link_or_button "Menu Tweaks"
      end

      it_behaves_like "has menu link", "menus/home_content_block_menu/hacks" do
        let(:prefix) { "" }
      end

      it_behaves_like "has menu link", "menus/menu/hacks" do
        let(:prefix) { "" }
      end

      it "renders the main menu page" do
        expect(page).to have_content(/Main menu/i)
      end
    end

    context "when menu_hacks are disabled" do
      let(:disabled_features) { [:menu] }

      it_behaves_like "do not have menu link", "menu_hacks" do
        let(:prefix) { "" }
      end
    end
  end

  context "when visiting custom redirections" do
    context "when custom_redirections are enabled" do
      before do
        click_link_or_button "Custom Redirections"
      end

      it_behaves_like "has menu link", "custom_redirects" do
        let(:prefix) { "" }
      end

      it "renders the page" do
        expect(page).to have_content(/Custom redirections/i)
      end
    end

    context "when custom redirections are disabled" do
      let(:disabled_features) { [:custom_redirects] }

      it_behaves_like "do not have menu link", "custom_redirects"
    end
  end

  context "when visiting Scoped Admins" do
    context "when menu_hacks are enabled" do
      before do
        click_link_or_button "Scoped Admins"
      end

      it_behaves_like "has menu link", "admins"

      it "renders the page" do
        expect(page).to have_content(/Tweaks for Scoped Admins/i)
      end
    end

    context "when scoped admins are disabled" do
      let(:disabled_features) { [:scoped_admins] }

      it_behaves_like "do not have menu link", "admins"
    end
  end

  context "when visiting proposal custom fields" do
    context "when custom fields are enabled" do
      before do
        click_link_or_button "Proposals Custom Fields"
      end

      it_behaves_like "has menu link", "proposal_custom_fields"

      it "renders the page" do
        expect(page).to have_content(/Tweaks for Proposals Custom Fields: Public fields/i)
      end
    end

    context "when custom fields are disabled" do
      let(:disabled_features) do
        [:proposal_custom_fields]
      end

      it_behaves_like "do not have menu link", "proposal_custom_fields"
    end
  end

  context "when visiting private proposal custom fields" do
    context "when private custom fields are enabled" do
      before do
        click_link_or_button "Private fields"
      end

      it_behaves_like "has menu link", "proposal_private_custom_fields"

      it "renders the page" do
        expect(page).to have_content(/Tweaks for Proposals Custom Fields: Private fields/i)
      end
    end

    context "when private custom fields are disabled" do
      let(:disabled_features) do
        [:proposal_private_custom_fields]
      end

      it_behaves_like "do not have menu link", "proposal_private_custom_fields"
    end
  end
end
