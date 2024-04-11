# frozen_string_literal: true

shared_context "with custom redirects params" do
  let(:organization) { create(:organization) }
  let(:context) do
    {
      current_user: create(:user, organization:),
      current_organization: organization
    }
  end
  let(:params) do
    {
      origin:,
      destination:,
      active:,
      pass_query:
    }
  end
  let(:attributes) do
    [
      origin,
      {
        "destination" => destination,
        "active" => active,
        "pass_query" => pass_query
      }
    ]
  end
  let(:origin) { "/origin" }
  let(:destination) { "/processes" }
  let(:active) { true }
  let(:pass_query) { true }

  let(:another_params) do
    {
      allow_images_in_editors: true,
      allow_videos_in_editors: true
    }
  end
  let(:form) do
    Decidim::DecidimAwesome::Admin::CustomRedirectForm.from_params(params).with_context(context)
  end
  let(:another_form) do
    Decidim::DecidimAwesome::Admin::ConfigForm.from_params(another_params).with_context(context)
  end
  let(:another_config) { Decidim::DecidimAwesome::Admin::UpdateConfig.new(another_form) }
end
