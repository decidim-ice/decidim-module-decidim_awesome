# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  module Admin
    describe CustomRedirectForm do
      subject { described_class.from_params(attributes).with_context(current_organization: organization) }

      let(:organization) { create :organization }
      let(:attributes) do
        {
          origin: origin,
          destination: destination,
          active: active,
          pass_query: pass_query
        }
      end

      let(:origin) { "/some-path" }
      let(:destination) { "/some-destination" }
      let(:active) { true }
      let(:pass_query) { true }

      context "when everything is OK" do
        it { is_expected.to be_valid }

        it "returns normalized values" do
          expect(subject.to_params).to eq([origin, { destination: destination, active: active, pass_query: pass_query }])
        end
      end

      context "when origin is empty" do
        let(:origin) { "" }

        it { is_expected.to be_invalid }

        context "and is only spaces" do
          let(:origin) { "  " }

          it { is_expected.to be_invalid }
        end
      end

      context "when destination empty" do
        let(:destination) { "" }

        it { is_expected.to be_invalid }

        context "and is only spaces" do
          let(:destination) { "  " }

          it { is_expected.to be_invalid }
        end
      end

      context "when origin is malformed" do
        let(:origin) { " some-Origin " }

        it { is_expected.to be_valid }

        it "sanitizes origin" do
          expect(subject.to_params[0]).to eq("/some-origin")
        end

        context "and origin has organization host" do
          let(:origin) { "http://#{organization.host}/some-Origin " }

          it "strips host" do
            expect(subject.to_params[0]).to eq("/some-origin")
          end
        end
      end

      context "when destination is malformed" do
        let(:destination) { " some-destInation " }

        it { is_expected.to be_valid }

        it "sanitizes destination" do
          expect(subject.to_params[1][:destination]).to eq("/some-destination")
        end

        context "and destination has organization host" do
          let(:destination) { "http://#{organization.host}/some-destination " }

          it "maintains host" do
            expect(subject.to_params[1][:destination]).to eq("http://#{organization.host}/some-destination")
          end
        end
      end

      context "when origin and destination are the same" do
        let(:destination) { "http://#{organization.host}#{origin} " }

        it { is_expected.to be_invalid }
      end

      context "when origin and destination are not case sensitive" do
        let(:origin) { "/Some-Origin-Path".downcase }
        let(:destination) { "http://#{organization.host}/Some-Origin-Path".downcase }

        it "compares origin and destination without considering case" do
          expect(origin).not_to eq("/Some-Origin-Path")
          expect(destination).not_to eq("http://#{organization.host}/Some-Origin-Path")
        end
      end
    end
  end
end
