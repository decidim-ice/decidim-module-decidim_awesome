# frozen_string_literal: true

require "spec_helper"
require "decidim/decidim_awesome/test/shared_examples/config_examples"

describe "Visit the admin page" do
  let(:organization) { create(:organization, rich_text_editor_in_public_views: rte_enabled) }
  let!(:admin) { create(:user, :admin, :confirmed, organization:) }
  let(:rte_enabled) { true }
  let(:disabled_features) { [] }
  let(:version_original) { Decidim.version }
  let(:version) { version_original }

  before do
    allow(Decidim).to receive(:version).and_return(version)
    disabled_features.each do |feature|
      allow(Decidim::DecidimAwesome.config).to receive(feature).and_return(:disabled)
    end

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
      skip "This feature is pending to be adapted to Decidim 0.28"

      expect(page).to have_content(/System Compatibility Checks/i)
      expect(page).to have_no_xpath("//span[@class='text-alert']")
      expect(page).to have_xpath("//span[@class='text-success']")
    end

    context "and header is overriden" do
      let(:version) { "0.11" }

      it "detects missing css" do
        skip "This feature is pending to be adapted to Decidim 0.28"

        expect(page).to have_xpath("//span[@class='text-alert']", count: 1)
      end
    end
  end

  context "when visiting editor hacks" do
    context "when editor hacks are enabled" do
      before do
        skip "Custom redirects feature is pending to be adapted to Decidim 0.28 and currently is disabled at lib/decidim/decidim_awesome/awesome.rb"

        click_link_or_button "Editor Hacks"
      end

      it_behaves_like "has menu link", "editors"

      it "renders the page" do
        expect(page).to have_content(/Tweaks for editors/i)
      end
    end

    context "when editor hacks are disabled" do
      let(:disabled_features) do
        [:allow_images_in_editors, :allow_videos_in_editors, :use_markdown_editor,
         :allow_images_in_markdown_editor]
      end

      it_behaves_like "do not have menu link", "editors"
    end
  end

  context "when visiting surveys hacks" do
    context "when survey hacks are enabled" do
      before do
        skip "auto_save_forms feature is pending to be adapted to Decidim 0.28 and currently is disabled at lib/decidim/decidim_awesome/awesome.rb"

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
        skip "Proposals hacks feature is pending to be adapted to Decidim 0.28 and currently is disabled at lib/decidim/decidim_awesome/awesome.rb"

        click_link_or_button "Proposals Hacks"
      end

      it_behaves_like "has menu link", "proposals"

      it "renders the page" do
        expect(page).to have_content(/Tweaks for proposals/i)
        expect(page).to have_content("Customize sorting options for the proposals list")
        expect(page).to have_content("\"Rich text editor for participants\" is enabled")
        expect(page).to have_content("User input validations for the \"title\" field")
        expect(page).to have_content("User input validations for the \"body\" field")
      end

      context "and additional_proposal_sortings is disabled" do
        let(:disabled_features) { [:additional_proposal_sortings] }

        it "renders the page" do
          expect(page).to have_no_content("Customize sorting options for the proposals list")
        end
      end

      context "and rich text editor for participants is disabled" do
        let(:rte_enabled) { false }

        it "renders the page" do
          expect(page).to have_content(/Tweaks for proposals/i)
          expect(page).to have_no_content("\"Rich text editor for participants\" is enabled")
        end
      end

      context "when all title validators are disabled" do
        let(:disabled_features) { [:validate_title_min_length, :validate_title_max_caps_percent, :validate_title_max_marks_together, :validate_title_start_with_caps] }

        it "does not show title options" do
          expect(page).to have_no_content("User input validations for the \"title\" field")
          expect(page).to have_content("User input validations for the \"body\" field")
        end
      end

      context "when all body validators are disabled" do
        let(:disabled_features) { [:validate_body_min_length, :validate_body_max_caps_percent, :validate_body_max_marks_together, :validate_body_start_with_caps] }

        it "does not show body options" do
          expect(page).to have_content("User input validations for the \"title\" field")
          expect(page).to have_no_content("User input validations for the \"body\" field")
        end
      end
    end

    context "when some proposals hacks are disabled" do
      [:allow_images_in_proposals, :validate_title_min_length, :validate_title_max_caps_percent, :validate_title_max_marks_together, :validate_title_start_with_caps, :validate_body_min_length, :validate_body_max_caps_percent, :validate_body_max_marks_together, :validate_body_start_with_caps].each do |var|
        let(:disabled_features) { [var] }

        before do
          skip "Proposals hacks feature is pending to be adapted to Decidim 0.28 and currently is disabled at lib/decidim/decidim_awesome/awesome.rb"
        end

        it_behaves_like "has menu link", "proposals"
      end
    end

    context "when all proposals hacks are disabled" do
      let(:disabled_features) { [:allow_images_in_proposals, :validate_title_min_length, :validate_title_max_caps_percent, :validate_title_max_marks_together, :validate_title_start_with_caps, :validate_body_min_length, :validate_body_max_caps_percent, :validate_body_max_marks_together, :validate_body_start_with_caps] }

      before do
        skip "Proposals hacks feature is pending to be adapted to Decidim 0.28 and currently is disabled at lib/decidim/decidim_awesome/awesome.rb"
      end

      it_behaves_like "do not have menu link", "proposals"
    end
  end

  context "when visiting live chat" do
    context "when livechat hacks are enabled" do
      before do
        skip "Live chat feature is pending to be adapted to Decidim 0.28 and currently is disabled at lib/decidim/decidim_awesome/awesome.rb"

        click_link_or_button "Live Chat"
      end

      it_behaves_like "has menu link", "livechat"

      it "renders the page" do
        expect(page).to have_content(/Tweaks for livechat/i)
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
        skip "Recover this tests after adapting and enabling all features"

        click_link_or_button "Custom Styles"
      end

      it_behaves_like "has menu link", "styles"

      it "renders the page" do
        expect(page).to have_content(/Tweaks for styles/i)
      end
    end

    context "when scoped styles are disabled" do
      let(:disabled_features) { [:scoped_styles] }

      before do
        skip "Recover this tests after adapting and enabling all features"
      end

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

      before do
        skip "Recover this tests after adapting and enabling all features"
      end

      it_behaves_like "do not have menu link", "menu_hacks" do
        let(:prefix) { "" }
      end
    end
  end

  context "when visiting custom redirections" do
    context "when custom_redirections are enabled" do
      before do
        skip "Custom redirects feature is pending to be adapted to Decidim 0.28 and currently is disabled at lib/decidim/decidim_awesome/awesome.rb"

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
        expect(page).to have_content(/Tweaks for admins/i)
      end
    end

    context "when scoped admins are disabled" do
      let(:disabled_features) { [:scoped_admins] }

      before do
        skip "Recover this tests after adapting and enabling all features"
      end

      it_behaves_like "do not have menu link", "admins"
    end
  end

  context "when visiting proposal custom fields" do
    context "when custom fields are enabled" do
      before do
        skip "Proposal custom fields feature is pending to be adapted to Decidim 0.28 and currently is disabled at lib/decidim/decidim_awesome/awesome.rb"

        click_link_or_button "Proposals Custom Fields"
      end

      it_behaves_like "has menu link", "proposal_custom_fields"

      it "renders the page" do
        expect(page).to have_content(/Tweaks for proposal_custom_fields/i)
      end
    end

    context "when custom fields are disabled" do
      let(:disabled_features) do
        [:proposal_custom_fields]
      end

      it_behaves_like "do not have menu link", "proposal_custom_fields"
    end
  end
end
