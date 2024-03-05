# frozen_string_literal: true

shared_examples "has no drag and drop" do |rte|
  it "has no help text" do
    expect(page).to have_no_content("Add images by dragging & dropping or pasting them.")
  end

  if rte
    it "has image button" do
      expect(page).to have_no_xpath("//button[@class='ql-image']")
    end
  else
    it "has no paste event" do
      sleep 1
      expect(page.execute_script("return typeof $._data($('#{editor_selector}')[0], 'events').paste")).to eq("undefined")
    end

    it "has no drop event" do
      sleep 1
      expect(page.execute_script("return typeof $._data($('#{editor_selector}')[0], 'events').drop")).to eq("undefined")
    end
  end
end

shared_examples "has drag and drop" do |rte|
  it "has help text" do
    skip "This feature is pending to be adapted to Decidim 0.28"

    expect(page).to have_content("Add images by dragging & dropping or pasting them.")
  end

  if rte
    it "has image button" do
      skip "This feature is pending to be adapted to Decidim 0.28"

      expect(page).to have_xpath("//button[@class='ql-image']")
    end
  else
    it "has paste event" do
      sleep 1
      expect(page.execute_script("return typeof $._data($('#{editor_selector}')[0], 'events').paste")).to eq("object")
    end

    it "has drop event" do
      sleep 1
      expect(page.execute_script("return typeof $._data($('#{editor_selector}')[0], 'events').drop")).to eq("object")
    end
  end
end

shared_examples "has markdown editor" do |images|
  it "has CodeMirror class" do
    skip "This feature is pending to be adapted to Decidim 0.28"

    expect(page).to have_xpath("//div[@class='CodeMirror cm-s-paper CodeMirror-wrap']")
  end

  it "has toolbar" do
    expect(page).to have_xpath("//div[@class='editor-toolbar']")
  end

  if images
    it "has help text" do
      skip "This feature is pending to be adapted to Decidim 0.28"

      expect(page).to have_content("Add images by dragging & dropping or pasting them.")
    end
  else
    it "has no help text" do
      expect(page).to have_no_content("Add images by dragging & dropping or pasting them.")
    end
  end
end

shared_examples "has no markdown editor" do
  it "has CodeMirror class" do
    expect(page).to have_no_xpath("//div[@class='CodeMirror cm-s-paper CodeMirror-wrap']")
  end

  it "has toolbar" do
    expect(page).to have_no_xpath("//div[@class='editor-toolbar']")
  end
end
