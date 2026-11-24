# frozen_string_literal: true

shared_examples "needs the HTML code editor" do
  context "when the user manages a participatory space" do
    let(:user) { create(:process_admin, :confirmed, participatory_process: create(:participatory_process, organization:)) }

    it "is allowed" do
      action

      expect(response).to have_http_status(:success)
    end
  end

  context "when the user is not an admin" do
    let(:user) { create(:user, :confirmed, organization:) }

    it "is not allowed" do
      action

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  context "when the code editor is not enabled in the organization" do
    let(:enabled) { false }

    it "is not found" do
      expect { action }.to raise_error(ActionController::RoutingError)
    end
  end

  context "when the code editor applies nowhere" do
    let!(:constraint) { create(:config_constraint, awesome_config: html_code_editor, settings: { "participatory_space_manifest" => "none" }) }

    it "is not found" do
      expect { action }.to raise_error(ActionController::RoutingError)
    end
  end
end
