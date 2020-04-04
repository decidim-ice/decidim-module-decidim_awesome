# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module ContextAnalyzers
      autoload :RequestAnalyzer, "decidim/decidim_awesome/context_analyzers/request_analyzer"
      autoload :ComponentAnalyzer, "decidim/decidim_awesome/context_analyzers/component_analyzer"
      autoload :ParticipatorySpaceAnalyzer, "decidim/decidim_awesome/context_analyzers/participatory_space_analyzer"
    end
  end
end
