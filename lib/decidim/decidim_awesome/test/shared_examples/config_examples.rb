# frozen_string_literal: true

shared_examples "javascript config vars" do
  it "has DecidimAwesome object" do
    expect(page.body).to have_content("window.DecidimAwesome")
    expect(page.body).to have_content("window.DecidimAwesome.version")
    expect(page.body).to have_content("window.DecidimAwesome.editorUploaderPath")
    expect(page.body).to have_content("window.DecidimAwesome.texts")
  end
end

shared_examples "has menu link" do |item|
  let(:prefix) { "config/" }
  it "shows the feature link" do
    within ".sidebar-menu" do
      expect(page).to have_link(href: "/admin/decidim_awesome/#{prefix}#{item}")
    end
  end
end

shared_examples "do not have menu link" do |item|
  let(:prefix) { "config/" }
  it "do not show the feature link" do
    within ".sidebar-menu" do
      expect(page).not_to have_link(href: "/admin/decidim_awesome/#{prefix}#{item}")
    end
  end
end

shared_examples "forbids disabled feature" do
  render_views
  let(:feature) { :menu }
  let(:features) { [feature] }
  before do
    features.each do |feat|
      allow(Decidim::DecidimAwesome.config).to receive(feat).and_return(:disabled)
    end
  end

  it "redirects with error" do
    action

    expect(response.body).to eq("no permissions for #{key}")
  end
end
