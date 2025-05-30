# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  describe UserAutoblockScoresPresenter, type: :helper do
    let(:user) { create(:user, organization:) }
    let(:organization) { create(:organization) }
    let!(:config) { create(:awesome_config, organization:, var: :users_autoblocks, value: rules) }
    let(:rules) { [] }
    let(:about_blank_rule) do
      { "id" => 1, "type" => "about_blank", "weight" => weight, "allowlist" => allowlist, "blocklist" => blocklist, "application_type" => application_type }
    end
    let(:activities_blank_rule) do
      { "id" => 2, "type" => "activities_blank", "weight" => weight, "allowlist" => allowlist, "blocklist" => blocklist, "application_type" => application_type }
    end
    let(:links_in_comments_or_about_rule) do
      { "id" => 3, "type" => "links_in_comments_or_about", "weight" => weight, "allowlist" => allowlist, "blocklist" => blocklist, "application_type" => application_type }
    end
    let(:email_unconfirmed_rule) do
      { "id" => 4, "type" => "email_unconfirmed", "weight" => weight, "allowlist" => allowlist, "blocklist" => blocklist, "application_type" => application_type }
    end
    let(:email_domain_rule) do
      { "id" => 5, "type" => "email_domain", "weight" => weight, "allowlist" => allowlist, "blocklist" => blocklist, "application_type" => application_type }
    end
    let(:links_in_comments_or_about_with_domains_rule) do
      { "id" => 6, "type" => "links_in_comments_or_about_with_domains", "weight" => weight, "allowlist" => allowlist, "blocklist" => blocklist, "application_type" => application_type }
    end
    let(:weight) { 10 }
    let(:allowlist) { "" }
    let(:blocklist) { "" }
    let(:application_type) { "positive" }

    subject { described_class.new(user) }

    describe "#scores" do
      shared_examples "a scored rule" do
        it "the user is scored" do
          expect(subject.scores[:total_score]).to eq(weight)
          expect(score_of_rule(subject.scores, rule)).to eq(weight)
        end
      end

      shared_examples "a not scored rule" do
        it "the user is not scored" do
          expect(subject.scores[:total_score]).to be_zero
          expect(score_of_rule(subject.scores, rule)).to be_zero
        end
      end

      shared_examples "a satisfied rule" do
        it_behaves_like "a scored rule"

        context "when the email domain is in the allowlist" do
          let(:allowlist) { "spam.org" }

          it_behaves_like "a not scored rule"
        end

        context "when the email domain is in the blocklist" do
          let(:blocklist) { "spam.org" }

          it_behaves_like "a scored rule"
        end

        context "when the application is negative" do
          let(:application_type) { "negative" }

          it_behaves_like "a not scored rule"
        end
      end

      shared_examples "an unsatisfied rule" do
        it_behaves_like "a not scored rule"

        context "when the email domain is in the allowlist" do
          let(:allowlist) { "spam.org" }

          it_behaves_like "a not scored rule"
        end

        context "when the email domain is in the blocklist" do
          let(:blocklist) { "spam.org" }

          it_behaves_like "a not scored rule"
        end

        context "when the application is negative" do
          let(:application_type) { "negative" }

          it_behaves_like "a scored rule"
        end
      end

      context "when no rules are defined" do
        it "returns 0" do
          expect(subject.scores).to eq({ total_score: 0 })
        end
      end

      context "when about_blank rule is defined" do
        let(:rules) { [rule] }
        let(:rule) { about_blank_rule }
        let(:user) { create(:user, organization:, about:, email: "user@spam.org") }
        let(:about) { nil }

        it "returns the total score and the rule score" do
          expect(subject.scores.keys).to include(:total_score, "About user section is blank - #{about_blank_rule["id"]}")
        end

        context "when the user about section is blank" do
          it_behaves_like "a satisfied rule"
        end

        context "when the user about section is present" do
          let(:about) { "Hi, I'm a great person" }

          it_behaves_like "an unsatisfied rule"
        end
      end

      context "when activities_blank rule is defined" do
        let(:rules) { [rule] }
        let(:rule) { activities_blank_rule }
        let(:user) { create(:user, organization:, email: "user@spam.org") }

        it "returns the total score and the rule score" do
          expect(subject.scores.keys).to include(:total_score, "User has not created contents - #{rule["id"]}")
        end

        context "when the user does not have activities" do
          it_behaves_like "a satisfied rule"
        end

        context "when the user has activities" do
          let(:process) { create(:participatory_process, organization:) }
          let(:component) { create(:component, manifest_name: "dummy", participatory_space: process) }
          let!(:activities) { create_list(:comment, 3, author: user, commentable: build(:dummy_resource, component:)) }

          it_behaves_like "an unsatisfied rule"
        end
      end

      context "when links_in_comments_or_about rule is defined" do
        let(:rules) { [rule] }
        let(:rule) { links_in_comments_or_about_rule }
        let(:user) { create(:user, organization:, about:, email: "user@spam.org") }
        let(:about) { "Hi, here I am" }

        it "returns the total score and the rule score" do
          expect(subject.scores.keys).to include(:total_score, "Comments or about section contains links - #{rule["id"]}")
        end

        context "when the user has links in the about section" do
          let(:about) { 'Hi visit my <a href="http://itsatrap.com/test">site</a>!' }

          it_behaves_like "a satisfied rule"
        end

        context "when the user has comments with links" do
          let(:process) { create(:participatory_process, organization:) }
          let(:component) { create(:component, manifest_name: "dummy", participatory_space: process) }
          let!(:comment) { create(:comment, author: user, body: "You can visit the site http://itsanothertrap.com/test", commentable: build(:dummy_resource, component:)) }

          it_behaves_like "a satisfied rule"
        end

        context "when the user has no links" do
          it_behaves_like "an unsatisfied rule"
        end
      end

      context "when email_unconfirmed rule is defined" do
        let(:rules) { [rule] }
        let(:rule) { email_unconfirmed_rule }
        let(:user) { create(:user, organization:, email: "user@spam.org") }

        it "returns the total score and the rule score" do
          expect(subject.scores.keys).to include(:total_score, "User email is not confirmed - #{rule["id"]}")
        end

        context "when the user is not confirmed" do
          it_behaves_like "a satisfied rule"
        end

        context "when the user is confirmed" do
          let(:user) { create(:user, :confirmed, organization:, email: "user@spam.org") }

          it_behaves_like "an unsatisfied rule"
        end
      end

      context "when email_domain rule is defined" do
        let(:rules) { [rule] }
        let(:rule) { email_domain_rule }
        let(:user) { create(:user, organization:, email: "user@blockme.com") }

        it "returns the total score and the rule score" do
          expect(subject.scores.keys).to include(:total_score, "Email domain included in list - #{rule["id"]}")
        end

        context "when the user email domain is in the blocklist" do
          let(:blocklist) { "blockme.com" }

          it_behaves_like "a scored rule"

          context "when the email domain is in the allowlist" do
            let(:allowlist) { "blockme.com" }

            it_behaves_like "a not scored rule"
          end

          context "when the application is negative" do
            let(:application_type) { "negative" }

            it_behaves_like "a not scored rule"
          end
        end

        context "when the user email domain is not in the blocklist" do
          let(:blocklist) { "example.org" }

          it_behaves_like "a not scored rule"

          context "when the email domain is in the allowlist" do
            let(:allowlist) { "blockme.com" }

            it_behaves_like "a not scored rule"
          end

          context "when the application is negative" do
            let(:application_type) { "negative" }

            it_behaves_like "a not scored rule"
          end
        end
      end

      context "when links_in_comments_or_about_with_domains rule is defined" do
        let(:rules) { [rule] }
        let(:rule) { links_in_comments_or_about_with_domains_rule }
        let(:user) { create(:user, organization:, about:, email: "user@spam.org") }
        let(:about) { "Hi, here I am" }

        it "returns the total score and the rule score" do
          expect(subject.scores.keys).to include(:total_score, "Comments or about section contains links with domains in allowlists or blocklists - #{rule["id"]}")
        end

        context "when the user has links in the about section" do
          let(:about) { 'Hi visit my <a href="http://itsatrap.com/test">site</a>!' }

          it_behaves_like "a scored rule"

          context "when the about section domain link is in the allowlist" do
            let(:allowlist) { "itsatrap.com" }

            it_behaves_like "a not scored rule"
          end

          context "when the about section domain link is in the blocklist" do
            let(:blocklist) { "itsatrap.com" }

            it_behaves_like "a scored rule"
          end

          context "when the application is negative" do
            let(:application_type) { "negative" }

            it_behaves_like "a not scored rule"
          end
        end

        context "when the user has comments with links" do
          let(:process) { create(:participatory_process, organization:) }
          let(:component) { create(:component, manifest_name: "dummy", participatory_space: process) }
          let!(:comment) { create(:comment, author: user, body: "You can visit the site http://itsanothertrap.com/test", commentable: build(:dummy_resource, component:)) }

          it_behaves_like "a scored rule"

          context "when the about section domain link is in the allowlist" do
            let(:allowlist) { "itsanothertrap.com" }

            it_behaves_like "a not scored rule"
          end

          context "when the about section domain link is in the blocklist" do
            let(:blocklist) { "itsanothertrap.com" }

            it_behaves_like "a scored rule"
          end

          context "when the application is negative" do
            let(:application_type) { "negative" }

            it_behaves_like "a not scored rule"
          end
        end

        context "when the user has no links" do
          it_behaves_like "an unsatisfied rule"
        end
      end
    end
  end
end

def score_of_rule(scores, rule)
  scores.find { |key, _value| /- #{rule["id"]}\z/.match?(key) }.last
end
