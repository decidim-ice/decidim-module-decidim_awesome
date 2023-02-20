# frozen_string_literal: true

shared_examples "a user presenter" do
  describe "#last_sign_in_date" do
    it "returns never logged in yet" do
      expect(subject.last_sign_in_date).to eq("<span class=\"muted\">Never logged yet</span>")
    end

    context "when no html" do
      let(:html) { false }

      it "returns never logged in yet" do
        expect(subject.last_sign_in_date).to eq("Never logged yet")
      end
    end

    context "when user has logged before" do
      let(:user) { create :user, organization: organization, last_sign_in_at: 1.day.ago }

      it "returns the last sign in date" do
        expect(subject.last_sign_in_date).to eq(1.day.ago.strftime("%d/%m/%Y %H:%M"))
      end
    end
  end

  describe "#user" do
    it "returns the user" do
      expect(subject.user).to eq(user)
    end

    it "returns email" do
      expect(subject.user_email).to eq(user.email)
    end

    it "returns user name" do
      expect(subject.user_name).to eq(user.name)
    end
  end

  describe "#removal_date" do
    it "returns currently active" do
      expect(subject.removal_date).to eq("<span class=\"text-success\">Currently active</span>")
    end

    context "when html is disabled" do
      let(:html) { false }

      it "returns currently active" do
        expect(subject.removal_date).to eq("Currently active")
      end
    end

    context "when the role was removed" do
      include_context "with role destroyed"

      it "returns the removal date" do
        expect(subject.removal_date).to eq(destroyed_at.strftime("%d/%m/%Y %H:%M"))
      end
    end
  end
end
