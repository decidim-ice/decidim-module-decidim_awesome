# frozen_string_literal: true

require "spec_helper"
require "decidim/decidim_awesome/test/shared_examples/editor_examples"

describe "Admin edits proposal title" do
  let(:manifest_name) { "proposals" }
  let(:organization) { participatory_process.organization }
  let!(:user) { create(:user, :admin, :confirmed, organization:) }
  let!(:proposal) { create(:proposal, :official, component:) }
  let(:title_max_caps_percent) { 20 }
  let(:title_max_marks_together) { 2 }
  let(:title_start_with_caps) { true }
  let!(:validate_title_max_caps_percent) { create(:awesome_config, organization:, var: :validate_title_max_caps_percent, value: title_max_caps_percent) }
  let!(:validate_title_max_marks_together) { create(:awesome_config, organization:, var: :validate_title_max_marks_together, value: title_max_marks_together) }
  let!(:validate_title_start_with_caps) { create(:awesome_config, organization:, var: :validate_title_start_with_caps, value: title_start_with_caps) }

  include_context "when managing a component as an admin"

  before do
    visit_component_admin

    find("a.action-icon--edit-proposal").click
  end

  shared_examples "title validation" do |type, context_text, value, validation_value, error_message|
    context "when title #{context_text}" do
      it "cannot be saved" do
        change_title_and_save(value)

        expect(page).to have_content(error_message)
      end

      context "and is allowed" do
        let(:"title_#{type}") { validation_value }

        it "is valid" do
          change_title_and_save(value)

          expect(page).to have_content("Proposal successfully updated")
        end
      end
    end
  end

  it_behaves_like "title validation", :max_caps_percent, "has too much caps", "A SCREAMING PIECE of text", 100, "Is using too many capital letters"
  it_behaves_like "title validation", :max_marks_together, "has too many marks", "I am screaming!!?", 3, "is using too many consecutive punctuation marks"
  it_behaves_like "title validation", :start_with_caps, "does not start with a capital letter", "a text starting with lowercase", false, "must start with a capital letter"

  private

  def change_title_and_save(value)
    find_by_id("proposal_title_en").set(value)
    click_on "Update"
  end
end
