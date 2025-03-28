# frozen_string_literal: true

shared_examples "has no image support" do
  it "has no image button" do
    expect(page).to have_no_xpath("//button[@class='editor-toolbar-control'][@data-editor-type='image']")
  end
end

shared_examples "has image support" do
  it "has image button" do
    expect(page).to have_xpath("//button[@class='editor-toolbar-control'][@data-editor-type='image']")
  end
end

shared_examples "has no video support" do
  it "has no video button" do
    expect(page).to have_no_xpath("//button[@class='editor-toolbar-control'][@data-editor-type='videoEmbed']")
  end
end

shared_examples "has video support" do
  it "has video button" do
    expect(page).to have_xpath("//button[@class='editor-toolbar-control'][@data-editor-type='videoEmbed']")
  end
end

shared_examples "has no drag and drop" do
  it "cannot drop a file" do
    expect(page).to have_no_content("Add images by dragging & dropping or pasting them.")
    find(editor_selector).drop(image)
    expect(page.execute_script("return document.querySelector('#{editor_selector}').value")).not_to eq("[Uploading file...]")
    sleep 1
    last_image = Decidim::DecidimAwesome::EditorImage.last
    expect(last_image).to be_nil
  end
end

shared_examples "has drag and drop" do
  it "can drop a file" do
    within "form.edit_proposal" do
      expect(page).to have_content("Add images by dragging & dropping or pasting them.")
      fill_in :proposal_body, with: ""
    end
    find(editor_selector).drop(image)
    expect(page.execute_script("return document.querySelector('#{editor_selector}').value")).to include("[Uploading file...]")
    sleep 1
    last_image = Decidim::DecidimAwesome::EditorImage.last
    expect(last_image).to be_present
    content = page.execute_script("return document.querySelector('#{editor_selector}').value")
    expect(content).to include(last_image.file.blob.to_gid.to_s)
    within "form.edit_proposal" do
      # ensures valid body validations
      fill_in :proposal_body, with: "This is a super test with lots of downcases characters to be sure that the image name does not mess with percentage of caps.\n#{content}"
      fill_in :proposal_title, with: "This is a test proposal"
      click_on "Send"
    end
    expect(proposal.reload.body["en"]).to include(last_image.attached_uploader(:file).path)
  end
end
