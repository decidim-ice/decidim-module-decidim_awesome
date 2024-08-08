# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    include ActiveSupport::Configurable

    autoload :Config, "decidim/decidim_awesome/config"
    autoload :SystemChecker, "decidim/decidim_awesome/system_checker"
    autoload :ContextAnalyzers, "decidim/decidim_awesome/context_analyzers"
    autoload :MenuHacker, "decidim/decidim_awesome/menu_hacker"
    autoload :CustomFields, "decidim/decidim_awesome/custom_fields"
    autoload :VotingManifest, "decidim/decidim_awesome/voting_manifest"
    autoload :Lock, "decidim/decidim_awesome/lock"
    autoload :TranslatedCustomFieldsType, "decidim/decidim_awesome/api/types/translated_custom_fields_type"
    autoload :LocalizedCustomFieldsType, "decidim/decidim_awesome/api/types/localized_custom_fields_type"

    # Awesome coms with some components for participatory spaces
    # Currently :awesome_map and :awesome_iframe, list them here
    # if you wan to disable them
    # NOTE if you have spaces with some of these components already configured
    # and then they are deactivated, it will break you application as there will be
    # references in the database
    #
    # use only symbols here
    config_accessor :disabled_components do
      [
        # :awesome_map,
        # :awesome_iframe
      ]
    end

    # Boolean configuration options
    #
    # Default values for configuration options:
    #   true  => always true but admins can still restrict its scope
    #   false => default false, admins can turn it true
    #   :disabled => false and non available, hidden from admins
    config_accessor :allow_images_in_full_editor do
      false
    end

    config_accessor :allow_images_in_small_editor do
      false
    end

    config_accessor :allow_images_in_proposals do
      false
    end

    config_accessor :use_markdown_editor do
      false
    end

    config_accessor :allow_images_in_markdown_editor do
      false
    end

    # used to save forms in localstorage
    config_accessor :auto_save_forms do
      false
    end

    # Live chat widget linked to Telegram account or group
    # In the admin side only
    config_accessor :intergram_for_admins do
      false
    end

    # In the public side only
    config_accessor :intergram_for_public do
      false
    end

    # Configuration options to handle different validations in proposals
    # (maybe in the future will apply to other places)
    # Set it to :disabled if you don't want to use this feature
    config_accessor :validate_title_min_length do
      15
    end

    config_accessor :validate_title_max_caps_percent do
      25
    end

    config_accessor :validate_title_max_marks_together do
      1
    end

    config_accessor :validate_title_start_with_caps do
      true
    end

    config_accessor :validate_body_min_length do
      15
    end

    config_accessor :validate_body_max_caps_percent do
      25
    end

    config_accessor :validate_body_max_marks_together do
      1
    end

    config_accessor :validate_body_start_with_caps do
      true
    end

    # This transforms the proposal voting into a weighted voting
    # Different processors can be registered and configured in the component's settings
    # Each processor must account for a cell to display how to vote and a cell to display the results
    config_accessor :weighted_proposal_voting do
      true
    end

    # Additional sorting methods for proposals
    # this setting also stores the selected sorting method in the user's session
    config_accessor :additional_proposal_sortings do
      [
        :supported_first,
        :supported_last,
        :az,
        :za
      ]
    end

    # Allows admins to limit the amount of pending amendments to (currently) one per proposal before it's accepted.
    # Once a pending amendment is accepted, a new on can be created.
    # Note that this does not limit the number of amendment per se, the admin has to set the limit in the proposal's component configuration.
    # set to :disable to will prevent admins to set an amendment's limit in the proposal's component configuration.
    # if set to "true" the checkbox will be checked by default
    # if set to "false" the checkbox will be unchecked by default
    config_accessor :allow_limiting_amendments do
      false
    end

    # allows admins to created specific CSS snippets affecting only some specific parts
    # Valid values differ a little from the previous convention:
    #   :disabled => false and non available, hidden from admins
    #   Hash => hash of different css text, each key will be used for the contraints
    # Admins create this hash dynamically but some pre-defined css boxes can be created here as:
    #   {
    #      some_identifier: ".wrapper { background: red; }"
    #   }
    config_accessor :scoped_styles do
      {}
    end

    # custom fields for proposals using JSON specification:
    # https://github.com/jsonform/jsonform/wiki
    # Valid values uses the same structure as :scoped_styles
    #   :disabled => false and non available, hidden from admins
    #   Hash => hash of different JSON texts, each key will be used for the contraints
    # Admins can create this hash dynamically but some pre-defined css boxes can be created here as:
    #   {
    #      some_identifier: "{ ... some definition... }"
    #   }
    config_accessor :proposal_custom_fields do
      {}
    end

    # Same as proposal_custom_fields but for generating private fields than can be read only by admins
    config_accessor :proposal_private_custom_fields do
      {}
    end

    # How old must be the private data to be considered expired and therefore presented to the admins for deletion
    config_accessor :private_data_expiration_time do
      3.months
    end

    # How long must be the private data prevented from being deleted again after being scheduled for deletion
    config_accessor :lock_time do
      1.minute
    end

    # allows to keep modifications for the main menu
    # can return :disabled to completly remove this feature
    # otherwise it should be an array (some overrides can be specified by default):
    # [
    #    {
    #       url: "/a-new-link",
    #       label: { "en" => "The label to show in the menu" },
    #       position: 10
    #    }
    # ]
    config_accessor :menu do
      []
    end

    # Allows admins to assignate "fake" admins scoped to some admin zones using the
    # same scope editor as :scoped_styles, valid values uses the same convention:
    #   :disabled => false and non available, hidden from admins
    #   Hash => hash of different admin ids, each key will be used for the contraints
    # Admins create this hash dynamically but some pre-defined admin boxes can be created here as:
    #   {
    #      some_identifier: [1234, 5678, 90123]
    #   }
    #
    # To test this feature in development, ensure that config/environmnets/development.rb is configured as:
    #   config.action_dispatch.show_exceptions = true
    #   config.action_dispatch.show_detailed_exceptions = false
    #   config.consider_all_requests_local = false
    config_accessor :scoped_admins do
      {}
    end

    # Allow to configure custom redirections
    # can return :disabled to completly remove this feature
    # You can initialize some default redirection if desired as follows:
    #  {
    #    "/decidim-docs" => { destination: "http://docs.decidim.org", active: true }
    #  }
    #
    # To test this feature in development, ensure that config/environmnets/development.rb is configured as:
    #   config.action_dispatch.show_exceptions = true
    #   config.action_dispatch.show_detailed_exceptions = false
    #   config.consider_all_requests_local = false

    config_accessor :custom_redirects do
      {}
    end

    # these settings do not follow the :disabled convention but
    # depends on the previous intergram configurations
    config_accessor :intergram_url do
      "https://www.intergram.xyz/js/widget.js"
    end

    # no need to override these settings, there admin-configurable
    config_accessor :intergram_for_admins_settings do
      {
        chat_id: nil,
        color: nil,
        use_floating_button: false,
        title_closed: nil,
        title_open: nil,
        intro_message: nil,
        auto_response: nil,
        auto_no_response: nil
      }
    end

    config_accessor :intergram_for_public_settings do
      {
        chat_id: nil,
        require_login: true,
        color: nil,
        use_floating_button: false,
        title_closed: nil,
        title_open: nil,
        intro_message: nil,
        auto_response: nil,
        auto_no_response: nil
      }
    end

    # additional correspondences between participatory spaces manifests and routes
    # ie: /admin/assemblies and /admin/assemblies_types are both treated as a "assembly" participatory space in terms of permission scoping
    # This can be tuned in a initialized if some other hacks over routes are applied
    # if a registered participatory space is not listed here then the name manifest will be used as a default route /manifest_name /admin/manifes_name
    config_accessor :participatory_spaces_routes_context do
      {
        # route in admin is diferent than in the frontend: /processes, /admin/participatory_processes
        participatory_processes: [:participatory_processes, :processes],
        # both /admin/assemblies and /admin/assemblies_types are considered assemblies
        assemblies: [:assemblies, :assemblies_types],
        # route in admin is diferent than in the frontend: /process_groups, /admin/participatory_process_groups
        process_groups: [:processes_groups, :participatory_process_groups]
      }
    end

    # If true, enables a new section in "Participants" where to audit all the admin roles that have been enabled/disabled historically in Decidim
    # Set to :disabled to completly remove this feature
    config_accessor :admin_accountability do
      [:participatory_space_roles, :admin_roles]
    end

    # Roles for which it is necessary to show admin_accountability
    config_accessor :participatory_space_roles do
      [
        "Decidim::AssemblyUserRole",
        "Decidim::ParticipatoryProcessUserRole",
        "Decidim::ConferenceUserRole"
      ]
    end

    # Which components will be tampered to add the voting registry override
    config_accessor :voting_components do
      [:proposals, :reporting_propposals]
    end

    # Public: Stores an instance of ContentBlockRegistry
    def self.voting_registry
      @voting_registry ||= Decidim::ManifestRegistry.new("decidim_awesome/voting")
    end

    #
    # HELPERS
    #
    # pass a single config var or an array of them
    # any non disabled match will return as true
    def self.possible_additional_proposal_sortings
      return [] unless additional_proposal_sortings.is_a?(Array)

      @possible_additional_proposal_sortings ||= additional_proposal_sortings.filter_map do |sort|
        next unless sort.to_sym.in?([:az, :za, :supported_first, :supported_last])

        sort.to_s
      end
    end

    def self.collation_for(locale)
      @collation_for ||= {}
      @collation_for[locale] ||= begin
        res = ActiveRecord::Base.connection.execute(Arel.sql("SELECT collname FROM pg_collation WHERE collname LIKE '#{locale}-x-icu' LIMIT 1")).first
        res ||= ActiveRecord::Base.connection.execute(Arel.sql("SELECT collname FROM pg_collation WHERE collname LIKE '#{locale[0..1]}%' LIMIT 1")).first
        res["collname"] if res
      end
    end

    def self.enabled?(*config_vars)
      config_vars.any? do |item|
        next unless config.has_key?(item.to_sym)

        config.send(item) != :disabled
      end
    end

    def self.registered_components
      @registered_components ||= []
    end

    # Wrap registered components to register it later, after initializing
    # so we can honor disabled_components config
    def self.register_component(manifest, &block)
      registered_components << [manifest, block]
    end

    # appends to a hash a new value in a specified position so that the hash becomes:
    # { a: 1, b: 2, c: 3 } => append_hash(hash, :b, :d, 4) => { a: 1, b: 2, d: 4, c: 3 }
    # if key is not found then it will be inserted at the end
    def self.hash_append!(hash, after_key, key, value)
      insert_at = hash.to_a.index(hash.assoc(after_key))
      insert_at = insert_at.nil? ? hash.size : insert_at + 1
      hash.replace(hash.to_a.insert(insert_at, [key, value]).to_h)
    end

    def self.legacy_version?
      Decidim.version[0..3] == "0.26"
    end
  end
end
