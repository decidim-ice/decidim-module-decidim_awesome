# frozen_string_literal: true

shared_context "with menu hacks params" do
  let(:organization) { create(:organization) }
  let(:context) do
    {
      current_user: create(:user, organization:),
      current_organization: organization
    }
  end
  let(:params) do
    {
      menu_id:,
      raw_label: label,
      url:,
      position:,
      target:,
      visibility:
    }
  end
  let(:menu_id) { menu_name.to_sym }
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
