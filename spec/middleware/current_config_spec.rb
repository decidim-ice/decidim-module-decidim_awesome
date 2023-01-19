# frozen_string_literal: true

require "spec_helper"
require "decidim/decidim_awesome/test/shared_examples/current_config_examples"

module Decidim::DecidimAwesome
  describe CurrentConfig do
    let(:app) { ->(env) { [200, env, "app"] } }
    let(:env) { Rack::MockRequest.env_for("https://#{host}/#{path}?foo=bar", "decidim.current_organization" => organization, method: method) }
    let(:host) { "city.domain.org" }
    let(:method) { "GET" }
    let(:middleware) { described_class.new(app) }
    let(:path) { "" }
    let!(:organization) { create(:organization, host: host) }
    let!(:organization2) { create(:organization, host: "another.host.org") }
    let!(:assembly) { create(:assembly, organization: organization) }
    let!(:another_assembly) { create(:assembly, organization: organization) }
    let!(:user) { create(:user, :confirmed, organization: organization) }
    let!(:admin) { create(:user, :confirmed, :admin, organization: organization) }

    # clean the tampered User model
    after do
      Decidim::User.awesome_potential_admins = []
      Decidim::User.awesome_admins_for_current_scope = []
    end

    context "when no scoped admins" do
      it_behaves_like "same environment"
      it_behaves_like "untampered user model"
    end

    context "when scoped admins" do
      let!(:config) { create :awesome_config, organization: organization, var: :scoped_admins, value: admins }
      let(:config_helper_bar) { create :awesome_config, organization: organization, var: :scoped_admin_bar }
      let(:config_helper_foo) { create :awesome_config, organization: organization, var: :scoped_admin_foo }
      let!(:constraint_bar) { create(:config_constraint, awesome_config: config_helper_bar, settings: settings_bar) }
      let!(:constraint_foo) { create(:config_constraint, awesome_config: config_helper_foo, settings: settings_foo) }
      let(:admins) do
        {
          "bar" => []
        }
      end
      let(:settings_bar) do
        {
          "participatory_space_manifest" => "assemblies",
          "participatory_space_slug" => assembly.slug
        }
      end
      let(:settings_foo) do
        {
          "participatory_space_manifest" => "participatory_processes"
        }
      end
      let(:settings_none) do
        {
          "participatory_space_manifest" => "none"
        }
      end

      context "and no admins defined" do
        it_behaves_like "same environment"
        it_behaves_like "untampered user model"
      end

      context "and admins are defined" do
        let(:admins) do
          {
            "bar" => [admin.id.to_s, user.id.to_s],
            "foo" => [admin.id.to_s]
          }
        end

        it_behaves_like "same environment"
        it_behaves_like "tampered users model"
        it_behaves_like "generic admin routes"

        context "and custom admins is disabled" do
          before do
            allow(Decidim::User).to receive(:respond_to?).with(:awesome_admins_for_current_scope).and_return(false)
          end

          it "user model is not tampered" do
            Decidim::User.awesome_admins_for_current_scope = nil
            middleware.call(env)

            expect(Decidim::User.awesome_admins_for_current_scope).not_to be_present
          end
        end

        context "when visiting assemblies" do
          let(:path) { "assemblies" }

          it_behaves_like "tampered users model"
        end

        context "when visiting admin assemblies" do
          let(:path) { "admin/assemblies" }

          it_behaves_like "tampered users model"
        end

        context "when visiting admin assembly" do
          let(:path) { "admin/assemblies/#{assembly.slug}" }

          it_behaves_like "tampered users model"
        end

        context "when editing admin assembly" do
          let(:path) { "admin/assemblies/#{assembly.id}" }

          it_behaves_like "untampered user model"

          context "and is POST" do
            let(:method) { "POST" }

            it_behaves_like "tampered users model"
          end

          context "and is PATCH" do
            let(:method) { "PATCH" }

            it_behaves_like "tampered users model"
          end
        end

        context "when visiting processes" do
          let(:path) { "processes" }

          it_behaves_like "tampered admin model"
        end

        context "when visiting admin processes" do
          let(:path) { "admin/processes" }

          it_behaves_like "tampered admin model"
        end

        context "and user have the none constraint" do
          let!(:constraint_bar2) { create(:config_constraint, awesome_config: config_helper_bar, settings: settings_none) }

          it_behaves_like "same environment"
          it_behaves_like "tampered admin model"
        end
      end
    end
  end
end
