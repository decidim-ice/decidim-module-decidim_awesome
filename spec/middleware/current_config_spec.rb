# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  describe CurrentConfig do
    let(:app) { ->(env) { [200, env, "app"] } }
    let(:env) { Rack::MockRequest.env_for("https://#{host}/#{path}?foo=bar", "decidim.current_organization" => organization, method: method) }
    let(:host) { "city.domain.org" }
    let(:method) { "GET" }
    let(:middleware) { described_class.new(app) }
    let(:path) { "some_path" }
    let!(:organization) { create(:organization, host: host) }
    let!(:organization2) { create(:organization, host: "another.host.org") }
    let!(:assembly) { create(:assembly, organization: organization) }
    let!(:another_assembly) { create(:assembly, organization: organization) }
    let!(:user) { create(:user, :confirmed, organization: organization) }
    let!(:admin) { create(:user, :confirmed, :admin, organization: organization) }

    shared_examples "same environment" do
      it "do not modify the environment" do
        code, new_env = middleware.call(env)

        expect(new_env).to eq(env)
        expect(code).to eq(200)
      end

      it "has current organization in env" do
        _code, new_env = middleware.call(env)

        expect(new_env["decidim.current_organization"]).to eq(env["decidim.current_organization"])
        expect(new_env["decidim_awesome.current_config"]).to be_a Config
      end
    end

    shared_examples "untampered user model" do
      it "user model is not tampered" do
        # ensure model is always reset after calling the middleware
        Decidim::User.awesome_admins_for_current_scope = [123]
        middleware.call(env)

        expect(Decidim::User.awesome_admins_for_current_scope).not_to be_present
      end
    end

    shared_examples "tampered users model" do
      it "user model is tampered" do
        # ensure model is always reset after calling the middleware
        Decidim::User.awesome_admins_for_current_scope = [123]
        middleware.call(env)

        expect(Decidim::User.awesome_admins_for_current_scope).to match_array([user.id, admin.id])
      end
    end

    shared_examples "tampered user model" do
      it "user model is tampered" do
        # ensure model is always reset after calling the middleware
        Decidim::User.awesome_admins_for_current_scope = [123]
        middleware.call(env)

        expect(Decidim::User.awesome_admins_for_current_scope).to match_array([user.id])
      end
    end

    shared_examples "tampered admin model" do
      it "user model is tampered" do
        # ensure model is always reset after calling the middleware
        Decidim::User.awesome_admins_for_current_scope = [123]
        middleware.call(env)

        expect(Decidim::User.awesome_admins_for_current_scope).to match_array([admin.id])
      end
    end

    shared_examples "generic admin routes" do
      context "when admin index" do
        let(:path) { "admin/" }

        it_behaves_like "tampered users model"

        context "when POST" do
          let(:method) { "POST" }

          it_behaves_like "untampered user model"
        end
      end

      context "when admin terms" do
        let(:path) { "admin/admin_terms" }

        it_behaves_like "tampered users model"

        context "when POST" do
          let(:method) { "POST" }

          it_behaves_like "tampered users model"
        end
      end

      context "when admin out of scope" do
        let(:path) { "admin/some_path" }

        it_behaves_like "untampered user model"
      end

      context "when admin an assembly" do
        let(:path) { "admin/assemblies/#{assembly.slug}" }

        it_behaves_like "tampered users model"

        context "and accessing assemblies index" do
          let(:path) { "admin/assemblies" }

          it_behaves_like "tampered users model"

          context "when POST" do
            let(:method) { "POST" }

            it_behaves_like "untampered user model"
          end
        end
      end

      context "and accessing another assemblies index" do
        let(:path) { "admin/assemblies/#{another_assembly.slug}" }

        it_behaves_like "untampered user model"
      end

      context "when admin a participatory process" do
        let(:path) { "admin/participatory_processes/some-process" }

        it_behaves_like "tampered admin model"
      end
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

        context "and user have the none constraint" do
          let!(:constraint_bar2) { create(:config_constraint, awesome_config: config_helper_bar, settings: settings_none) }

          it_behaves_like "same environment"
          it_behaves_like "tampered admin model"
        end
      end
    end
  end
end
