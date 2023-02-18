# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class PaperTrailVersion < PaperTrail::Version
      default_scope { order("created_at DESC") }

      def self.safe_user_roles
        DecidimAwesome.admin_user_roles.filter(&:safe_constantize)
      end

      scope :role_actions, -> { where(item_type: PaperTrailVersion.safe_user_roles, event: "create") }

      def present(html: true)
        @present ||= if item_type.in?(PaperTrailVersion.safe_user_roles)
                       PaperTrailRolePresenter.new(self, html: html)
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
          Arel.sql("(#{queries.join(" UNION ")})")
        end
      end

      ransacker :created_at, type: :date do
        Arel.sql("date(created_at)")
      end
    end
  end
end
