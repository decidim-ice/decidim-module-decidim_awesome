# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  module Admin
    describe CreateScopedAdmin do
      subject { described_class.new(organization) }

      let(:organization) { create(:organization) }
      let(:context) do
        {
          current_user: create(:user, organization: organization),
          current_organization: organization
        }
      end
      let(:params) do
        {
          allow_images_in_full_editor: true,
          allow_images_in_small_editor: true
        }
      end
      let(:form) do
        ConfigForm.from_params(params).with_context(context)
      end
      let(:another_config) { UpdateConfig.new(form) }
      let(:scoped_admins) do
        AwesomeConfig.find_by(organization: organization, var: :scoped_admins)
      end

      shared_examples "create default constraints" do
        let(:subconfig) do
          AwesomeConfig.find_by(organization: organization, var: "scoped_admin_#{key}")
        end

        it "creates a 'none' constraint by default" do
          expect { subject.call }.to broadcast(:ok)
          expect(subconfig.constraints.count).to eq(1)
          expect(subconfig.constraints.first.settings).to eq({ "participatory_space_manifest" => "none" })
        end
      end

      describe "when valid" do
        it "broadcasts :ok and creates a Hash" do
          expect { subject.call }.to broadcast(:ok)

          expect(scoped_admins.value).to be_a(Hash)
          expect(scoped_admins.value.keys.count).to eq(1)
        end

        it_behaves_like "create default constraints" do
          let(:key) { scoped_admins.value.keys.first }
        end

        context "and entries already exist" do
          let!(:config) { create :awesome_config, organization: organization, var: :scoped_admins, value: { test: [123, 456] } }

          shared_examples "has scoped admin boxes content" do
            it "do not removes previous entries" do
              expect { subject.call }.to broadcast(:ok)

              expect(scoped_admins.value.keys.count).to eq(2)
              expect(scoped_admins.value.values).to include([123, 456])
            end
          end

          it_behaves_like "has scoped admin boxes content"
          it_behaves_like "create default constraints" do
            let(:key) { scoped_admins.value.keys.last }
          end

          context "and another configuration is created" do
            before do
              another_config.call
            end

            it "modifies the other config" do
              expect(AwesomeConfig.find_by(organization: organization, var: :allow_images_in_full_editor).value).to eq(true)
              expect(AwesomeConfig.find_by(organization: organization, var: :allow_images_in_small_editor).value).to eq(true)
            end

            it_behaves_like "has scoped admin boxes content"
          end

          context "and another configuration is updated" do
            let!(:existing_config) { create :awesome_config, organization: organization, var: :allow_images_in_full_editor, value: false }

            before do
              another_config.call
            end

            it "modifies the other config" do
              expect(AwesomeConfig.find_by(organization: organization, var: :allow_images_in_full_editor).value).to eq(true)
              expect(AwesomeConfig.find_by(organization: organization, var: :allow_images_in_small_editor).value).to eq(true)
            end

            it_behaves_like "has scoped admin boxes content"
          end
        end
      end

      describe "when invalid" do
        subject { described_class.new("nonsense") }

        it "broadcasts :invalid and does not modifiy the config options" do
          expect { subject.call }.to broadcast(:invalid)

          expect(scoped_admins).to eq(nil)
        end
      end
    end
  end
end
