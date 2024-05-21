# frozen_string_literal: true

welcome_text = "Dashboard"

shared_examples "redirects to index" do |_link|
  it "display index page" do
    expect(page).to have_content("You are not authorized to perform this action")
    expect(page).to have_content(welcome_text)
    expect(page).to have_current_path(decidim_admin.root_path, ignore_query: true)
  end
end

shared_examples "forbids awesome access" do
  it "does not have awesome link" do
    visit decidim_admin.root_path
    expect(page).to have_no_content("Decidim awesome")
  end

  describe "forbids module access" do
    before do
      visit decidim_admin_decidim_awesome.config_path(:editors)
    end

    it_behaves_like "redirects to index"
  end
end

shared_examples "allows awesome access" do
  it "does not have awesome link" do
    visit decidim_admin.root_path
    expect(page).to have_link("Decidim awesome")
  end

  it "allows module access" do
    visit decidim_admin_decidim_awesome.config_path(:editors)
    expect(page).to have_content("Tweaks for editors")
  end
end

shared_examples "forbids external accesses" do
  describe "forbids newsletter access" do
    before do
      visit decidim_admin.newsletters_path
    end

    it_behaves_like "redirects to index"
  end

  describe "forbids participants access" do
    before do
      visit decidim_admin.users_path
    end

    it_behaves_like "redirects to index"
  end

  describe "forbids pages access" do
    before do
      visit decidim_admin.static_pages_path
    end

    it_behaves_like "redirects to index"
  end

  describe "forbids moderation access" do
    before do
      visit decidim_admin.moderations_path
    end

    it_behaves_like "redirects to index"
  end

  describe "forbids organization access" do
    before do
      visit decidim_admin.edit_organization_path
    end

    it_behaves_like "redirects to index"
  end
end

shared_examples "allows external accesses" do
  it "shows newsletter access" do
    visit decidim_admin.newsletters_path
    expect(page).to have_content("New newsletter")
  end

  it "shows participants access" do
    visit decidim_admin.users_path
    expect(page).to have_content("New admin")
  end

  it "shows pages access" do
    visit decidim_admin.static_pages_path
    expect(page).to have_content("Pages without topic")
  end

  it "shows moderation access" do
    visit decidim_admin.moderations_path
    expect(page).to have_content("Reported content URL")
  end

  it "shows organization access" do
    visit decidim_admin.edit_organization_path
    expect(page).to have_content("Edit organization")
  end
end

shared_examples "allows all admin routes" do
  before do
    visit decidim_admin.root_path
    # this is a workaround to wait for the page to load
    # it seems that the test might fail randomly otherwise
    # underlaying issue is unknown, maybe capybara is faster clicking than ruby is at storing class variables?
    sleep 0.1
  end

  it "allows the admin root page" do
    expect(page).to have_content(welcome_text)
  end

  it "allows the assemblies page" do
    click_link_or_button "Assemblies"
    expect(page).to have_content("New assembly")
  end

  it "allows the processes page" do
    click_link_or_button "Processes"

    expect(page).to have_content("New process")
  end
end

shared_examples "allows scoped admin routes" do
  before do
    visit decidim_admin.root_path
    sleep 0.1
  end

  it "allows the admin root page" do
    expect(page).to have_content(welcome_text)
  end

  it "allows the assemblies page" do
    click_link_or_button "Assemblies"

    expect(page).to have_content("New assembly")
  end

  describe "forbids processes" do
    before do
      click_link_or_button "Processes"
    end

    it_behaves_like "redirects to index"

    it "is not a process page" do
      expect(page).to have_no_content("New process")
    end
  end
end

shared_examples "has admin link" do
  it "has menu link" do
    within "header" do
      expect(page).to have_css("#admin-bar", text: "Admin dashboard")
    end
  end
end

shared_examples "has no admin link" do
  it "has no menu link" do
    within "header" do
      expect(page).to have_no_css("#admin-bar", text: "Admin dashboard")
    end
  end
end

shared_examples "shows partial admin links in the frontend" do
  describe "shows the link in the homepage" do
    before do
      visit decidim.root_path
    end

    it_behaves_like "has admin link"
  end

  describe "shows the link in assemblies" do
    before do
      visit decidim_assemblies.assemblies_path
    end

    it_behaves_like "has admin link"
    it "has a Edit button" do
      expect(page).to have_link(href: "/admin/assemblies")
    end
  end

  describe "do not show the link in processes" do
    before do
      visit decidim_participatory_processes.participatory_processes_path
    end

    it_behaves_like "has no admin link"
    it "has no Edit button" do
      expect(page).to have_no_link(href: "/admin/processes")
    end
  end
end

shared_examples "can edit assembly" do
  it "can save" do
    visit decidim_admin_assemblies.edit_assembly_path(assembly.slug)
    expect(page).to have_content("General Information")
    fill_in_i18n(
      :assembly_title,
      "#assembly-title-tabs",
      en: "Edited assembly",
      ca: "Assamblea editada",
      es: "Asamblea editada"
    )
    click_link_or_button "Update"
    expect(page).to have_admin_callout("successfully")
  end
