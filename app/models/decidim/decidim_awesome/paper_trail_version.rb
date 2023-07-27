# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class PaperTrailVersion < PaperTrail::Version
      default_scope { order("versions.created_at DESC") }

      def self.safe_user_roles
        DecidimAwesome.participatory_space_roles.filter(&:safe_constantize)
      end

      scope :space_role_actions, lambda { |current_organization_id|
        role_changes = where(item_type: PaperTrailVersion.safe_user_roles, event: "create")
        user_ids_from_object_changes = role_changes.pluck(:object_changes).map { |change| change.match(/decidim_user_id:\n-\n- (\d+)/)[1].to_i }
        relevant_user_ids = Decidim::User.where(id: user_ids_from_object_changes, decidim_organization_id: current_organization_id).pluck(:id)

        role_changes.where("object_changes ~ ANY (array[?])", relevant_user_ids.map { |id| "decidim_user_id:\n-\n- #{id}" })
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
          base.where("object_changes LIKE '%\nroles:\n- []\n- - %' OR object_changes LIKE '%\nadmin:\n- false\n- true%'")
        when "admin"
          base.where("object_changes LIKE '%\nadmin:\n- false\n- true%'")
        else
          base.where(Arel.sql("object_changes LIKE '%\nroles:\n- []\n- - #{filter}\n%'"))
        end
      end

      def present(html: true)
        @present ||= if item_type == "Decidim::UserBaseEntity"
                       UserEntityPresenter.new(self, html: html)
                     elsif item_type.in?(PaperTrailVersion.safe_user_roles)
                       ParticipatorySpaceRolePresenter.new(self, html: html)
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
    end
  end
end
