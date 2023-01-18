# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module SystemChecker
      class << self
        # List of files overriden by this plugin
        # overriden files has to match MD5 calculation to be sure is the same as the expected
        def overrides
          return @overrides if @overrides

          # rubocop:disable Rails/DynamicFindBy
          checksums = YAML.load_file("#{__dir__}/checksums.yml")
          @overrides = checksums.map do |package, files|
            props = {
              spec: ::Gem::Specification.find_by_name(package),
              files: files.transform_values(&:values)
            }
            [package, to_struct(props)]
          end
          # rubocop:enable Rails/DynamicFindBy
          @overrides = to_struct(@overrides.to_h)
        end

        delegate :to_h, to: :overrides

        def each(&block)
          to_h.each(&block)
        end

        def each_file
          each do |_, props|
            props.files.each do |file, signatures|
              yield "#{props.spec.gem_dir}#{file}", signatures
            end
          end
        end

        def valid?(spec, file)
          find_signatures("#{spec.gem_dir}#{file}").detect { |s| md5("#{spec.gem_dir}#{file}") == s }
        end

        private

        def find_signatures(file)
          to_h.each do |_, props|
            props.files.each do |f, signatures|
              return signatures if file == "#{props.spec.gem_dir}#{f}"
            end
          end
        end

        def md5(file)
          Digest::MD5.hexdigest(File.read(file))
        end

        def to_struct(obj)
          Struct.new obj
        end
      end
    end
  end
end
