# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  describe CustomFields do
    subject { described_class.new fields }

    let(:fields) do
      [
        box1,
        box2
      ]
    end
    let(:box1) { '[{"type":"text","required":true,"label":"Age","name":"age"}]' }
    let(:box2) { '[{"type":"textarea","required":true,"label":"Birthday","name":"date"}]' }
    let(:bare_json) do
      [
        { "type" => "text", "required" => true, "label" => "Age", "name" => "age" },
        { "type" => "textarea", "required" => true, "label" => "Birthday", "name" => "date" }
      ]
    end
    let(:partial_json) do
      [
        { "type" => "text", "required" => true, "label" => "Age", "name" => "age" },
        { "type" => "textarea", "required" => true, "label" => "Birthday", "name" => "date", "userData" => ["1980-04-16"] }
      ]
    end
    let(:array_json) do
      [
        { "type" => "text", "required" => true, "label" => "Age", "name" => "age", "userData" => ["44"] },
        { "type" => "textarea", "required" => true, "label" => "Birthday", "name" => "date", "userData" => ["1980-04-16", "1/12/1880"] }
      ]
    end
    let(:partial_array_json) do
      [
        { "type" => "text", "required" => true, "label" => "Age", "name" => "age" },
        { "type" => "textarea", "required" => true, "label" => "Birthday", "name" => "date", "userData" => ["1980-04-16", "1/12/1880"] }
      ]
    end
    let(:json) do
      [
        { "type" => "text", "required" => true, "label" => "Age", "name" => "age", "userData" => ["44"] },
        { "type" => "textarea", "required" => true, "label" => "Birthday", "name" => "date", "userData" => ["1980-04-16"] }
      ]
    end
    let(:one_json) do
      [
        { "type" => "textarea", "required" => true, "label" => "Birthday", "name" => "date", "userData" => ["1980-04-16"] }
      ]
    end
    let(:xml) { '<xml><dl><dt name="age">Age</dt><dd id="age" name="text"><div>44</div></dd><dt name="date">Birthday</dt><dd id="date" name="date"><div alt="1980-04-16">16/4/1980</div></dd></dl></xml>' }

    before do
      subject.apply_xml xml
    end

    it "joins everything in JSON format" do
      expect(subject.to_json).to eq(json)
      expect(subject.errors).to be_nil
    end

    context "when xml is malformed" do
      let(:xml) { '<dl><dt name="age">Age</dt><dd id="age"><div>44</div></dd><dt name="date">Birthday</dt><dd id="date"><div>16/4/1980</div></dd></dl>' }

      it "returns original json and errors" do
        expect(subject.to_json).to eq(bare_json)
        expect(subject.errors).to include("DL/DD elements not found")
      end
    end

    context "when xml contains only one dd" do
      let(:xml) { '<xml><dl><dt name="date">Birthday</dt><dd id="date"><div alt="1980-04-16">16/4/1980</div></dd></dl></xml>' }

      it "fills what's available" do
        expect(subject.to_json).to eq(partial_json)
        expect(subject.errors).to be_nil
      end
    end

    context "when xml contains arrays of divs" do
      let(:xml) { '<xml><dl><dt name="age">Age</dt><dd id="age"><div>44</div></dd><dt name="date">Birthday</dt><dd id="date"><div alt="1980-04-16">16/4/1980</div><div>1/12/1880</div></dd></dl></xml>' }

      it "fills what's available" do
        expect(subject.to_json).to eq(array_json)
        expect(subject.errors).to be_nil
      end
    end

    context "when xml contains only arrays of divs" do
      let(:xml) { '<xml><dl><dt name="date">Birthday</dt><dd id="date"><div alt="1980-04-16">16/4/1980</div><div>1/12/1880</div></dd></dl></xml>' }

      it "fills what's available" do
        expect(subject.to_json).to eq(partial_array_json)
        expect(subject.errors).to be_nil
      end
    end

    context "when xml contains partial answers" do
      let(:xml) { '<xml><dl><dt name="name">Name</dt><dd id="name"><div>Lucky Luke</div></dd><dt name="date">Birthday</dt><dd id="date"><div alt="1980-04-16">16/4/1980</div></dd></dl></xml>' }

      it "fills what's available" do
        expect(subject.to_json).to eq(partial_json)
        expect(subject.errors).to be_nil
      end
    end

    context "when xml contains has no enclose div" do
      let(:xml) { '<xml><dl><dt name="age">Age</dt><dd id="age">44</dd><dt name="date">Birthday</dt><dd id="date"><div alt="1980-04-16">16/4/1980</div></dd></dl></xml>' }

      it "fills what's available" do
        expect(subject.to_json).to eq(partial_json)
        expect(subject.errors).to be_nil
      end
    end

    context "when fields is not an array" do
      let(:fields) { box2 }

      it "returns the json or one element" do
        expect(subject.to_json).to eq(one_json)
        expect(subject.errors).to be_nil
      end
    end
  end
end
