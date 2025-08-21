# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class PaperTrailVersion < PaperTrail::Version
      default_scope { order("versions.created_at DESC") }

      def self.safe_user_roles
        DecidimAwesome.participatory_space_roles.filter(&:safe_constantize)
      end

      def self.safe_admin_role_type(admin_role)
        Decidim.user_roles.find { |role| role == admin_role }
      end

      scope :space_role_actions, lambda { |organization|
        role_changes = where(item_type: PaperTrailVersion.safe_user_roles, event: "create")

        user_ids_from_object_changes = role_changes.pluck(:object_changes).map { |change| change.fetch("decidim_user_id", []).last.to_i }
        user_ids_from_object_changes.compact_blank!
        relevant_user_ids = Decidim::User.where(id: user_ids_from_object_changes, organization:).pluck(:id)
        # add users that might have been completly destroyed in any organization
        relevant_user_ids += user_ids_from_object_changes - Decidim::User.where(id: user_ids_from_object_changes).pluck(:id)

        role_changes.where("object_changes @> ANY (array[?]::jsonb[])", relevant_user_ids.map { |id| { "decidim_user_id" => [nil, id] }.to_json })
      }

      scope :in_organization, lambda { |organization|
        joins("LEFT JOIN decidim_users ON decidim_users.id = item_id")
          .where("item_type = 'Decidim::UserBaseEntity' AND decidim_users.decidim_organization_id = ?", organization.id)
          .order("versions.created_at DESC")
      }

      def self.admin_role_actions(filter = nil)
        base = where(item_type: "Decidim::UserBaseEntity", event: %w(create update))
        case filter
        when nil
          base.where(
            "object_changes @> ?::jsonb OR object_changes @> ?::jsonb",
            { "roles" => [[], []] }.to_json,
            { "admin" => [false, true] }.to_json
          )
        when "admin"
          base.where("object_changes @> ?::jsonb", { "admin" => [false, true] }.to_json)
        else
          base.where("object_changes @> ?::jsonb", { "roles" => [[], [filter]] }.to_json)
        end
      end

      def present(html: true)
        @present ||= if item_type == "Decidim::UserBaseEntity"
                       UserEntityPresenter.new(self, html:)
                     elsif item_type.in?(PaperTrailVersion.safe_user_roles)
                       ParticipatorySpaceRolePresenter.new(self, html:)
                     else
                       self
                     end
      end

      ransacker :role_type do
        @role_type ||= begin
          queries = PaperTrailVersion.safe_user_roles.map do |role_class|
            table = role_class.safe_constantize.table_name
            %{
              SELECT ("#{table}"."role")::text FROM "#{table}"
              WHERE "#{table}"."id" = "versions"."item_id"
              AND item_type = '#{role_class}'
            }
          end
          Arel.sql("(#{queries.join(" UNION ")})")
        end
      end
      ransacker :participatory_space_type do
        Arel.sql(%{("item_type")::text})
      end

      ransacker :user_email do
        @user_email ||= begin
          queries = PaperTrailVersion.safe_user_roles.map do |role_class|
            table = role_class.safe_constantize.table_name
            %(
              SELECT decidim_users.email FROM decidim_users
              JOIN #{table} ON decidim_users.id = #{table}.decidim_user_id
              WHERE #{table}.id = versions.item_id
              AND item_type = '#{role_class}'
            )
          end
          queries << %(
            SELECT decidim_users.email FROM decidim_users
            WHERE decidim_users.id = versions.item_id
            AND item_type = 'Decidim::UserBaseEntity'
          )
          Arel.sql("(#{queries.join(" UNION ")})")
        end
      end

      ransacker :user_name do
        @user_name ||= begin
          queries = PaperTrailVersion.safe_user_roles.map do |role_class|
            table = role_class.safe_constantize.table_name
            %(
              SELECT decidim_users.name FROM decidim_users
              JOIN #{table} ON decidim_users.id = #{table}.decidim_user_id
              WHERE #{table}.id = versions.item_id
              AND item_type = '#{role_class}'
            )
          end
          queries << %(
            SELECT decidim_users.name FROM decidim_users
            WHERE decidim_users.id = versions.item_id
            AND item_type = 'Decidim::UserBaseEntity'
          )
          Arel.sql("(#{queries.join(" UNION ")})")
        end
      end

      ransacker :created_at, type: :date do
        Arel.sql("date(versions.created_at)")
      end

      def self.ransackable_attributes(_auth_object = nil)
        %w(created_at event id item_id item_type object object_changes participatory_space_type role_type user_email user_name whodunnit)
      end

      def self.ransackable_associations(_auth_object = nil)
        ["item"]
      end
    end
  end
end
