# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module ContextAnalyzers
      # Translates some Decidim URL path to detected participatory spaces and components
      class RequestAnalyzer
        def initialize(request)
          @request = request
          @context = {}
        end

        def self.context_for(request)
          analyzer = new request
          analyzer.extract_context!
          analyzer.context
        end

        attr_reader :request, :context

        def extract_context!
          path = URI.parse(@request.url).path
          context_from_path path
        end

        private

        # In the frontend there's no a 100% correspondence between url and manifest name
        def participatory_spaces
          spaces = Decidim.participatory_space_manifests.map do |space|
            [space.name.to_s, space.name.to_s]
          end.to_h
          spaces.merge(
            "processes" => "participatory_processes",
            "participatory_process_groups" => "process_groups",
            "processes_groups" => "process_groups",
            "assemblies_types" => "assemblies"
          )
        end

        def process_admin_segments(segments)
          spaces = participatory_spaces
          return unless spaces[segments[0]]

          @context[:participatory_space_manifest] = spaces[segments[0]]
          @context[:participatory_space_slug] = segments[1] if segments[1].present?

          return unless segments[2].presence == "components" && segments[3].present?

          @context[:component_id] = segments[3]
          # Try to infer component_manifest
          c = Component.find_by(id: segments[3])
          @context[:component_manifest] = c.manifest_name if c
        end

        def process_front_segments(segments)
          spaces = participatory_spaces
          return unless spaces[segments[0]]

          @context[:participatory_space_manifest] = spaces[segments[0]]
          @context[:participatory_space_slug] = segments[1] if segments[1].present?

          return unless segments[2].presence == "f" && segments[3].present?

          @context[:component_id] = segments[3]
          # Try to infer component_manifest
          c = Component.find_by(id: segments[3])
          @context[:component_manifest] = c.manifest_name if c
        end

        def system_manifest?(path)
          patterns = [
            %r{^/admin/newsletters},
            %r{^/admin/organization},
            %r{^/admin/static_pages}
          ]
          path.match(Regexp.union(patterns))
        end

        def context_from_path(path)
          if system_manifest?(path)
            @context[:participatory_space_manifest] = "system"
            return
          end

          segments = path.sub(%r{^/}, "").split("/")
          return if segments.blank?

          if segments[0] == "admin"
            segments.shift
            return process_admin_segments(segments)
          end
          process_front_segments(segments)
        end
      end
    end
  end
end
