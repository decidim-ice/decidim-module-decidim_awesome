# frozen_string_literal: true

shared_examples "javascript config vars" do
  it "has DecidimAwesome object" do
    expect(page.body).to have_content("window.DecidimAwesome")
    expect(page.body).to have_content("window.DecidimAwesome.editor_uploader_path")
    expect(page.body).to have_content("window.DecidimAwesome.texts")
  end
end

shared_examples "has menu link" do |item|
  let(:prefix) { "config/" }
  it "shows the feature link" do
    within ".secondary-nav" do
      expect(page).to have_link(href: "/admin/decidim_awesome/#{prefix}#{item}")
    end
  end
end

shared_examples "do not have menu link" do |item|
  let(:prefix) { "config/" }
  it "do not show the feature link" do
    within ".secondary-nav" do
      expect(page).not_to have_link(href: "/admin/decidim_awesome/#{prefix}#{item}")
    end
  end
end
