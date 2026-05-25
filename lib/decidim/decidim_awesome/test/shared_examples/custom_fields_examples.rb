# frozen_string_literal: true

shared_examples "creates a new box" do |name|
  it "saves the content" do
    click_on "Add a new \"#{name}\" box"

    expect(page).to have_admin_callout("created successfully")

    sleep 2
    page.execute_script("document.querySelector('.proposal_custom_fields_editor').FormBuilder.actions.setData(#{data})")

    click_on "Update configuration"

    sleep 2
    expect(page).to have_admin_callout("updated successfully")
    expect(page).to have_content("Full Name")
    expect(page).to have_content("Occupation")
    expect(page).to have_content("Street Sweeper")
    expect(page).to have_content("Short Bio")
  end
end

shared_examples "updates a box" do
  it "updates the content" do
    sleep 2
    expect(page).to have_content("Full Name")
    expect(page).to have_content("Occupation")
    expect(page).to have_content("Street Sweeper")
    expect(page).to have_no_content("Short Bio")

    page.execute_script("$('.proposal_custom_fields_container[data-key=\"foo\"] .proposal_custom_fields_editor')[0].FormBuilder.actions.setData(#{data})")
    click_on "Update configuration"

    sleep 2
    expect(page).to have_admin_callout("updated successfully")
    expect(page).to have_content("Full Name")
    expect(page).to have_no_content("Occupation")
    expect(page).to have_no_content("Street Sweeper")
    expect(page).to have_content("Short Bio")
  end
end

shared_examples "removes a box" do |name|
  let(:custom_fields) do
    {
      "foo" => "[#{data1}]",
      "bar" => "[#{data2}]"
    }
  end

  it "updates the content" do
    sleep 2
    expect(page).to have_content("Full Name")
    expect(page).to have_content("Occupation")
    expect(page).to have_content("Street Sweeper")
    expect(page).to have_no_content("Short Bio")

    within ".proposal_custom_fields_container[data-key=\"foo\"]" do
      accept_confirm { click_on "Remove this \"#{name}\" box" }
    end

    sleep 2
    expect(page).to have_admin_callout("removed successfully")
    expect(page).to have_no_content("Full Name")
    expect(page).to have_content("Occupation")
    expect(page).to have_content("Street Sweeper")
    expect(page).to have_no_content("Short Bio")

    expect(Decidim::DecidimAwesome::AwesomeConfig.find_by(organization:, var: "#{var_name}_foo")).not_to be_present
    expect(Decidim::DecidimAwesome::AwesomeConfig.find_by(organization:, var: "#{var_name}_bar")).to be_present
  end
end

shared_examples "adds a constraint" do
  let(:custom_fields) do
    {
      "foo" => "[#{data1}]",
      "bar" => "[#{data2}]"
    }
  end

  it "adds a new config helper var" do
    within ".proposal_custom_fields_container[data-key=\"foo\"]" do
      click_on "Add case"
    end

    select "Processes", from: "constraint_participatory_space_manifest"
    within "#new-modal-#{var_name}_foo" do
      click_on "Save"
    end

    sleep 2

    within ".proposal_custom_fields_container[data-key=\"foo\"] .constraints-editor" do
      expect(page).to have_content("Processes")
    end

    expect(Decidim::DecidimAwesome::AwesomeConfig.find_by(organization:, var: "#{var_name}_bar")).to be_present
    expect(Decidim::DecidimAwesome::AwesomeConfig.find_by(organization:, var: "#{var_name}_bar").constraints.first.settings).to eq(constraint.settings)
  end
end

shared_examples "removes a constraint" do
  let(:custom_fields) do
    {
      "foo" => "[#{data1}]",
      "bar" => "[#{data2}]"
    }
  end

  it "removes the helper config var" do
    within ".proposal_custom_fields_container[data-key=\"bar\"] .constraints-editor" do
      expect(page).to have_content("Processes")
      expect(page).to have_content("Proposals")
    end

    within ".proposal_custom_fields_container[data-key=\"bar\"] .constraints-editor" do
      within first(".constraints-list li") do
        click_on "Delete"
      end
    end

    within ".proposal_custom_fields_container[data-key=\"bar\"] .constraints-editor" do
      expect(page).to have_no_content("Proposals")
    end

    visit decidim_admin_decidim_awesome.config_path("#{var_name}s")

    within ".proposal_custom_fields_container[data-key=\"bar\"] .constraints-editor" do
      expect(page).to have_no_content("Proposals")
    end

    expect(Decidim::DecidimAwesome::AwesomeConfig.find_by(organization:, var: "#{var_name}_bar")).to be_present
    expect(Decidim::DecidimAwesome::AwesomeConfig.find_by(organization:, var: "#{var_name}_bar").constraints.count).to eq(1)
    expect(Decidim::DecidimAwesome::AwesomeConfig.find_by(organization:, var: "#{var_name}_bar").constraints.first).to eq(another_constraint)
  end

  context "and there is only one constraint" do
    let!(:another_constraint) { nil }

    it "do not remove the helper config var" do
      within ".proposal_custom_fields_container[data-key=\"bar\"] .constraints-editor" do
        click_on "Delete"
      end

      within ".proposal_custom_fields_container[data-key=\"bar\"] .constraints-editor" do
        expect(page).to have_content("Proposals")
      end

      expect(page).to have_content("Sorry, this cannot be deleted")
      expect(Decidim::DecidimAwesome::AwesomeConfig.find_by(organization:, var: "#{var_name}_bar").constraints.count).to eq(1)
      expect(Decidim::DecidimAwesome::AwesomeConfig.find_by(organization:, var: "#{var_name}_bar").constraints.first).to eq(constraint)
    end
  end
end
