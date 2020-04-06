# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module SystemChecker
      # List of files overriden by this plugin
      # overriden files has to match MD5 calculation to be sure is the same as the expected
      def self.overrides
        # rubocop:disable Rails/DynamicFindBy
        @overrides ||= to_struct(
          admin: to_struct(
            spec: ::Gem::Specification.find_by_name("decidim-admin"),
            files: {
              "/app/views/layouts/decidim/admin/_header.html.erb" => "6f0c010b1dcf912be1b3e0ff9f156026"
            }
          ),
          core: to_struct(
            spec: ::Gem::Specification.find_by_name("decidim-core"),
            files: {
              "/app/views/layouts/decidim/_head.html.erb" => "b261c55492d047ba730eed8b39be0304",
              "/app/assets/javascripts/decidim/editor.js.es6" => "797d0ec1c9e79453cf6718f82d2fdd27"
            }
          ),
          proposals: to_struct(
            spec: ::Gem::Specification.find_by_name("decidim-proposals"),
            files: {
              "/app/presenters/decidim/proposals/proposal_presenter.rb" => "af098810b12cee97fddc2ee8fd405a54"
            }
          )
        )
        # rubocop:enable Rails/DynamicFindBy
      end

      def self.to_h
        overrides.to_h
      end

      def self.each(&block)
        to_h.each(&block)
      end

      def self.each_file
        each do |_, props|
          props.files.each do |file, signature|
            yield "#{props.spec.gem_dir}#{file}", signature
          end
        end
      end

      def self.valid?(spec, file)
        md5("#{spec.gem_dir}#{file}") == find_signature("#{spec.gem_dir}#{file}")
      end

      def self.find_signature(file)
        to_h.each do |_, props|
          props.files.each do |f, signature|
            return signature if file == "#{props.spec.gem_dir}#{f}"
          end
        end
      end

      def self.md5(file)
        Digest::MD5.hexdigest(File.read(file))
      end

      def self.to_struct(obj)
        OpenStruct.new obj
      end
    end
  end
end
