# frozen_string_literal: true

shared_examples "a blank component" do
  describe "GET settings" do
    it "redirects to settings" do
      get :settings, params: { component_id: component }
      expect(response).to have_http_status(:redirect)
      expect(response.location).to include("#{component.id}/edit")
    end
  end
end
