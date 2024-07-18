# frozen_string_literal: true

shared_examples "has no image support" do
  it "has no image button" do
    expect(page).not_to have_xpath("//button[@class='editor-toolbar-control'][@data-editor-type='image']")
  end
end

shared_examples "has image support" do
  it "has image button" do
    expect(page).to have_xpath("//button[@class='editor-toolbar-control'][@data-editor-type='image']")
  end
end

shared_examples "has no video support" do
  it "has no video button" do
    expect(page).not_to have_xpath("//button[@class='editor-toolbar-control'][@data-editor-type='videoEmbed']")
  end
end

shared_examples "has video support" do
  it "has video button" do
    expect(page).to have_xpath("//button[@class='editor-toolbar-control'][@data-editor-type='videoEmbed']")
  end
end

shared_examples "has no drag and drop" do
  it "cannot drop a file" do
    expect(page).not_to have_content("Add images by dragging & dropping or pasting them.")
    find(editor_selector).drop(image)
    expect(page.execute_script("return document.querySelector('#{editor_selector}').value")).not_to eq("[Uploading file...]")
    sleep 1
    last_image = Decidim::DecidimAwesome::EditorImage.last
    expect(last_image).to be_nil
  end
end

shared_examples "has drag and drop" do
  it "can drop a file" do
    expect(page).to have_content("Add images by dragging & dropping or pasting them.")
    fill_in "proposal_title", with: "This is a test proposal"
    fill_in "proposal_body", with: ""
    find(editor_selector).drop(image)
    expect(page.execute_script("return document.querySelector('#{editor_selector}').value")).to eq("[Uploading file...]")
    sleep 1
    last_image = Decidim::DecidimAwesome::EditorImage.last
    expect(last_image).to be_present
    content = page.execute_script("return document.querySelector('#{editor_selector}').value")
    expect(content).to include(last_image.attached_uploader(:file).path)
    # ensures valid body validations
    fill_in "proposal_body", with: "This is a super test\n#{content}"
    click_link_or_button "Send"
    expect(proposal.reload.body["en"]).to include(last_image.attached_uploader(:file).path)
  end
end
