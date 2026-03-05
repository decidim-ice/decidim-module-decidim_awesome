# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      module HasCookieItemsPresets
        extend ActiveSupport::Concern

        COOKIE_ITEM_PRESETS = {
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

        def cookie_item_presets
          COOKIE_ITEM_PRESETS.map do |group_key, items|
            {
              key: group_key,
              label: t("cookie_item_presets.labels.#{group_key}", scope: "decidim.decidim_awesome.admin.cookie_items", count: items.count)
            }
          end
        end

        def find_preset_items(group_key)
          COOKIE_ITEM_PRESETS[group_key&.to_sym]
        end

        def build_preset_forms(items)
          locales = current_organization.available_locales
          items.map { |preset| build_preset_form(preset, locales) }
        end

        def build_preset_form(preset, locales)
          service_label = t("cookie_item_presets.services.#{preset[:service]}", scope: "decidim.decidim_awesome.admin.cookie_items")
          description_label = t("cookie_item_presets.descriptions.#{preset[:description]}", scope: "decidim.decidim_awesome.admin.cookie_items")

          form(CookieItemForm).from_params(
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
