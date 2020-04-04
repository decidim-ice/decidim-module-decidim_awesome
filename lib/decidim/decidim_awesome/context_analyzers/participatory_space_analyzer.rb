# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module ContextAnalyzers
      # Translates a decidim participatory_space to detected participatory spaces
      class ParticipatorySpaceAnalyzer
        def initialize(participatory_space)
          @participatory_space = participatory_space
          @context = {}
        end

        def self.context_for(participatory_space)
          analyzer = new participatory_space
          analyzer.extract_context!
          analyzer.context
        end

        attr_reader :participatory_space, :context

        def extract_context!
          return unless @participatory_space.respond_to? :manifest
          return unless @participatory_space.manifest.is_a? Decidim::ParticipatorySpaceManifest

          @context[:participatory_space_manifest] = @participatory_space.manifest.name.to_s
          @context[:participatory_space_slug] = @participatory_space&.slug
        end
      end
    end
  end
end
