# frozen_string_literal: true

shared_examples "edits box label inline" do |test_case, key|
  let(:data) { '[{"type":"text","label":"Short Name","subtype":"text","className":"form-control","name":"text-1476748004559"}]' }

  it "updates the label when no changes" do
    link = find("[data-key=#{key}] a.awesome-auto-edit", match: :first)
    expect(page).not_to have_css("input.awesome-auto-edit")
    link.click
    expect(page).to have_css("input.awesome-auto-edit")
    find("body").click
    expect(page).not_to have_css("input.awesome-auto-edit")
    link.click
    input = find("[data-key=#{key}] input.awesome-auto-edit")
    input.fill_in with: "A new làbel\n"
    sleep 1
    expect(page).not_to have_css("input.awesome-auto-edit")
    expect(page).to have_css("span.awesome-auto-edit[data-key=a_new_label]")

    find("*[type=submit]").click
    case test_case
    when :css
      expect(page).to have_content("body {background: red;}")
    when :fields
      expect(page).to have_content("Occupation")
      expect(page).to have_content("Street Sweeper")
      expect(page).not_to have_content("Short Bio")
    when :admins
      expect(page).not_to have_content(user.name.to_s)
      expect(page).to have_content(user2.name.to_s)
      expect(page).to have_content(user3.name.to_s)
    end
    expect(page).to have_css("span.awesome-auto-edit[data-key=a_new_label]")
    expect(page).not_to have_css("span.awesome-auto-edit[data-key=#{key}]")
  end

  it "updates the label with previous changes" do
    case test_case
    when :css
      sleep 1
      page.execute_script("document.querySelector(\"[data-key=#{key}] .CodeMirror\").CodeMirror.setValue(\"div {background: brown;}\");")
    when :fields
      sleep 2
      page.execute_script("$('.proposal_custom_fields_container[data-key=#{key}] .proposal_custom_fields_editor')[0].FormBuilder.actions.setData(#{data})")
    when :admins
      sleep 1
      page.execute_script("$('.multiusers-select:first').append(new Option('#{user.name}', #{user.id}, true, true)).trigger('change');")
    end

    link = find("[data-key=#{key}] a.awesome-auto-edit", match: :first)
    expect(page).not_to have_css("input.awesome-auto-edit")
    link.click
    expect(page).to have_css("input.awesome-auto-edit")
    find("body").click
    expect(page).not_to have_css("input.awesome-auto-edit")
    link.click
    input = find("[data-key=#{key}] input.awesome-auto-edit")
    input.fill_in with: "A new làbel\n"
    sleep 1
    expect(page).not_to have_css("input.awesome-auto-edit")
    expect(page).to have_css("span.awesome-auto-edit[data-key=a_new_label]")

    find("*[type=submit]").click
    case test_case
    when :css
      expect(page).to have_admin_callout("updated successfully")
      expect(page).to have_content("div {background: brown;}")
    when :fields
      expect(page).to have_content("Short Name")
    when :admins
      expect(page).to have_content(user.name.to_s)
      expect(page).to have_content(user2.name.to_s)
      expect(page).to have_content(user3.name.to_s)
    end
    expect(page).to have_css("span.awesome-auto-edit[data-key=a_new_label]")
    expect(page).not_to have_css("span.awesome-auto-edit[data-key=#{key}]")
  end

  it "updates the label with post changes" do
    link = find("[data-key=#{key}] a.awesome-auto-edit", match: :first)
    expect(page).not_to have_css("input.awesome-auto-edit")
    link.click
    expect(page).to have_css("input.awesome-auto-edit")
    find("body").click
    expect(page).not_to have_css("input.awesome-auto-edit")
    link.click
    input = find("[data-key=#{key}] input.awesome-auto-edit")
    input.fill_in with: "A new làbel\n"
    sleep 1
    expect(page).not_to have_css("input.awesome-auto-edit")
    expect(page).to have_css("span.awesome-auto-edit[data-key=a_new_label]")

    case test_case
    when :css
      sleep 2
      page.execute_script('document.querySelector("[data-key=a_new_label] .CodeMirror").CodeMirror.setValue("body {background: lilac;}");')
      find("*[type=submit]").click
      expect(page).to have_admin_callout("updated successfully")
      expect(page).to have_content("body {background: lilac;}")
    when :fields
      expect(page).to have_content("Full Name")
      sleep 2
      page.execute_script("$('.proposal_custom_fields_container[data-key=a_new_label] .proposal_custom_fields_editor')[0].FormBuilder.actions.setData(#{data})")
      find("*[type=submit]").click
      expect(page).to have_content("Short Name")
    when :admins
      page.execute_script("$('.multiusers-select:first').append(new Option('#{user.name}', #{user.id}, true, true)).trigger('change');")
      find("*[type=submit]").click
      expect(page).to have_content(user.name.to_s)
      expect(page).to have_content(user2.name.to_s)
      expect(page).to have_content(user3.name.to_s)
    end
    expect(page).to have_css("span.awesome-auto-edit[data-key=a_new_label]")
    expect(page).not_to have_css("span.awesome-auto-edit[data-key=#{key}]")
  end
end
