# frozen_string_literal: true

require "spec_helper"
require "digest"

# This ensures that overwritten files are the expected ones by checking the expected checksum
module Decidim::DecidimAwesome
  describe SystemChecker do
    subject { described_class }

    it "has 1 modified files in admin" do
      expect(subject.overrides.admin.files.length).to eq(1)
    end

    it "has 2 modified files in core" do
      expect(subject.overrides.core.files.length).to eq(2)
    end

    it "has 1 modified files in proposals" do
      expect(subject.overrides.proposals.files.length).to eq(1)
    end

    it "each file matches the expected checksum" do
      subject.each_file do |file, signature|
        expect(md5(file)).to eq(signature)
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
