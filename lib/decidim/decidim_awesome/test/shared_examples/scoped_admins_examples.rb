# frozen_string_literal: true

shared_examples "redirects to index" do |_link|
  it "display index page" do
    expect(page).to have_content("You are not authorized to perform this action")
    expect(page).to have_content("Welcome to the Decidim Admin Panel.")
    expect(page).to have_current_path(decidim_admin.root_path, ignore_query: true)
  end
end

shared_examples "forbids awesome access" do
  it "does not have awesome link" do
    visit decidim_admin.root_path
    expect(page).not_to have_content("Decidim awesome")
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
    expect(page).to have_content("New user")
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
  end

  it "allows the admin root page" do
    expect(page).to have_content("Welcome to the Decidim Admin Panel.")
  end

  it "allows the assemblies page" do
    click_link "Assemblies"

    expect(page).to have_content("New assembly")
  end

  it "allows the processes page" do
    click_link "Processes"

    expect(page).to have_content("New process")
  end
end

shared_examples "allows limited admin routes" do
  before do
    visit decidim_admin.root_path
  end

  it "allows the admin root page" do
    expect(page).to have_content("Welcome to the Decidim Admin Panel.")
  end

  it "allows the assemblies page" do
    click_link "Assemblies"

    expect(page).to have_content("New assembly")
  end

  describe "forbids processes" do
    before do
      click_link "Processes"
    end

    it_behaves_like "redirects to index"

    it "is not a process page" do
      expect(page).not_to have_content("New process")
    end
  end
end

shared_examples "has admin link" do
  it "has menu link" do
    within ".topbar__dropmenu.topbar__user__logged" do
      expect(page).to have_selector("#user-menu li", text: "Admin dashboard", visible: :hidden)
    end
  end
end

shared_examples "has no admin link" do
  it "has menu link" do
    within ".topbar__dropmenu.topbar__user__logged" do
      expect(page).not_to have_selector("#user-menu li", text: "Admin dashboard", visible: :hidden)
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
      expect(page).not_to have_link(href: "/admin/processes")
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
    find("*[type=submit]").click
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

    click_link "Edit proposal"
    expect(page).to have_content("Update proposal")
    fill_in_i18n(
      :proposal_title,
      "#proposal-title-tabs",
      en: "Edited proposal",
      ca: "Proposta editada",
      es: "Propuesta editada"
    )
    find("*[type=submit]").click
    expect(page).to have_admin_callout("successfully")
  end

  it "can create a proposal" do
    visit manage_component_path(component)

    click_link "New proposal"
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
    find("*[type=submit]").click
    expect(page).to have_admin_callout("successfully")
  end
end

shared_examples "edits allowed components" do
  before do
    visit decidim_admin.root_path
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
      expect(page).not_to have_link(href: manage_component_path(another_component))
    end
  end
end
