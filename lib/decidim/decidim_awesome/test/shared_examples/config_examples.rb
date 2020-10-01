# frozen_string_literal: true

shared_examples "javascript config vars" do
  it "has DecidimAwesome object" do
    expect(page.body).to have_content("window.DecidimAwesome")
    expect(page.body).to have_content("window.DecidimAwesome.editor_upload_path")
    expect(page.body).to have_content("window.DecidimAwesome.texts")
  end
end
