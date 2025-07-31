# frozen_string_literal: true

Decidim::DecidimAwesome.configure do |config|
  if ENV.fetch("FEATURES", nil) == "disabled"
    [
      :allow_images_in_editors,
      :allow_videos_in_editors,
      :allow_images_in_proposals,
      :auto_save_forms,
      :user_timezone,
      :force_authorization_after_login,
      :authorization_groups,
      :admins_available_authorizations,
      :intergram_for_admins,
      :intergram_for_public,
      :scoped_styles,
      :scoped_admin_styles,
      :proposal_custom_fields,
      :proposal_private_custom_fields,
      :menu,
      :mobile_menu,
      :home_content_block_menu,
      :scoped_admins,
      :custom_redirects,
      :validate_title_min_length,
      :validate_title_max_caps_percent,
      :validate_title_max_marks_together,
      :validate_title_start_with_caps,
      :validate_body_min_length,
      :validate_body_max_caps_percent,
      :validate_body_max_marks_together,
      :validate_body_start_with_caps,
      :weighted_proposal_voting,
      :additional_proposal_sortings,
      :allow_limiting_amendments,
      :proposal_private_custom_fields,
      :hashcash_signup,
      :hashcash_login
    ].each do |conf|
      config.send("#{conf}=", :disabled)
    end

    config.disabled_components = [:awesome_map, :awesome_iframe]
  end
end
