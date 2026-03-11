# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class CookieItemPresetBuilder
        PRESETS = {
          decidim_essential: [
            { name: "_session_id", type: "cookie", service: "decidim_essential", description: "session_id" },
            { name: Decidim.consent_cookie_name, type: "cookie", service: "decidim_essential", description: "decidim_consent" },
            { name: "remember_user_token", type: "cookie", service: "decidim_essential", description: "remember_user_token" }
          ],
          matomo: [
            { name: "_pk_id", type: "cookie", service: "matomo", description: "matomo_pk_id" },
            { name: "_pk_ses", type: "cookie", service: "matomo", description: "matomo_pk_ses" },
            { name: "_pk_ref", type: "cookie", service: "matomo", description: "matomo_pk_ref" },
            { name: "mtm_consent", type: "cookie", service: "matomo", description: "matomo_mtm_consent" }
          ],
          google_analytics: [
            { name: "_ga", type: "cookie", service: "google_analytics", description: "ga_main" },
            { name: "_gid", type: "cookie", service: "google_analytics", description: "ga_gid" },
            { name: "_gat", type: "cookie", service: "google_analytics", description: "ga_gat" },
            { name: "_ga_", type: "cookie", service: "google_analytics", description: "ga_property" }
          ],
          google_tag_manager: [
            { name: "_gcl_au", type: "cookie", service: "google_tag_manager", description: "gtm_gcl_au" },
            { name: "_gtm_debug", type: "cookie", service: "google_tag_manager", description: "gtm_debug" },
            { name: "_dc_gtm_", type: "cookie", service: "google_tag_manager", description: "gtm_dc" }
          ],
          google_maps_embeds: [
            { name: "NID", type: "cookie", service: "google_maps_embeds", description: "maps_nid" },
            { name: "1P_JAR", type: "cookie", service: "google_maps_embeds", description: "maps_1p_jar" },
            { name: "CONSENT", type: "cookie", service: "google_maps_embeds", description: "maps_consent" }
          ],
          openstreetmap_tiles: [
            { name: "_osm_location", type: "cookie", service: "openstreetmap_tiles", description: "osm_location" },
            { name: "_osm_session", type: "cookie", service: "openstreetmap_tiles", description: "osm_session" },
            { name: "_osm_totp_token", type: "cookie", service: "openstreetmap_tiles", description: "osm_totp_token" }
          ],
          vimeo_embeds: [
            { name: "vuid", type: "cookie", service: "vimeo_embeds", description: "vimeo_vuid" },
            { name: "player", type: "cookie", service: "vimeo_embeds", description: "vimeo_player" }
          ],
          youtube_nocookie: [
            { name: "yt-remote-device-id", type: "local_storage", service: "youtube_nocookie", description: "yt_remote_device_id" },
            { name: "yt-remote-connected-devices", type: "local_storage", service: "youtube_nocookie", description: "yt_remote_connected_devices" },
            { name: "ytidb::LAST_RESULT_ENTRY_KEY", type: "local_storage", service: "youtube_nocookie", description: "ytidb_last_result_entry_key" }
          ],
          facebook_pixel: [
            { name: "_fbp", type: "cookie", service: "facebook_pixel", description: "fbp" },
            { name: "fr", type: "cookie", service: "facebook_pixel", description: "facebook_fr" }
          ],
          linkedin_insight: [
            { name: "li_gc", type: "cookie", service: "linkedin_insight", description: "linkedin_li_gc" },
            { name: "lidc", type: "cookie", service: "linkedin_insight", description: "linkedin_lidc" },
            { name: "UserMatchHistory", type: "cookie", service: "linkedin_insight", description: "linkedin_user_match_history" }
          ],
          recaptcha: [
            { name: "_GRECAPTCHA", type: "cookie", service: "recaptcha", description: "recaptcha_grecaptcha" },
            { name: "rc::a", type: "local_storage", service: "recaptcha", description: "recaptcha_rc_a" },
            { name: "rc::c", type: "local_storage", service: "recaptcha", description: "recaptcha_rc_c" }
          ],
          hcaptcha: [
            { name: "hcaptcha_session", type: "cookie", service: "hcaptcha", description: "hcaptcha_session" },
            { name: "hc_accessibility", type: "local_storage", service: "hcaptcha", description: "hcaptcha_accessibility" }
          ],
          cloudflare_turnstile: [
            { name: "__cf_bm", type: "cookie", service: "cloudflare_turnstile", description: "turnstile_cf_bm" },
            { name: "_cfuvid", type: "cookie", service: "cloudflare_turnstile", description: "turnstile_cfuvid" },
            { name: "cf_clearance", type: "cookie", service: "cloudflare_turnstile", description: "turnstile_cf_clearance" }
          ],
          youtube_embeds: [
            { name: "VISITOR_INFO1_LIVE", type: "cookie", service: "youtube_embeds", description: "visitor_info1_live" },
            { name: "YSC", type: "cookie", service: "youtube_embeds", description: "ysc" },
            { name: "PREF", type: "cookie", service: "youtube_embeds", description: "pref" },
            { name: "CONSENT", type: "cookie", service: "youtube_embeds", description: "consent" }
          ],
          jitsi_meet: [
            { name: "amp_", type: "local_storage", service: "jitsi_meet", description: "jitsi_amp" },
            { name: "amplitude_unset", type: "local_storage", service: "jitsi_meet", description: "jitsi_amplitude_unset" },
            { name: "amplitude_unsent_identify", type: "local_storage", service: "jitsi_meet", description: "jitsi_amplitude_unsent_identify" },
            { name: "language", type: "local_storage", service: "jitsi_meet", description: "jitsi_language" },
            { name: "features/base/known-domains", type: "local_storage", service: "jitsi_meet", description: "jitsi_known_domains" },
            { name: "features/base/settings", type: "local_storage", service: "jitsi_meet", description: "jitsi_settings" },
            { name: "features/calendar-sync", type: "local_storage", service: "jitsi_meet", description: "jitsi_calendar_sync" },
            { name: "features/dropbox", type: "local_storage", service: "jitsi_meet", description: "jitsi_dropbox" },
            { name: "features/prejoin", type: "local_storage", service: "jitsi_meet", description: "jitsi_prejoin" },
            { name: "features/recent-list", type: "local_storage", service: "jitsi_meet", description: "jitsi_recent_list" },
            { name: "features/video-quality-persistent-storage", type: "local_storage", service: "jitsi_meet", description: "jitsi_video_quality" },
            { name: "features/virtual-background", type: "local_storage", service: "jitsi_meet", description: "jitsi_virtual_background" },
            { name: "endpointID", type: "local_storage", service: "jitsi_meet", description: "jitsi_endpoint_id" },
            { name: "callStatsUserName", type: "local_storage", service: "jitsi_meet", description: "jitsi_callstats_username" }
          ],
          graphiql: [
            { name: "graphiql:docExplorerOpen", type: "local_storage", service: "graphiql", description: "graphiql_doc_explorer_open" },
            { name: "graphiql:editorFlex", type: "local_storage", service: "graphiql", description: "graphiql_editor_flex" },
            { name: "graphiql:historyPaneOpen", type: "local_storage", service: "graphiql", description: "graphiql_history_pane_open" },
            { name: "graphiql:queries", type: "local_storage", service: "graphiql", description: "graphiql_queries" },
            { name: "graphiql:query", type: "local_storage", service: "graphiql", description: "graphiql_query" },
            { name: "graphiql:tabState", type: "local_storage", service: "graphiql", description: "graphiql_tab_state" }
          ],
          emoji_picker: [
            { name: "emojiPicker-recent", type: "local_storage", service: "emoji_picker", description: "emoji_picker_recent" }
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

          @form_builder.from_params(
            name: preset[:name],
            type: preset[:type],
            service: locales.index_with { |_| service_label },
            description: locales.index_with { |_| description_label }
          )
        end
      end
    end
  end
end
