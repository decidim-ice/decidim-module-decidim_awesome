# frozen_string_literal: true

shared_examples "edits box label inline" do |after_test, key|
  let(:data) { '[{"type":"text","label":"Short Name","subtype":"text","className":"form-control","name":"text-1476748004559"}]' }

  it "updates the label" do
    link = find("[data-key=\"#{key}\"] a.awesome-auto-edit", match: :first)
    expect(page).not_to have_css("input.awesome-auto-edit")
    link.click
    expect(page).to have_css("input.awesome-auto-edit")
    find("body").click
    expect(page).not_to have_css("input.awesome-auto-edit")
    link.click
    input = find("[data-key=\"#{key}\"] input.awesome-auto-edit")
    input.fill_in with: "A new làbel\n"
    sleep 1
    expect(page).not_to have_css("input.awesome-auto-edit")
    expect(page).to have_css('span.awesome-auto-edit[data-key="a_new_label"]')

    case after_test
    when :css
      sleep 1
      page.execute_script("document.querySelector(\"[data-key=a_new_label] .CodeMirror\").CodeMirror.setValue(\"body {background: lilac;}\");")
      find("*[type=submit]").click

      expect(page).to have_admin_callout("updated successfully")
      expect(page).to have_content("body {background: lilac;}")
    when :fields
      expect(page).to have_content("Full Name")
      sleep 2
      page.execute_script("$('.proposal_custom_fields_container[data-key=\"a_new_label\"] .proposal_custom_fields_editor')[0].FormBuilder.actions.setData(#{data})")
      find("*[type=submit]").click
      expect(page).to have_content("Short Name")
    end
  end
end
