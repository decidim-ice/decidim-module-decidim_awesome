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

  context "when the code editor is not enabled" do
    let(:enabled) { false }

    it "keeps the WYSIWYG editor" do
      expect(page).to have_css(".editor-toolbar")
      expect(page).to have_no_css(".cm-editor")
    end
  end
end
