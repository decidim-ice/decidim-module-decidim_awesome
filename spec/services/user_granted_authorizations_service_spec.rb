# frozen_string_literal: true

require "spec_helper"
require "decidim/decidim_awesome/test/verification_visibility_examples"

module Decidim::DecidimAwesome
  describe UserGrantedAuthorizationsService do
    subject { described_class.new(organization, user) }

    include_context "verification visibility examples setup"

    describe "#user_authorizations" do
      it "returns the granted authorizations for the user" do
        create(:authorization, :granted, user:, name: :dummy_authorization_handler, organization:)
        create(:authorization, :granted, user:, name: :another_dummy_authorization_handler, organization:)
        expect(subject.user_authorizations).to contain_exactly("dummy_authorization_handler")
      end

      it "returns an empty array if no authorizations are granted" do
        create(:authorization, granted_at: nil, user:, name: :dummy_authorization_handler, organization:)
        expect(subject.user_authorizations).to be_empty
      end
    end

    describe "#granted_handlers" do
      it "returns only the granted handlers groups" do
        create(:authorization, :granted, user:, name: :dummy_authorization_handler, organization:)
        expect(subject.granted_handlers).to have_key("test")
        expect(subject.granted_handlers["test"]).to have_key("dummy_authorization_handler")
      end

      it "does not return non-granted handlers groups" do
        create(:authorization, granted_at: nil, user:, name: :dummy_authorization_handler, organization:)
        expect(subject.granted_handlers).to be_empty
      end

      context "when the awesome config var is another handler" do
        let(:force_authorizations_value) do
          { "test" => { "authorization_handlers" => { "another_dummy_authorization_handler" => { "options" => {} } } } }
        end

        it "does not handlers that are not in the awesome config var" do
          create(:authorization, :granted, user:, name: :dummy_authorization_handler, organization:)
          expect(subject.granted_handlers).to be_empty
        end
      end
    end

    describe "#non_granted_handlers" do
      it "returns only the non-granted handlers groups" do
        expect(subject.non_granted_handlers).to have_key("test")
        expect(subject.non_granted_handlers["test"]).to have_key("dummy_authorization_handler")
      end

      it "does not return granted handlers groups" do
        create(:authorization, :granted, user:, name: :dummy_authorization_handler, organization:)
        expect(subject.non_granted_handlers).to be_empty
      end

      context "when the awesome config var is another handler" do
        let(:force_authorizations_value) do
          { "test" => { "authorization_handlers" => { "another_dummy_authorization_handler" => { "options" => {} } } } }
        end

        it "does not handlers that are not in the awesome config var" do
          create(:authorization, granted_at: nil, user:, name: :dummy_authorization_handler, organization:)
          expect(subject.non_granted_handlers).to be_empty
        end
      end
    end

    describe "#component_with_invisible_resources" do
      it "returns an empty list if no restrictions are applied" do
        expect(subject.component_with_invisible_resources).to be_empty
      end

      it "returns the components with invisible resources due to non-granted authorizations" do
        create(:config_constraint, awesome_config: sub_config, settings: { "component_manifest" => "proposals" })

        expect(subject.component_with_invisible_resources.first).to contain_exactly(assembly_component, process_component)
      end

      it "returns the components scoped to a participatory space" do
        create(:config_constraint, awesome_config: sub_config,
                                   settings: { "component_manifest" => "proposals", "participatory_space_manifest" => "assemblies" })

        expect(subject.component_with_invisible_resources.first).to contain_exactly(assembly_component)
      end
    end

    describe "#spaces_with_invisible_components" do
      it "returns an empty list if no restrictions are applied" do
        expect(subject.spaces_with_invisible_components).to be_empty
      end

      it "returns the spaces with invisible components due to non-granted authorizations" do
        create(:config_constraint, awesome_config: sub_config, settings: { "participatory_space_manifest" => "assemblies" })

        expect(subject.spaces_with_invisible_components.first).to contain_exactly(assembly)
      end
    end
  end
end
