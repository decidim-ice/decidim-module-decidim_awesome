# frozen_string_literal: true

shared_context "with admin accountability helpers" do
  def search_by_date(start_date, end_date)
    within(".filters__section") do
      fill_in_datepicker :q_created_at_gteq_date, with: start_date.strftime("%d/%m/%Y") if start_date.present?
      fill_in_datepicker :q_created_at_lteq_date, with: end_date.strftime("%d/%m/%Y") if end_date.present?
      find("*[type=submit]").click
    end
  end

  def apply_filter(options, filter)
    within(".filters__section") do
      click_on "Filter"
      click_on options
      click_on filter
    end
  end
end
