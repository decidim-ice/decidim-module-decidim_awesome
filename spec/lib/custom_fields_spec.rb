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
        { "type" => "text", "required" => true, "label" => "Birthday", "name" => "date" }
      ]
    end
    let(:compatible_json) do
      [
        { "type" => "text", "required" => true, "label" => "Age", "name" => "age" },
        { "type" => "textarea", "required" => true, "label" => "Birthday", "name" => "date", "userData" => ["I am a former text, written <b>before</b> definition of custom fields in this proposal."] }
      ]
    end
    let(:partial_json) do
      [
        { "type" => "text", "required" => true, "label" => "Age", "name" => "age" },
        { "type" => "textarea", "required" => true, "label" => "Birthday", "name" => "date", "userData" => ["1980-04-16"] }
      ]
    end
    let(:html_json) do
      [
        { "type" => "text", "required" => true, "label" => "Textarea", "name" => "textarea", "userData" => ["<p>I am Pi!</p>"] },
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
    let(:utf8_json) do
      [
        { "type" => "textarea", "required" => true, "label" => "Textarea", "name" => "textarea", "userData" => ["Test äöüéè👽"] }
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
      context "and there's no textarea type in the definition" do
        let(:box2) { '[{"type":"text","required":true,"label":"Birthday","name":"date"}]' }
        let(:xml) { '<dt name="age">Age</dt><dd id="age"><div>44</div></dd><dt name="date">Birthday</dt><dd id="date"><div>16/4/1980</div></dd></dl>' }

        it "returns original json and errors" do
          expect(subject.to_json).to eq(bare_json)
          expect(subject.errors).to include("DL/DD elements not found")
        end
      end

      context "and there's a textarea type in the definition" do
        let(:xml) { "I am a former text, written <b>before</b> definition of custom fields in this proposal." }

        it "returns original json and errors" do
          expect(subject.to_json).to eq(compatible_json)
          expect(subject.errors).to include("Content couldn't be parsed but has been assigned to the field 'date'")
        end
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

    context "when xml contains html inside div" do
      let(:box1) { '[{"type":"text","required":true,"label":"Textarea","name":"textarea"}]' }
      let(:xml) { '<xml><dl><dt name="textarea">Textarea</dt><dd id="textarea"><div><p>I am Pi!</p></div></dd><dt name="date">Birthday</dt><dd id="date"><div alt="1980-04-16">16/4/1980</div></dd></dl></xml>' }

      it "collects all the inner html" do
        expect(subject.to_json).to eq(html_json)
        expect(subject.errors).to be_nil
      end
    end

    context "when xml contains utf-8 characters" do
      let(:fields) { box1 }
      let(:box1) { '[{"type":"textarea","required":true,"label":"Textarea","name":"textarea"}]' }
      let(:xml) { '<xml><dl><dt name="textarea">Textarea</dt><dd id="textarea"><div>Test äöüéè👽</div></dd></dl></xml>' }

      it "does not mangle them" do
        expect(subject.to_json).to eq(utf8_json)
        expect(subject.errors).to be_nil
      end
    end
  end
end
