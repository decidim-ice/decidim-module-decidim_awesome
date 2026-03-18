# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  describe RichTextColumn do
    subject { described_class.new(attributes) }

    let(:attributes) { {} }

    describe "attributes" do
      it "has a translatable body" do
        column = described_class.new(body: { en: "<p>Hello</p>" })
        expect(column.body).to eq("en" => "<p>Hello</p>")
      end

      it "defaults restrict_videos to false" do
        expect(subject.restrict_videos).to be(false)
      end

      it "defaults restrict_links to false" do
        expect(subject.restrict_links).to be(false)
      end

      it "accepts restrict_videos as true" do
        column = described_class.new(restrict_videos: true)
        expect(column.restrict_videos).to be(true)
      end

      it "accepts restrict_links as true" do
        column = described_class.new(restrict_links: true)
        expect(column.restrict_links).to be(true)
      end

      it "defaults background_color to nil" do
        expect(subject.background_color).to be_nil
      end

      it "accepts a background_color" do
        column = described_class.new(background_color: "#ff0000")
        expect(column.background_color).to eq("#ff0000")
      end

      it "defaults background_image_placement to cover_center" do
        expect(subject.background_image_placement).to eq("cover_center")
      end

      it "accepts a background_image_placement" do
        column = described_class.new(background_image_placement: "repeat")
        expect(column.background_image_placement).to eq("repeat")
      end
    end

    describe ".from_settings" do
      it "returns an array with a blank column when nil" do
        result = described_class.from_settings(nil)
        expect(result.size).to eq(1)
        expect(result.first).to be_a(described_class)
      end

      it "returns an array with a blank column when empty" do
        result = described_class.from_settings([])
        expect(result.size).to eq(1)
      end

      it "maps a normal array to column objects" do
        result = described_class.from_settings([
                                                 { "body" => { "en" => "First" }, "restrict_videos" => true },
                                                 { "body" => { "en" => "Second" } }
                                               ])
        expect(result.size).to eq(2)
        expect(result.first.body).to eq("en" => "First")
        expect(result.first.restrict_videos).to be(true)
        expect(result.last.body).to eq("en" => "Second")
        expect(result.last.restrict_videos).to be(false)
      end

      it "caps the array at max_rich_text_columns" do
        max = Decidim::DecidimAwesome.max_rich_text_columns
        oversized = Array.new(max + 3) { |i| { "body" => { "en" => "Col #{i}" } } }
        result = described_class.from_settings(oversized)
        expect(result.size).to eq(max)
      end
    end
  end
end
