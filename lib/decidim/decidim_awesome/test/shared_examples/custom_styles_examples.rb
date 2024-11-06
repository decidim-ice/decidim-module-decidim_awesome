# frozen_string_literal: true

shared_examples "creates a new box" do |name|
  it "saves the content in the hash" do
    click_on "Add a new \"#{name}\" CSS box"

    expect(page).to have_admin_callout("created successfully")

    sleep 1
    page.execute_script('document.querySelector(".CodeMirror").CodeMirror.setValue("body {background: red;}");')

    click_on "Update configuration"

    expect(page).to have_admin_callout("updated successfully")
    expect(page).to have_content("body {background: red;}")
  end
end

shared_examples "saves content" do |key|
  it "updates succesfully" do
    expect(page).to have_content("body {background: red;}")
    expect(page).to have_content("body {background: blue;}")

    sleep 1
    page.execute_script("document.querySelector(\"[data-key=#{key}] .CodeMirror\").CodeMirror.setValue(\"body {background: green;}\");")
    click_link_or_button "Update configuration"

    expect(page).to have_admin_callout("updated successfully")
    expect(page).not_to have_content("body {background: red;}")
    expect(page).to have_content("body {background: green;}")
    expect(page).to have_content("body {background: blue;}")
  end

  it "shows error message if invalid" do
    sleep 1
    page.execute_script("document.querySelector(\"[data-key=#{key}] .CodeMirror\").CodeMirror.setValue(\"I am invalid CSS\");")
    click_link_or_button "Update configuration"

    expect(page).to have_admin_callout("Error updating configuration!")
    expect(page).not_to have_content("body {background: red;}")
    expect(page).to have_content("body {background: blue;}")
    expect(page).to have_content("I am invalid CSS")
  end
end

shared_examples "updates new box" do
  it "updates the content in the hash" do
    expect(page).to have_content("body {background: red;}")
    expect(page).to have_content("body {background: blue;}")
  end
end

shared_examples "removes a box" do
  let(:styles) do
    {
      "foo" => "body {background: red;}",
      "bar" => "body {background: blue;}"
    }
  end

  it "updates the content in the hash" do
    expect(page).to have_content("body {background: red;}")
    expect(page).to have_content("body {background: blue;}")

    within ".scoped_styles_container[data-key=\"foo\"]" do
      accept_confirm { click_link_or_button "Remove this CSS box" }
    end

    expect(page).to have_admin_callout("removed successfully")
    expect(page).to have_content("body {background: blue;}")
    expect(page).not_to have_content("body {background: red;}")
    expect(Decidim::DecidimAwesome::AwesomeConfig.find_by(organization: organization, var: "#{var_name}_foo")).not_to be_present
    expect(Decidim::DecidimAwesome::AwesomeConfig.find_by(organization: organization, var: "#{var_name}_bar")).to be_present
  end
end

shared_examples "adds a constraint" do |name|
  let(:styles) do
    {
      "foo" => "body {background: red;}",
      "bar" => "body {background: blue;}"
    }
  end

  it "adds a new config helper var" do
    click_on "Add a new \"#{name}\" CSS box"

    expect(page).to have_content("Processes")

    expect(Decidim::DecidimAwesome::AwesomeConfig.find_by(organization: organization, var: "#{var_name}_bar")).to be_present
    expect(Decidim::DecidimAwesome::AwesomeConfig.find_by(organization: organization,
                                                          var: "#{var_name}_bar").constraints.first.settings).to eq("participatory_space_manifest" => "participatory_processes")
  end
end

shared_examples "removes a constraint" do
  let(:styles) do
    {
      "foo" => "body {background: red;}",
      "bar" => "body {background: blue;}"
    }
  end

  before do
    visit decidim_admin_decidim_awesome.config_path("#{var_name}s")
    click_on "Add case", id: "new-#{var_name}_bar"
  end

  it "removes the helper config var" do
    within "#constraint-form-" do
      select "Processes", from: "Apply to participatory spaces of type"
    end
    click_on "Save"

    within ".scoped_styles_container[data-key=\"bar\"] .constraints-editor" do
      expect(page).to have_content("Processes")
    end

    within ".scoped_styles_container[data-key=\"bar\"] .constraints-editor" do
      click_on "Delete"
    end

    within ".scoped_styles_container[data-key=\"bar\"] .constraints-editor" do
      expect(page).not_to have_content("Processes")
    end

    visit decidim_admin_decidim_awesome.config_path("#{var_name}s")

    within ".scoped_styles_container[data-key=\"bar\"] .constraints-editor" do
      expect(page).not_to have_content("Processes")
    end

    expect(Decidim::DecidimAwesome::AwesomeConfig.find_by(organization: organization, var: "#{var_name}_bar")).to be_present
    expect(Decidim::DecidimAwesome::AwesomeConfig.find_by(organization: organization, var: "#{var_name}_bar").constraints).not_to be_present
  end
end

shared_examples "extra css is added" do
  it "css is present" do
    expect(page.body).to have_content("body {background: red;}")
  end

  it "css is applied" do
    expect(page.execute_script("return window.getComputedStyle($('body')[0]).backgroundColor")).to eq("rgb(255, 0, 0)")
  end
end

shared_examples "no extra css is added" do
  it "css is no present" do
    expect(page.body).not_to have_content("body {background: red;}")
  end

  it "css is not applyied" do
    expect(page.execute_script("return window.getComputedStyle($('body')[0]).backgroundColor")).to eq(default_background_color)
  end
end

shared_examples "extra css is added" do
  it "css is present" do
    expect(page.body).to have_content("body {background: red;}")
  end

  it "css is applied" do
    expect(page.execute_script("return window.getComputedStyle($('body')[0]).backgroundColor")).to eq("rgb(255, 0, 0)")
  end
end

shared_examples "no extra css is added" do
  it "css is no present" do
    expect(page.body).not_to have_content("body {background: red;}")
  end

  it "css is not applyied" do
    expect(page.execute_script("return window.getComputedStyle($('body')[0]).backgroundColor")).to eq(default_background_color)
  end
end
