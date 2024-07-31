# frozen_string_literal: true

# spec/presenters/private_data_presenter_spec.rb

require "spec_helper"

module Decidim::DecidimAwesome
  RSpec.describe PrivateDataPresenter, type: :presenter do
    let(:participatory_space) { create(:participatory_process) }
    let(:component) { create(:proposal_component, participatory_space:) }
    let(:proposal) { create(:proposal, component:) }
    let(:proposal2) { create(:proposal, component:) }
    let(:proposal3) { create(:proposal, component:) }
    let(:modern_proposal) { create(:proposal, component:) }
    let!(:extra_fields) { create(:awesome_proposal_extra_fields, proposal:, private_body: "private") }
    let!(:extra_fields2) { create(:awesome_proposal_extra_fields, proposal: proposal2, private_body: "private") }
    let!(:extra_fields3) { create(:awesome_proposal_extra_fields, proposal: proposal3, private_body: "private") }
    let!(:modern_extra_fields) { create(:awesome_proposal_extra_fields, proposal: modern_proposal, private_body: nil) }
    let!(:external_extra_fields) { create(:awesome_proposal_extra_fields, private_body: "private") }
    let(:organization) { participatory_space.organization }
    let(:presenter) { described_class.new(component) }

    before do
      allow(::Decidim::DecidimAwesome).to receive(:private_data_expiration_time).and_return(3.months)
      # rubocop:disable Rails/SkipsModelValidations
      extra_fields.update_column(:private_body_updated_at, 4.months.ago.to_date)
      extra_fields2.update_column(:private_body_updated_at, 5.months.ago.to_date)
      extra_fields3.update_column(:private_body_updated_at, 6.months.ago.to_date)
      modern_extra_fields.update_column(:private_body_updated_at, 2.months.ago.to_date)
      external_extra_fields.update_column(:private_body_updated_at, 4.months.ago.to_date)
      # rubocop:enable Rails/SkipsModelValidations
    end

    describe "#name" do
      it "returns the formatted name" do
        expect(presenter.name).to eq("#{translated(participatory_space.title)} / #{translated(component.name)}")
      end
    end

    describe "#path" do
      it "returns the correct path" do
        expect(presenter.path).to eq("/processes/#{participatory_space.slug}/f/#{component.id}/proposals")
      end
    end

    describe "#total" do
      it "returns the correct count of proposals with old private_data" do
        expect(presenter.total).to eq("3")
      end
    end

    describe "#last_date" do
      it "returns the correct last updated date" do
        expect(presenter.last_date).to eq(4.months.ago.to_date)
      end
    end

    describe "#time_ago" do
      it "returns the correct time ago string" do
        allow(presenter).to receive(:time_ago_in_words).and_return("2 days")
        expect(presenter.time_ago).to eq(I18n.t("decidim.decidim_awesome.admin.maintenance.private_data.time_ago", time: "2 days"))
      end
    end

    describe "#destroyable?" do
      it "returns false if last_date is nil" do
        allow(presenter).to receive(:last_date).and_return(nil)
        expect(presenter).not_to be_destroyable
      end

      it "returns true if last_date is older than expiration time" do
        allow(presenter).to receive(:last_date).and_return(2.years.ago)
        expect(presenter).to be_destroyable
      end
    end

    describe "#locked?" do
      it "returns the correct locked status" do
        expect(presenter).not_to be_locked
      end
    end

    describe "#as_json" do
      it "returns the correct JSON representation" do
        expected_json = {
          id: component.id,
          name: "#{translated(participatory_space.title)} / #{translated(component.name)}",
          path: "/processes/#{participatory_space.slug}/f/#{component.id}/proposals",
          total: "3",
          last_date: 4.months.ago.to_date,
          time_ago: "4 months ago",
          locked: false,
          done: nil
        }
        expect(presenter.as_json).to eq(expected_json)
      end
    end

    describe "#done" do
      it "returns the loading spinner if locked" do
        allow(presenter).to receive(:locked?).and_return(true)
        expect(presenter.done).to eq('<span class="loading-spinner primary"></span>')
      end

      it "returns nil if destroyable" do
        allow(presenter).to receive(:destroyable?).and_return(true)
        expect(presenter.done).to be_nil
      end

      it "returns the nil if not destroyable" do
        allow(presenter).to receive(:destroyable?).and_return(false)
        expect(presenter.done).to be_nil
      end

      it "returns the correct done message if last_date is nil" do
        allow(presenter).to receive(:last_date).and_return(nil)
        expect(presenter.done).to eq("Done")
      end
    end
  end
end
