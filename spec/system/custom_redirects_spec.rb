# frozen_string_literal: true

require "spec_helper"

describe "Custom Redirections", type: :system do
  let(:organization) { create :organization }
  let(:origin) { "/send-me-somewhere" }
  let(:destination) { "/canary-islands" }
  let(:active) { true }
  let(:pass_query) { true }
  let!(:config) { create :awesome_config, organization: organization, var: :custom_redirects, value: redirections }
  let(:redirections) do
    {
      origin => { destination: destination, active: active, pass_query: pass_query },
      "/a-cheaper-place" => { destination: "/lloret", active: true, pass_query: false }
    }
  end

  before do
    # ErrorController is only called when in production mode
    unless ENV["SHOW_EXCEPTIONS"]
      allow(Rails.application).to \
        receive(:env_config).with(no_args).and_wrap_original do |m, *|
          m.call.merge(
            "action_dispatch.show_exceptions" => true,
            "action_dispatch.show_detailed_exceptions" => false
          )
        end
    end

    switch_to_host(organization.host)
  end

  context "when no redirections" do
    let(:redirections) { nil }

    it_behaves_like "a 404 page" do
      let(:target_path) { origin }
    end
  end

  context "when redirection not configured" do
    it_behaves_like "a 404 page" do
      let(:target_path) { "/catch-me-if-you-can" }
    end
  end

  context "when redirection exists" do
    it "redirects to destination" do
      visit origin

      expect(page).to have_current_path(destination)
    end

    context "when inactive" do
      let(:active) { false }

      it_behaves_like "a 404 page" do
        let(:target_path) { origin }
      end
    end

    context "when query string active" do
      let(:query) { "passengers=2&dogs=1" }
      let(:goto) { "#{origin}?#{query}" }

      it "passes query string to destination" do
        visit goto

        expect(page).to have_current_path("#{destination}?#{query}")
        expect(page).not_to have_current_path(destination)
      end

      context "when destination has already a query string" do
        let(:destination) { "/canary-islands?island=la-palma" }

        it "appends query string to destination" do
          visit goto

          expect(page).to have_current_path("#{destination}&#{query}")
        end

        context "when query string inactive" do
          let(:pass_query) { false }

          it "do not pass the query string" do
            visit goto

            expect(page).to have_current_path(destination)
          end
        end
      end
    end

    context "when origin is malformed" do
      let(:goto) { "#{origin.upcase} " }

      it "reaches destination anyway" do
        visit goto

        expect(page).to have_current_path(destination)
      end
    end
  end
end
