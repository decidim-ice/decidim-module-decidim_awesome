# frozen_string_literal: true

shared_context "verification visibility examples setup" do
  let(:organization) { create(:organization, available_authorizations: [:dummy_authorization_handler]) }
  let!(:user) { create(:user, :confirmed, organization:) }
  let(:process) { create(:participatory_process, :with_steps, title: { en: "Visible process" }, organization:) }
  let(:assembly) { create(:assembly, title: { en: "Invisible assembly" }, organization:) }
  let!(:process_component) { create(:proposal_component, name: { en: "Process component" }, participatory_space: process) }
  let!(:assembly_component) { create(:proposal_component, name: { en: "Assembly component" }, participatory_space: assembly) }
  let!(:process_proposal) { create(:proposal, component: process_component, title: { en: "Process proposal" }) }
  let!(:assembly_proposal) { create(:proposal, component: assembly_component, title: { en: "Assembly proposal" }) }
  let!(:process_comment) { create(:comment, commentable: process_proposal, author: user, body: "Process comment") }
  let!(:assembly_comment) { create(:comment, commentable: assembly_proposal, author: user, body: "Assembly comment") }

  let!(:publish_assembly_action_log) { create(:action_log, organization:, component: nil, participatory_space: nil, resource: assembly, action: "publish", visibility: "all") }
  let!(:publish_process_action_log) { create(:action_log, organization:, component: nil, participatory_space: nil, resource: process, action: "publish", visibility: "all") }
  let!(:publish_process_proposal_action_log) do
    create(:action_log, organization:, resource: process_proposal, component: process_component, participatory_space: process, action: "publish", visibility: "all")
  end
  let!(:publish_assembly_proposal_action_log) do
    create(:action_log, organization:, resource: assembly_proposal, component: assembly_component, participatory_space: assembly, action: "publish", visibility: "all")
  end
  let!(:create_process_comment_action_log) do
    create(:action_log, organization:, resource: process_comment, component: process_comment.component, participatory_space: process, action: "create", visibility: "public-only")
  end
  let!(:create_assembly_comment_action_log) do
    create(:action_log, organization:, resource: assembly_comment, component: assembly_comment.component, participatory_space: assembly, action: "create",
                        visibility: "public-only")
  end

  let!(:force_authorizations_config) do
    create(
      :awesome_config,
      organization:,
      var: :force_authorizations,
      value: force_authorizations_value
    )
  end
  let(:force_authorizations_value) do
    { "test" => { "authorization_handlers" => { "dummy_authorization_handler" => { "options" => {} } } } }
  end
  let!(:sub_config) { create(:awesome_config, organization:, var: "force_authorization_test", value: nil) }
end

shared_examples "all resources are visible in last activities" do
  it "All resources are accessible" do
    visit decidim.last_activities_path
    expect(page).to have_content("New participatory process: Visible process")
    expect(page).to have_content("New proposal: Process proposal")
    expect(page).to have_content("New comment: Process comment")
    expect(page).to have_content("New assembly: Invisible assembly")
    expect(page).to have_content("New proposal: Assembly proposal")
    expect(page).to have_content("New comment: Assembly comment")
  end
end

shared_examples "some resources are not visible in last activities" do |all_components: false|
  it "Some resources are not accessible" do
    visit decidim.last_activities_path
    expect(page).to have_content("New participatory process: Visible process")
    if all_components
      expect(page).to have_no_content("New proposal: Process proposal")
      expect(page).to have_no_content("New comment: Process comment")
    else
      expect(page).to have_content("New proposal: Process proposal")
      expect(page).to have_content("New comment: Process comment")
    end
    expect(page).to have_content("New assembly: Invisible assembly")
    expect(page).to have_no_content("New proposal: Assembly proposal")
    expect(page).to have_no_content("New comment: Assembly comment")
  end
end