end

shared_examples "edits all assemblies" do
  before do
    visit decidim_admin.root_path
  end

  it_behaves_like "can edit assembly"

  it "can edit another assembly" do
    visit decidim_admin_assemblies.edit_assembly_path(another_assembly.slug)
    expect(page).to have_content("General Information")
  end
end

shared_examples "edits allowed assemblies" do
  before do
    visit decidim_admin.root_path
  end

  it_behaves_like "can edit assembly"

  describe "forbids unallowed assembly" do
    before do
      visit decidim_admin_assemblies.edit_assembly_path(another_assembly.slug)
    end

    it_behaves_like "redirects to index"
  end

  describe "create new assemblies" do
    before do
      visit decidim_admin_assemblies.new_assembly_path
    end

    it_behaves_like "redirects to index"
  end
end

shared_examples "can manage component" do
  it "can update proposal" do
    visit manage_component_path(component)
    expect(page).to have_content("Proposals")
    expect(page).to have_content("Title")
    expect(page).to have_content(proposal.title["en"])

    click_link_or_button "Edit proposal"
    expect(page).to have_content("Update proposal")
    fill_in_i18n(
      :proposal_title,
      "#proposal-title-tabs",
      en: "Edited proposal",
      ca: "Proposta editada",
      es: "Propuesta editada"
    )
    click_link_or_button "Update"
    expect(page).to have_admin_callout("successfully")
  end

  it "can create a proposal" do
    visit manage_component_path(component)

    click_link_or_button "New proposal"
    expect(page).to have_content("Create proposal")
    fill_in_i18n(
      :proposal_title,
      "#proposal-title-tabs",
      en: "Create proposal",
      ca: "Proposta creada",
      es: "Propuesta creada"
    )
    fill_in_i18n_editor(
      :proposal_body,
      "#proposal-body-tabs",
      en: "Create body",
      ca: "Body creat",
      es: "Body creat"
    )
    click_link_or_button "Create"
    expect(page).to have_admin_callout("successfully")
  end
end

shared_examples "edits allowed components" do
  before do
    visit decidim_admin.root_path
    sleep 0.1
  end

  it_behaves_like "can manage component"
  it "can edit component" do
    visit Decidim::EngineRouter.admin_proxy(component.participatory_space).edit_component_path(component.id)
    expect(page).to have_content("Edit component")
  end

  it "set permissions in component" do
    visit Decidim::EngineRouter.admin_proxy(component.participatory_space).edit_component_permissions_path(component.id)
    expect(page).to have_content("Edit permissions")
  end

  describe "forbids unallowed component" do
    before do
      visit manage_component_path(another_component)
    end

    it_behaves_like "redirects to index"
  end
end

shared_examples "shows component partial admin links in the frontend" do
  describe "shows the link in the homepage" do
    before do
      visit decidim.root_path
    end

    it_behaves_like "has admin link"
  end

  describe "shows the link in the component" do
    before do
      visit main_component_path(component)
    end

    it_behaves_like "has admin link"
    it "has a Edit button" do
      expect(page).to have_link(href: manage_component_path(component))
    end
  end

  describe "do not show the link in another compoenent" do
    before do
      visit main_component_path(another_component)
    end

    it_behaves_like "has no admin link"
    it "has no Edit button" do
      expect(page).to have_no_link(href: manage_component_path(another_component))
    end
  end
end

shared_examples "allows access to group processes" do
  before do
    visit decidim_admin_participatory_processes.participatory_processes_path
  end

  it "shows the list of processes" do
    within("[data-content]") do
      expect(page).to have_content("Processes")
      expect(page).to have_content(participatory_process.title["en"])
    end
  end

  describe "forbids editing processes" do
    before do
      visit decidim_admin_participatory_processes.edit_participatory_process_path(participatory_process.slug)
    end

    it_behaves_like "redirects to index"
  end

  describe "allows listing group process" do
    before do
      visit decidim_admin_participatory_processes.participatory_process_groups_path
    end

    it "shows the list of groups" do
      within("[data-content]") do
        expect(page).to have_content("Process groups")
        expect(page).to have_content(process_group.title["en"])
      end
    end
  end
end

shared_examples "allows edit any group process" do
  before do
    visit decidim_admin_participatory_processes.edit_participatory_process_group_path(another_process_group.id)
  end

  it "allows to edit group processes" do
    expect(page).to have_content("Edit process group")
    fill_in_i18n(
      :participatory_process_group_title,
      "#participatory_process_group-title-tabs",
      en: "Edited process group",
      ca: "Proces grup editat",
      es: "Grupo de procesos editado"
    )
    click_link_or_button "Update"
    expect(page).to have_admin_callout("successfully")
  end
end

shared_examples "allows edit only allowed group process" do
  before do
    visit decidim_admin_participatory_processes.participatory_processes_path
  end

  describe "forbids editing group" do
    before do
      visit decidim_admin_participatory_processes.edit_participatory_process_group_path(another_process_group.id)
    end

    it_behaves_like "redirects to index"
  end
end
