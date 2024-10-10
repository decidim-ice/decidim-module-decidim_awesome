# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe UpdateAccount do
    let(:command) { described_class.new(user, form) }
    let(:user) { create(:user, :confirmed, extended_data:) }
    let(:extended_data) { { "time_zone" => "UTC", "another_value" => "Something" } }
    let(:data) do
      {
        name: user.name,
        nickname: user.nickname,
        email: user.email,
        password: nil,
        old_password: nil,
        avatar: nil,
        remove_avatar: nil,
        personal_url: "https://example.org",
        about: "This is a description of me",
        locale: "es",
        user_time_zone: ""
      }
    end

    let(:form) do
      AccountForm.from_params(
        name: data[:name],
        nickname: data[:nickname],
        email: data[:email],
        password: data[:password],
        old_password: data[:old_password],
        avatar: data[:avatar],
        remove_avatar: data[:remove_avatar],
        personal_url: data[:personal_url],
        about: data[:about],
        locale: data[:locale],
        user_time_zone: data[:user_time_zone]
      ).with_context(current_organization: user.organization, current_user: user)
    end

    context "when invalid" do
      before do
        allow(form).to receive(:valid?).and_return(false)
      end

      it "does not update anything" do
        form.name = "John Doe"
        form.name = "Europe/Berlin"
        old_name = user.name
        expect { command.call }.to broadcast(:invalid)
        expect(user.reload.name).to eq(old_name)
        expect(user.extended_data["time_zone"]).to eq("UTC")
        expect(user.extended_data["another_value"]).to eq("Something")
      end
    end

    context "when timezone is invalid" do
      let(:time_zone) { "giberish" }

      it "returns valid" do
        form.user_time_zone = time_zone
        expect { command.call }.to broadcast(:ok)
      end
    end

    shared_examples_for "ignores the time zone" do
      it "does not update the users's timezone" do
        form.user_time_zone = "Europe/Berlin"
        form.name = "John Mayall"
        expect { command.call }.to broadcast(:ok)
        expect(user.reload.name).to eq("John Mayall")
        expect(user.extended_data["time_zone"]).to eq("UTC")
        expect(user.extended_data["another_value"]).to eq("Something")
      end
    end

    context "when valid" do
      it_behaves_like "ignores the time zone"

      context "when user_timezone is true" do
        before do
          allow(Decidim::DecidimAwesome).to receive(:config).and_return(user_timezone: true)
        end

        context "when timezone is invalid" do
          let(:time_zone) { "giberish" }

          it "returns valid" do
            form.user_time_zone = time_zone
            expect { command.call }.to broadcast(:invalid)
          end
        end

        it "updates the users's timezone" do
          form.name = "John Mayall"
          form.user_time_zone = "Europe/Berlin"
          expect { command.call }.to broadcast(:ok)
          expect(user.reload.name).to eq("John Mayall")
          expect(user.extended_data["time_zone"]).to eq("Europe/Berlin")
          expect(user.extended_data["another_value"]).to eq("Something")
        end
      end
    end

    context "when user_timezone is :disabled" do
      before do
        allow(Decidim::DecidimAwesome).to receive(:config).and_return(user_timezone: :disabled)
      end

      it_behaves_like "ignores the time zone"
    end
  end
end
