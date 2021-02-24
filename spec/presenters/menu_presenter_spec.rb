# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe MenuPresenter, type: :helper do
    subject { MenuPresenter.new(:custom_menu, view) }

    let(:override) do
      [{
        url: "/foo",
        label: {
          "en" => "Fumanchu"
        },
        position: 10
      },
       {
         url: "/baz",
         label: {
           "en" => "Baz"
         },
         position: 3
       }]
    end
    let(:user) { create :user, organization: organization }
    let(:organization) { create :organization }
    let!(:config) { create :awesome_config, organization: organization, var: :custom_menu, value: override }

    before do
      allow(view).to receive(:current_organization).and_return(organization)
      allow(view).to receive(:current_user).and_return(user)
      MenuRegistry.register :custom_menu do |menu|
        menu.item "Foo", "/foo", position: 1
        menu.item "Bar", "/bar", position: 2
        menu.item "Baz", "/baz", if: Time.current.year == 2000
        menu.item "Hid", "/hid", if: Time.current.year == 2000
      end
    end

    after do
      MenuRegistry.destroy(:custom_menu)
      Decidim::DecidimAwesome.config.except!(:custom_menu)
    end

    shared_examples "has default items" do
      it "renders the menu as a navigation list and skips non visible" do
        expect(subject.render).to \
          have_selector("ul") &
          have_selector("li", count: 2) &
          have_link("Foo", href: "/foo") &
          have_link("Bar", href: "/bar")
      end

      it "renders the menu in the right order" do
        expect(subject.render).to \
          have_selector("ul") &
          have_selector("li:first-child", text: "Foo") &
          have_selector("li:last-child", text: "Bar")
      end

      it "returns instance of Decidim:Menu" do
        expect(subject.evaluated_menu).to be_a(Decidim::Menu)
      end
    end

    shared_examples "has overriden items" do
      it "renders the menu as a navigation list" do
        expect(subject.render).to \
          have_selector("ul") &
          have_selector("li", count: 3) &
          have_link("Bar", href: "/bar") &
          have_link("Fumanchu", href: "/foo") &
          have_link("Baz", href: "/baz")
      end

      it "renders the menu in the right order" do
        expect(subject.render).to \
          have_selector("ul") &
          have_selector("li:first-child", text: "Bar") &
          have_selector("li:last-child", text: "Fumanchu")
      end

      it "returns instance of Decidim:Menu" do
        expect(subject.evaluated_menu).to be_a(Decidim::DecidimAwesome::MenuHacker)
      end
    end

    context "when overrided menu is not an awesome config var" do
      it_behaves_like "has default items"
    end

    context "when overrided menu is disabled" do
      before do
        Decidim::DecidimAwesome.config[:custom_menu] = :disabled
      end

      it_behaves_like "has default items"
    end

    context "when overrided menu is enabled" do
      before do
        Decidim::DecidimAwesome.config[:custom_menu] = []
      end

      it_behaves_like "has overriden items"
    end
  end
end
