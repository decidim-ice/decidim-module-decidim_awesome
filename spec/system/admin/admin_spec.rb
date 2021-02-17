# frozen_string_literal: true

require "spec_helper"
require "decidim/decidim_awesome/test/shared_examples/config_examples"

describe "Visit the admin page", type: :system do
  let(:organization) { create :organization, rich_text_editor_in_public_views: rte_enabled }
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

    switch_to_host(organization.host)
    login_as admin, scope: :user
    visit decidim_admin.root_path
    click_link "Decidim awesome"
  end

  include_examples "javascript config vars"

  context "when manages tweaks" do
    it "renders the admin page" do
      expect(page).to have_content("Decidim Awesome")
    end
  end

  context "when visiting system compatibility" do
    before do
      click_link "System compatibility"
    end

    it "renders the page" do
      expect(page).to have_content(/System compatibility checks/i)
      expect(page).not_to have_xpath("//span[@class='text-alert']")
      expect(page).to have_xpath("//span[@class='text-success']")
    end

    context "and header is overriden" do
      let(:version) { "0.11" }

      it "detects missing css" do
        expect(page).to have_xpath("//span[@class='text-alert']", count: 5)
      end
    end
  end

  context "when visiting editor hacks" do
    context "when editor hacks are enabled" do
      before do
        click_link "Editor hacks"
      end

      it_behaves_like "has menu link", "editors"

      it "renders the page" do
        expect(page).to have_content(/Tweaks for editors/i)
      end
    end

    context "when editor hacks are disabled" do
      let(:disabled_features) do
        [:allow_images_in_full_editor, :allow_images_in_small_editor, :use_markdown_editor,
         :allow_images_in_markdown_editor]
      end

      it_behaves_like "do not have menu link", "editors"
    end
  end

  context "when visiting surveys hacks" do
    context "when survey hacks are enabled" do
      before do
        click_link "Surveys & forms"
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
        click_link "Proposals hacks"
      end

      it_behaves_like "has menu link", "proposals"

      it "renders the page" do
        expect(page).to have_content(/Tweaks for proposals/i)
        expect(page).to have_content("\"Rich text editor for participants\" is enabled")
      end

      context "and rich text editor for participants is disabled" do
        let(:rte_enabled) { false }

        it "renders the page" do
          expect(page).to have_content(/Tweaks for proposals/i)
          expect(page).not_to have_content("\"Rich text editor for participants\" is enabled")
        end
      end
    end

    context "when proposal hacks are disabled" do
      let(:disabled_features) { [:allow_images_in_proposals] }

      it_behaves_like "do not have menu link", "proposals"
    end
  end

  context "when visiting live chat" do
    context "when livechat hacks are enabled" do
      before do
        click_link "Live Chat"
      end

      it_behaves_like "has menu link", "livechat"

      it "renders the page" do
        expect(page).to have_content(/Tweaks for livechat/i)
      end
    end
  end

  context "when livechat hacks are disabled" do
    let(:disabled_features) { [:intergram_for_admins, :intergram_for_public] }

    it_behaves_like "do not have menu link", "livechat"
  end

  context "when visiting CSS tweaks" do
    context "when scoped styles are enabled" do
      before do
        click_link "Custom styles"
      end

      it_behaves_like "has menu link", "styles"

      it "renders the page" do
        expect(page).to have_content(/Tweaks for styles/i)
      end
    end
  end

  context "when scoped styles are disabled" do
    let(:disabled_features) { [:scoped_styles] }

    it_behaves_like "do not have menu link", "styles"
  end
end
