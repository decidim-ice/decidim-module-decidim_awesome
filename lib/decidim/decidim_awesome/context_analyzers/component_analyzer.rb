# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module ContextAnalyzers
      # Translates a decidim component to detected participatory spaces and components
      class ComponentAnalyzer
        def initialize(component)
          @component = component
          @context = {}
        end

        def self.context_for(component)
          analyzer = new component
          analyzer.extract_context!
          analyzer.context
        end

        attr_reader :component, :context

        def extract_context!
          if @component.respond_to? :participatory_space
            @context[:participatory_space_manifest] = @component.participatory_space.manifest.name.to_s
            @context[:participatory_space_slug] = @component.participatory_space&.slug
          end

          if @component.respond_to? :component
            @context[:component_manifest] = @component.component.manifest.name.to_s
            @context[:component_id] = @component.component&.id&.to_s
          elsif @component.is_a? Decidim::Component
            @context[:component_manifest] = @component.manifest.name.to_s
            @context[:component_id] = @component&.id&.to_s
          end
        end
      end
    end
  end
end
