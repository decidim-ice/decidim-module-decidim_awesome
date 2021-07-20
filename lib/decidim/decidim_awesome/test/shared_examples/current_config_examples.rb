# frozen_string_literal: true

shared_examples "same environment" do
  it "do not modify the environment" do
    code, new_env = middleware.call(env)

    expect(new_env).to eq(env)
    expect(code).to eq(200)
  end

  it "has current organization in env" do
    _code, new_env = middleware.call(env)

    expect(new_env["decidim.current_organization"]).to eq(env["decidim.current_organization"])
    expect(new_env["decidim_awesome.current_config"]).to be_a Decidim::DecidimAwesome::Config
  end
end

shared_examples "untampered user model" do
  it "user model is reset" do
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

    context "when additional slashes" do
      let(:path) { "/admin/" }

      it_behaves_like "untampered user model"
    end

    context "when multiple slashes" do
      let(:path) { "//admin/" }

      it_behaves_like "untampered user model"
    end

    context "when POST" do
      let(:method) { "POST" }

      it_behaves_like "untampered user model"
    end

    context "when PATCH" do
      let(:method) { "PATCH" }

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

      context "when PATCH" do
        let(:method) { "PATCH" }

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
