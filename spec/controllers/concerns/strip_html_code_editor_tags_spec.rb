# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ApplicationController do
    controller do
      def create
        render json: params.to_unsafe_h["proposal"]
      end
    end

    let(:organization) { create(:organization) }
    let!(:html_code_editor) { create(:awesome_config, organization:, var: :html_code_editor, value: enabled) }
    let(:enabled) { true }
    let(:body) { "<p>Longer opening hours</p><style>header { display: none; }</style>" }
    let(:params) { { proposal: { title: "Tom & Jerry", body:, notes: ["<STYLE>a { color: red; }</STYLE>Weekends"] } } }
    let(:received) { post(:create, params:).parsed_body }

    before do
      request.env["decidim.current_organization"] = organization
    end

    it "removes the extra tags from the content sent through the public site" do
      expect(received["body"]).to eq("<p>Longer opening hours</p>header { display: none; }")
      expect(received["notes"]).to eq(["a { color: red; }Weekends"])
    end

    it "leaves the rest of the content as it was sent" do
      expect(received["title"]).to eq("Tom & Jerry")
    end

    context "when the code editor is not enabled in the organization" do
      let(:enabled) { false }

      it "leaves the content as it was sent" do
        expect(received["body"]).to eq(body)
      end
    end

    context "when the code editor applies nowhere" do
      let!(:constraint) { create(:config_constraint, awesome_config: html_code_editor, settings: { "participatory_space_manifest" => "none" }) }

      it "leaves the content as it was sent" do
        expect(received["body"]).to eq(body)
      end
    end

    context "when the extra tags are nested" do
      let(:body) { "<details><details>Opening</details> hours</details>" }

      before do
        allow(Decidim::DecidimAwesome).to receive(:html_code_editor_allowed_tags).and_return(%w(details))
      end

      it "removes all of them" do
        expect(received["body"]).to eq("Opening hours")
      end
    end
  end
end
