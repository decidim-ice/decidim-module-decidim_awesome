# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  module Admin
    describe HashcashController do
      routes { Decidim::DecidimAwesome::AdminEngine.routes }

      let(:user) { create(:user, :confirmed, :admin, organization:) }
      let(:organization) { create(:organization) }
      let!(:stamp) { ActiveHashcash::Stamp.create!(ip_address: "10.0.0.1", request_path: "/users/sign_in", counter: "123", rand: "asdf", resource: "localhost", bits: 20, date: Time.current, ext: "", version: 1) }

      before do
        request.env["decidim.current_organization"] = user.organization
        sign_in user, scope: :user
      end

      describe "GET #index" do
        it "returns http success" do
          get(:index)
          expect(response).to have_http_status(:success)

          expect(controller.helpers.stamps).to eq([stamp])
        end
      end

      describe "GET #ip_addresses" do
        it "returns http success" do
          get(:ip_addresses)
          expect(controller.helpers.addresses).to eq("10.0.0.1" => 1)
          expect(response).to have_http_status(:success)
        end
      end

      describe "GET #show" do
        it "returns http success" do
          get(:show, params: { id: stamp.id })
          expect(controller.helpers.stamp).to eq(stamp)
          expect(response).to have_http_status(:success)
        end
      end
    end
  end
end
