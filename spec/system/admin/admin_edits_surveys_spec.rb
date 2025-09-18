# frozen_string_literal: true

require "spec_helper"

describe "Admin access to manage a survey" do
  let(:organization) { create(:organization) }
  let(:component) do
    create(:component,
           manifest_name: "surveys",
           published_at: nil,
           organization:)
  end
  let!(:questionnaire) { create(:questionnaire) }
  let!(:survey) { create(:survey, :published, :clean_after_publish, component:, questionnaire:) }

  let!(:user) { create(:user, :admin, :confirmed, organization: component.organization) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  it "allows to manage component" do
    visit decidim_admin_participatory_processes.decidim_admin_participatory_process_surveys_path(component.participatory_space, component)

    expect(page.evaluate_script("window.DecidimAwesome")).not_to be_nil
    expect(page.evaluate_script("window.current_questionnaire")).to be_nil
  end
end
