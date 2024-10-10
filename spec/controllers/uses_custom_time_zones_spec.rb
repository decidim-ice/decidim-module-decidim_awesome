# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ApplicationController do
    let(:organization) { create(:organization, time_zone:) }
    let(:user) { create(:user, :confirmed, organization:, extended_data: { time_zone: user_time_zone }) }
    let(:user_time_zone) { "London" }
    let(:enable_user_time_zone) { true }

    before do
      request.env["decidim.current_organization"] = organization
      allow(controller).to receive(:current_user) { user }
      allow(Decidim::DecidimAwesome).to receive(:config).and_return(user_timezone: enable_user_time_zone)
    end

    shared_examples "user time zone is used" do
      it "Time uses user zone within the controller scope" do
        controller.use_user_time_zone do
          expect(Time.zone.name).to eq("London")
        end
      end

      context "when user time zone is disabled" do
        let(:enable_user_time_zone) { false }

        it "Time uses UTC zone within the controller scope" do
          controller.use_user_time_zone do
            expect(Time.zone.name).to eq("UTC")
          end
        end
      end
    end

    context "when time zone is UTC" do
      let(:time_zone) { "UTC" }

      it "controller uses UTC" do
        expect(controller.organization_time_zone).to eq("UTC")
        expect(controller.user_time_zone).to eq("London")
      end

      it_behaves_like "user time zone is used"

      it "Time uses UTC outside the controller scope" do
        expect(Time.zone.name).to eq("UTC")
      end
    end

    context "when time zone is non-UTC" do
      let(:time_zone) { "Hawaii" }

      it "controller uses the custom time zone" do
        expect(controller.organization_time_zone).to eq("Hawaii")
      end

      it_behaves_like "user time zone is used", "Hawaii"

      it "Time uses UTC outside the controller scope" do
        expect(Time.zone.name).to eq("UTC")
      end
    end

    context "when Rails is non-UTC", tz: "Azores" do
      context "and organizations uses UTC" do
        let(:time_zone) { "UTC" }

        it "controller uses UTC" do
          expect(controller.organization_time_zone).to eq("UTC")
        end

        it_behaves_like "user time zone is used"

        it "Time uses Rails timezone outside the controller scope" do
          expect(Time.zone.name).to eq("Azores")
        end
      end

      context "and organizations uses non-UTC" do
        let(:time_zone) { "Hawaii" }

        it "controller uses UTC" do
          expect(controller.organization_time_zone).to eq("Hawaii")
        end

        it_behaves_like "user time zone is used", "Hawaii"

        it "Time uses Rails timezone outside the controller scope" do
          expect(Time.zone.name).to eq("Azores")
        end
      end
    end
  end
end
