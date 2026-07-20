# frozen_string_literal: true

require "spec_helper"
require "digest"

# This ensures that overwritten files are the expected ones by checking the expected checksum
module Decidim::DecidimAwesome
  describe SystemChecker do
    subject { described_class }

    it "has overrides" do
      expect(subject.overrides.to_h.length).to eq(7)
    end

    it "has 2 modified files in admin" do
      expect(subject.overrides["decidim-admin"].files.length).to eq(2)
    end

    it "has 1 modified files in assemblies" do
      expect(subject.overrides["decidim-assemblies"].files.length).to eq(1)
    end

    it "has 1 modified files in participatory_processes" do
      expect(subject.overrides["decidim-participatory_processes"].files.length).to eq(1)
    end

    it "has 1 modified files in conferences" do
      expect(subject.overrides["decidim-conferences"].files.length).to eq(1)
    end

    it "has 23 modified files in core" do
      expect(subject.overrides["decidim-core"].files.length).to eq(23)
    end

    it "has 28 modified files in proposals" do
      expect(subject.overrides["decidim-proposals"].files.length).to eq(28)
    end

    it "has 1 modified files in verifications" do
      expect(subject.overrides["decidim-verifications"].files.length).to eq(1)
    end

    # context "when file" do
    #   # upstream files removed in newer decidim versions, still tracked for older ones
    #   removed_upstream = ["/app/views/decidim/proposals/proposals/_votes_count.html.erb"]
    #
    #   described_class.each do |_group, props|
    #     props.files.each do |file, signatures|
    #       next if removed_upstream.include?(file)
    #
    #       it "#{file} matches checksum" do
    #         expect(subject.exists?(props.spec, file)).to be(true), "expected #{file} to exist in #{props.spec.gem_dir}"
    #         expect([signatures].flatten).to include(md5("#{props.spec.gem_dir}#{file}"))
    #       end
    #     end
    #   end
    # end
    context "when file" do
      described_class.each do |_group, props|
        props.files.each do |file, signatures|
          it "#{file} matches checksum" do
            if subject.exists?(props.spec, file)
              expect([signatures].flatten).to include(md5("#{props.spec.gem_dir}#{file}"))
            else
              expect([signatures].flatten).to include("removed"), "expected #{file} to exist in #{props.spec.gem_dir} (or be marked as removed in checksums.yml)"
            end
          end
        end
      end
    end

    described_class.each do |group, props|
      context "when iterating by group #{group}" do
        it "each file is valid" do
          props.files do |file, _signature|
            expect(subject.valid?(props.spec, file)).to be(true)
          end
        end
      end
    end

    def md5(file)
      Digest::MD5.hexdigest(File.read(file))
    end
  end
end
