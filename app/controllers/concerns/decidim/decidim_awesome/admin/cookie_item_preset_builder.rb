# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class CookieItemPresetBuilder
        PRESETS = {
          decidim_essential: [
            { name: "_session_id", type: "cookie", service: "decidim_essential", description: "session_id", expiration: "session" },
            { name: Decidim.consent_cookie_name, type: "cookie", service: "decidim_essential", description: "decidim_consent", expiration: "1 year" },
            { name: "remember_user_token", type: "cookie", service: "decidim_essential", description: "remember_user_token", expiration: "2 weeks" }
          ],
          matomo: [
            { name: "_pk_id", type: "cookie", service: "matomo", description: "matomo_pk_id", expiration: "13 months" },
            { name: "_pk_ses", type: "cookie", service: "matomo", description: "matomo_pk_ses", expiration: "30 minutes" },
            { name: "_pk_ref", type: "cookie", service: "matomo", description: "matomo_pk_ref", expiration: "6 months" },
            { name: "mtm_consent", type: "cookie", service: "matomo", description: "matomo_mtm_consent", expiration: "30 years" }
          ],
          google_analytics: [
            { name: "_ga", type: "cookie", service: "google_analytics", description: "ga_main", expiration: "2 years" },
            { name: "_gid", type: "cookie", service: "google_analytics", description: "ga_gid", expiration: "24 hours" },
            { name: "_gat", type: "cookie", service: "google_analytics", description: "ga_gat", expiration: "1 minute" },
            { name: "_ga_", type: "cookie", service: "google_analytics", description: "ga_property", expiration: "2 years" }
          ],
          google_tag_manager: [
            { name: "_gcl_au", type: "cookie", service: "google_tag_manager", description: "gtm_gcl_au", expiration: "3 months" },
            { name: "_gtm_debug", type: "cookie", service: "google_tag_manager", description: "gtm_debug", expiration: "session" },
            { name: "_dc_gtm_", type: "cookie", service: "google_tag_manager", description: "gtm_dc", expiration: "1 minute" }
          ],
          google_maps_embeds: [
            { name: "NID", type: "cookie", service: "google_maps_embeds", description: "maps_nid", expiration: "6 months" },
            { name: "1P_JAR", type: "cookie", service: "google_maps_embeds", description: "maps_1p_jar", expiration: "30 days" },
            { name: "CONSENT", type: "cookie", service: "google_maps_embeds", description: "maps_consent", expiration: "20 years" }
          ],
          openstreetmap_tiles: [
            { name: "_osm_location", type: "cookie", service: "openstreetmap_tiles", description: "osm_location", expiration: "persistent" },
            { name: "_osm_session", type: "cookie", service: "openstreetmap_tiles", description: "osm_session", expiration: "session" },
            { name: "_osm_totp_token", type: "cookie", service: "openstreetmap_tiles", description: "osm_totp_token", expiration: "session" }
          ],
          vimeo_embeds: [
            { name: "vuid", type: "cookie", service: "vimeo_embeds", description: "vimeo_vuid", expiration: "2 years" },
            { name: "player", type: "cookie", service: "vimeo_embeds", description: "vimeo_player", expiration: "1 year" }
          ],
          youtube_nocookie: [
            { name: "yt-remote-device-id", type: "local_storage", service: "youtube_nocookie", description: "yt_remote_device_id", expiration: "persistent" },
            { name: "yt-remote-connected-devices", type: "local_storage", service: "youtube_nocookie", description: "yt_remote_connected_devices", expiration: "persistent" },
            { name: "ytidb::LAST_RESULT_ENTRY_KEY", type: "local_storage", service: "youtube_nocookie", description: "ytidb_last_result_entry_key", expiration: "persistent" }
          ],
          facebook_pixel: [
            { name: "_fbp", type: "cookie", service: "facebook_pixel", description: "fbp", expiration: "3 months" },
            { name: "fr", type: "cookie", service: "facebook_pixel", description: "facebook_fr", expiration: "3 months" }
          ],
          linkedin_insight: [
            { name: "li_gc", type: "cookie", service: "linkedin_insight", description: "linkedin_li_gc", expiration: "6 months" },
            { name: "lidc", type: "cookie", service: "linkedin_insight", description: "linkedin_lidc", expiration: "24 hours" },
            { name: "UserMatchHistory", type: "cookie", service: "linkedin_insight", description: "linkedin_user_match_history", expiration: "30 days" }
          ],
          recaptcha: [
            { name: "_GRECAPTCHA", type: "cookie", service: "recaptcha", description: "recaptcha_grecaptcha", expiration: "6 months" },
            { name: "rc::a", type: "local_storage", service: "recaptcha", description: "recaptcha_rc_a", expiration: "persistent" },
            { name: "rc::c", type: "local_storage", service: "recaptcha", description: "recaptcha_rc_c", expiration: "session" }
          ],
          hcaptcha: [
            { name: "hcaptcha_session", type: "cookie", service: "hcaptcha", description: "hcaptcha_session", expiration: "session" },
            { name: "hc_accessibility", type: "local_storage", service: "hcaptcha", description: "hcaptcha_accessibility", expiration: "persistent" }
          ],
          cloudflare_turnstile: [
            { name: "__cf_bm", type: "cookie", service: "cloudflare_turnstile", description: "turnstile_cf_bm", expiration: "30 minutes" },
            { name: "_cfuvid", type: "cookie", service: "cloudflare_turnstile", description: "turnstile_cfuvid", expiration: "session" },
            { name: "cf_clearance", type: "cookie", service: "cloudflare_turnstile", description: "turnstile_cf_clearance", expiration: "30 minutes" }
          ],
          youtube_embeds: [
            { name: "VISITOR_INFO1_LIVE", type: "cookie", service: "youtube_embeds", description: "visitor_info1_live", expiration: "6 months" },
            { name: "YSC", type: "cookie", service: "youtube_embeds", description: "ysc", expiration: "session" },
            { name: "PREF", type: "cookie", service: "youtube_embeds", description: "pref", expiration: "8 months" },
            { name: "CONSENT", type: "cookie", service: "youtube_embeds", description: "consent", expiration: "20 years" }
          ],
          jitsi_meet: [
            { name: "amp_", type: "local_storage", service: "jitsi_meet", description: "jitsi_amp", expiration: "persistent" },
            { name: "amplitude_unset", type: "local_storage", service: "jitsi_meet", description: "jitsi_amplitude_unset", expiration: "persistent" },
            { name: "amplitude_unsent_identify", type: "local_storage", service: "jitsi_meet", description: "jitsi_amplitude_unsent_identify", expiration: "persistent" },
            { name: "language", type: "local_storage", service: "jitsi_meet", description: "jitsi_language", expiration: "persistent" },
            { name: "features/base/known-domains", type: "local_storage", service: "jitsi_meet", description: "jitsi_known_domains", expiration: "persistent" },
            { name: "features/base/settings", type: "local_storage", service: "jitsi_meet", description: "jitsi_settings", expiration: "persistent" },
            { name: "features/calendar-sync", type: "local_storage", service: "jitsi_meet", description: "jitsi_calendar_sync", expiration: "persistent" },
            { name: "features/dropbox", type: "local_storage", service: "jitsi_meet", description: "jitsi_dropbox", expiration: "persistent" },
            { name: "features/prejoin", type: "local_storage", service: "jitsi_meet", description: "jitsi_prejoin", expiration: "persistent" },
            { name: "features/recent-list", type: "local_storage", service: "jitsi_meet", description: "jitsi_recent_list", expiration: "persistent" },
            { name: "features/video-quality-persistent-storage", type: "local_storage", service: "jitsi_meet", description: "jitsi_video_quality", expiration: "persistent" },
            { name: "features/virtual-background", type: "local_storage", service: "jitsi_meet", description: "jitsi_virtual_background", expiration: "persistent" },
            { name: "endpointID", type: "local_storage", service: "jitsi_meet", description: "jitsi_endpoint_id", expiration: "persistent" },
            { name: "callStatsUserName", type: "local_storage", service: "jitsi_meet", description: "jitsi_callstats_username", expiration: "persistent" }
          ],
          graphiql: [
            { name: "graphiql:docExplorerOpen", type: "local_storage", service: "graphiql", description: "graphiql_doc_explorer_open", expiration: "persistent" },
            { name: "graphiql:editorFlex", type: "local_storage", service: "graphiql", description: "graphiql_editor_flex", expiration: "persistent" },
            { name: "graphiql:historyPaneOpen", type: "local_storage", service: "graphiql", description: "graphiql_history_pane_open", expiration: "persistent" },
            { name: "graphiql:queries", type: "local_storage", service: "graphiql", description: "graphiql_queries", expiration: "persistent" },
            { name: "graphiql:query", type: "local_storage", service: "graphiql", description: "graphiql_query", expiration: "persistent" },
            { name: "graphiql:tabState", type: "local_storage", service: "graphiql", description: "graphiql_tab_state", expiration: "persistent" }
          ],
          emoji_picker: [
            { name: "emojiPicker-recent", type: "local_storage", service: "emoji_picker", description: "emoji_picker_recent", expiration: "persistent" }
          ]
        }.freeze

        def initialize(form_builder, organization)
          @form_builder = form_builder
          @organization = organization
        end

        def presets
          PRESETS.map do |group_key, items|
            {
              key: group_key,
              label: I18n.t("cookie_item_presets.labels.#{group_key}",
                            scope: "decidim.decidim_awesome.admin.cookie_items",
                            count: items.count)
            }
          end
        end

        def find(group_key)
          PRESETS[group_key&.to_sym]
        end

        def build_forms(items)
          locales = @organization.available_locales
          items.map { |preset| build_form(preset, locales) }
        end

        private

        def build_form(preset, locales)
          service_label = I18n.t("cookie_item_presets.services.#{preset[:service]}",
                                 scope: "decidim.decidim_awesome.admin.cookie_items")
          description_label = I18n.t("cookie_item_presets.descriptions.#{preset[:description]}",
                                     scope: "decidim.decidim_awesome.admin.cookie_items")
          expiration_label = preset[:expiration].to_s

          @form_builder.from_params(
            name: preset[:name],
            type: preset[:type],
            service: locales.index_with { |_| service_label },
            description: locales.index_with { |_| description_label },
            expiration: locales.index_with { |_| expiration_label }
          )
        end
      end
    end
  end
end
