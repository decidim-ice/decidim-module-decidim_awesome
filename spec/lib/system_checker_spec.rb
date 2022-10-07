# frozen_string_literal: true

require "spec_helper"
require "digest"

# This ensures that overwritten files are the expected ones by checking the expected checksum
module Decidim::DecidimAwesome
  describe SystemChecker do
    subject { described_class }

    it "has overrides" do
      expect(subject.overrides.to_h.length).to eq(3)
    end

    it "has 1 modified files in admin" do
      expect(subject.overrides["decidim-admin"].files.length).to eq(1)
    end

    it "has 5 modified files in core" do
      expect(subject.overrides["decidim-core"].files.length).to eq(6)
    end

    it "has 5 modified files in proposals" do
      expect(subject.overrides["decidim-proposals"].files.length).to eq(5)
    end

    context "when file" do
      described_class.each_file do |file, signatures|
        it "#{file} matches checksum" do
          expect([signatures].flatten).to include(md5(file))
        end
      end
    end

    described_class.each do |group, props|
      context "when iterating by group #{group}" do
        it "each file is valid" do
          props.files do |file, _signature|
            expect(subject.valid?(props.spec, file)).to eq(true)
          end
        end
      end
    end

    def md5(file)
      Digest::MD5.hexdigest(File.read(file))
    end
  end
end
