# frozen_string_literal: true

Deface::Override.new(virtual_path: "layouts/decidim/_head",
                     name: "legacy_awesome_scripts",
                     insert_after: 'erb[loud]:contains(\'javascript_pack_tag "decidim_core"\')') do
  # NOTE THAT THIS ONLY APPLIES TO DECIDIM 0.26. This will be ignored in 0.27
  '
	<%= javascript_pack_tag "decidim_decidim_awesome", defer: false %>
	<%= javascript_pack_tag("decidim_decidim_awesome_custom_fields") if Decidim::DecidimAwesome.enabled?(:proposal_custom_fields) %>
  <% if show_public_intergram? %>
    <%= render partial: "layouts/decidim/decidim_awesome/intergram_widget", locals: { settings: organization_awesome_config[:intergram_for_public_settings] } %>
  <% end %>
	'
end
