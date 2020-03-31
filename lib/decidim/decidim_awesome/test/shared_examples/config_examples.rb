# frozen_string_literal: true

shared_examples "javascript config vars" do
  it "has DecidimAwesome object" do
    expect(page.body).to have_content("window.DecidimAwesome")
  end
end
