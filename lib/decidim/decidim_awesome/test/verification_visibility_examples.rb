shared_examples "all resources are visible in last activities" do
  it "All resources are accessible" do
    visit decidim.last_activities_path
    expect(page).to have_content("New participatory process: Visible process")
    expect(page).to have_content("New proposal: Visible process proposal")
    expect(page).to have_content("New comment: Process comment")
    expect(page).to have_content("New assembly: Invisible assembly")
    expect(page).to have_content("New proposal: Invisible assembly proposal")
    expect(page).to have_content("New comment: Assembly comment")
  end
end

shared_examples "some resources are not visible in last activities" do |all_components: false|
  it "Some resources are not accessible" do
    visit decidim.last_activities_path
    expect(page).to have_content("New participatory process: Visible process")
    if all_components
      expect(page).to have_no_content("New proposal: Visible process proposal")
      expect(page).to have_no_content("New comment: Process comment")
    else
      expect(page).to have_content("New proposal: Visible process proposal")
      expect(page).to have_content("New comment: Process comment")
    end
    expect(page).to have_content("New assembly: Invisible assembly")
    expect(page).to have_no_content("New proposal: Invisible assembly proposal")
    expect(page).to have_no_content("New comment: Assembly comment")
  end
end
