# frozen_string_literal: true

require "spec_helper"

module Decidim::Proposals
  module Admin
    describe CreateProposal do
      subject { described_class.new(form) }

      let(:organization) { create(:organization) }
      let(:user) { create(:user, :admin, organization: organization) }
      let(:participatory_process) { create(:participatory_process, :with_steps, organization: organization) }
      let(:component) { create(:proposal_component, :with_creation_enabled, participatory_space: participatory_process) }
      let(:context) do
        {
          current_user: user,
          current_organization: organization,
          current_component: component
        }
      end
      let(:params) do
        {
          title: title,
          body: body,
          private_body: private_body
        }
      end
      let(:title) do
        { "en" => "A valid proposal title" }
      end
      let(:body) do
        { "en" => "A valid proposal body" }
      end
      let(:private_body) { "A valid private proposal body" }
      let(:form) do
        Decidim::Proposals::Admin::ProposalForm.from_params(params).with_context(context)
      end
      let(:proposal) { Decidim::Proposals::Proposal.last }

      it "broadcasts :ok and creates a private_body" do
        expect { subject.call }.to broadcast(:ok)
        expect(proposal.title).to eq(title)
        expect(proposal.body).to eq(body)
        expect(proposal.component).to eq(component)
        expect(proposal.private_body).to eq(private_body)
        expect(proposal.extra_fields.private_body).to eq(private_body)
      end

      context "when no private_body" do
        let(:private_body) { nil }

        it "broadcasts :ok and does not create extra_fields" do
          expect { subject.call }.to broadcast(:ok)
          expect(proposal.title).to eq(title)
          expect(proposal.body).to eq(body)
          expect(proposal.component).to eq(component)
          expect(proposal.private_body).to be_nil
          expect(proposal.extra_fields).to be_nil
        end
      end
    end
  end
end
