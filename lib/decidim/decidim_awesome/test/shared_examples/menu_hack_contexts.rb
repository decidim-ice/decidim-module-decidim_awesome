# frozen_string_literal: true

shared_context "with menu hacks params" do
  let(:organization) { create(:organization) }
  let(:context) do
    {
      current_user: create(:user, organization: organization),
      current_organization: organization
    }
  end
  let(:params) do
    {
      raw_label: label,
      url: url,
      position: position,
      target: target,
      visibility: visibility
    }
  end
  let(:attributes) do
    {
      "label" => label,
      "url" => url,
      "position" => position,
      "target" => target,
      "visibility" => visibility
    }
  end
  let(:label) do
    {
      "en" => "Menu english",
      "ca" => "Menu catalan"
    }
  end
  let(:url) { "/some-path" }
  let(:position) { 2 }
  let(:target) { "_blank" }
  let(:visibility) { "hidden" }
  let(:menu_name) { "menu" }

  let(:another_params) do
    {
      allow_images_in_full_editor: true,
      allow_images_in_small_editor: true
    }
  end
  let(:form) do
    Decidim::DecidimAwesome::Admin::MenuForm.from_params(params).with_context(context)
  end
  let(:another_form) do
    Decidim::DecidimAwesome::Admin::ConfigForm.from_params(another_params).with_context(context)
  end
  let(:another_config) { Decidim::DecidimAwesome::Admin::UpdateConfig.new(another_form) }
end

shared_examples "forbids disabled feature" do
  let(:feature) { :menu }
  let(:features) { [feature] }
  before do
    features.each do |feat|
      allow(Decidim::DecidimAwesome.config).to receive(feat).and_return(:disabled)
    end
  end

  it "redirects with error" do
    action

    expect(flash[:alert]).not_to be_empty
    expect(response).to redirect_to("/admin/")
  end
end
