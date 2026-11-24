# frozen_string_literal: true

require "spec_helper"

describe "Admin uses the HTML code editor" do
  let(:organization) { create(:organization) }
  let!(:admin) { create(:user, :admin, :confirmed, organization:) }
  let!(:static_page) { create(:static_page, organization:, content: { en: "<figure>A caption</figure>" }) }
  let!(:html_code_editor) { create(:awesome_config, organization:, var: :html_code_editor, value: enabled) }
  let(:enabled) { true }
  let(:html) { '<div class="custom-hero"><p>Budget open</p></div><style>.custom-hero { text-transform: uppercase; }</style>' }

  before do
    switch_to_host(organization.host)
    login_as admin, scope: :user
    visit decidim_admin.edit_static_page_path(static_page)
  end

  it "saves the HTML and shows it in the public page" do
    page.execute_script(<<~JS, find(".editor-input .cm-content", match: :first), html)
      const data = new DataTransfer();
      data.setData("text/plain", arguments[1]);
      arguments[0].dispatchEvent(new ClipboardEvent("paste", { clipboardData: data, bubbles: true, cancelable: true }));
    JS
    click_on "Update"

    expect(page).to have_admin_callout("Page updated successfully")

    visit decidim.page_path(static_page)

    within ".custom-hero" do
      expect(page).to have_content("BUDGET OPEN")
    end
  end

  it "warns about the tags that are not allowed" do
    find(".cm-lintRange-warning", text: "figure").hover

    expect(page).to have_content("This tag is not allowed and will be removed when the content is displayed")
  end

  it "previews the content as it is displayed" do
    click_on "Preview", match: :first

    within_frame(find("#awesome-html-code-preview iframe")) do
      expect(page).to have_content("A caption")
      expect(page).to have_no_css("figure")
    end
  end

  it "uploads a file and adds it to the content" do
    within first(".awesome-code-editor-toolbar") do
      attach_file(Decidim::Dev.asset("city.jpeg"), make_visible: true)
    end

    expect(page).to have_css(".cm-content", text: 'alt="city.jpeg"')

    click_on "Update"

    expect(page).to have_admin_callout("Page updated successfully")

    visit decidim.page_path(static_page)

    expect(page).to have_css("img[alt='city.jpeg']")
  end

  it "uploads the files dropped in the editor" do
    find(".editor-input .cm-content", match: :first).drop(Decidim::Dev.asset("city.jpeg"))

    expect(page).to have_css(".cm-content", text: 'alt="city.jpeg"')
  end

  it "does not upload the files that are not allowed" do
    within first(".awesome-code-editor-toolbar") do
      attach_file(Decidim::Dev.asset("Exampledocument.pdf"), make_visible: true)
    end

    expect(page).to have_content(/The file could not be uploaded: .+/)
    expect(page).to have_no_css(".cm-content", text: "Exampledocument")
  end

  context "when the code editor is not enabled" do
    let(:enabled) { false }

    it "keeps the WYSIWYG editor" do
      expect(page).to have_css(".ProseMirror")
      expect(page).to have_no_css(".cm-editor")
    end
  end

  describe "the extra tags in the public pages" do
    let!(:static_page) { create(:static_page, organization:, content: { en: html }) }
    let!(:constraint) { create(:config_constraint, awesome_config: html_code_editor, settings: { "participatory_space_manifest" => manifest }) }

    before do
      visit decidim.page_path(static_page)
    end

    context "when the code editor applies outside the participatory spaces" do
      let(:manifest) { "system" }

      it "keeps them" do
        within ".custom-hero" do
          expect(page).to have_content("BUDGET OPEN")
        end
      end
    end

    context "when the code editor applies to the participatory processes" do
      let(:manifest) { "participatory_processes" }
      let!(:participatory_process) { create(:participatory_process, :with_content_blocks, organization:, description: { en: html }, blocks_manifests: [:main_data]) }

      it "removes them" do
        within ".custom-hero" do
          expect(page).to have_content("Budget open")
        end
      end

      it "keeps them in the pages of a process" do
        visit decidim_participatory_processes.participatory_process_path(participatory_process)

        within ".custom-hero" do
          expect(page).to have_content("BUDGET OPEN")
        end
      end
    end
  end
end
