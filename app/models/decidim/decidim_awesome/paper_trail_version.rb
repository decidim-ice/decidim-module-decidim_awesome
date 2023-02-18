# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class PaperTrailVersion < PaperTrail::Version
      default_scope { order("created_at DESC") }
      scope :role_actions, -> { where(item_type: ::Decidim::DecidimAwesome.admin_user_roles, event: "create") }

      def present(html: true)
        @present ||= if item_type.in?(Decidim::DecidimAwesome.admin_user_roles)
                       PaperTrailRolePresenter.new(self, html: html)
                     else
                       self
                     end
      end

      ransacker :role_type do
        Arel.sql(%{
              (
                SELECT cast("decidim_assembly_user_roles"."role" as text) FROM "decidim_assembly_user_roles"
                WHERE "decidim_assembly_user_roles"."id" = "versions"."item_id"
                AND item_type = 'Decidim::AssemblyUserRole'
                UNION
                SELECT cast("decidim_participatory_process_user_roles"."role" as text) FROM decidim_participatory_process_user_roles
                WHERE decidim_participatory_process_user_roles.id = versions.item_id
                AND item_type = 'Decidim::ParticipatoryProcessUserRole'
              )
            })
      end

      ransacker :participatory_space_type do
        Arel.sql(%{ (cast("item_type" as text))})
      end

      ransacker :user_email do
        query = <<-SQL.squish
            (
            SELECT decidim_users.email FROM decidim_users
            JOIN decidim_assembly_user_roles ON decidim_users.id = decidim_assembly_user_roles.decidim_user_id
            WHERE decidim_assembly_user_roles.id = versions.item_id
            AND item_type = 'Decidim::AssemblyUserRole'
            UNION
            SELECT decidim_users.email FROM decidim_users
            JOIN decidim_participatory_process_user_roles ON decidim_users.id = decidim_participatory_process_user_roles.decidim_user_id
            WHERE decidim_participatory_process_user_roles.id = versions.item_id
            AND item_type = 'Decidim::ParticipatoryProcessUserRole'
            )
        SQL
        Arel.sql(query)
      end

      ransacker :user_name do
        query = <<-SQL.squish
            (
            SELECT decidim_users.name FROM decidim_users
            JOIN decidim_assembly_user_roles ON decidim_users.id = decidim_assembly_user_roles.decidim_user_id
            WHERE decidim_assembly_user_roles.id = versions.item_id
            AND item_type = 'Decidim::AssemblyUserRole'
            UNION
            SELECT decidim_users.name FROM decidim_users
            JOIN decidim_participatory_process_user_roles ON decidim_users.id = decidim_participatory_process_user_roles.decidim_user_id
            WHERE decidim_participatory_process_user_roles.id = versions.item_id
            AND item_type = 'Decidim::ParticipatoryProcessUserRole'
            )
        SQL
        Arel.sql(query)
      end

      ransacker :created_at, type: :date do
        Arel.sql("date(created_at)")
      end
    end
  end
end
