// Toggle voting cards settings visibility based on awesome_voting_manifest value
document.addEventListener("DOMContentLoaded", () => {
  const votingManifestSelect = document.querySelector("#component_settings_awesome_voting_manifest");

  if (!votingManifestSelect) {
    return;
  }

  const votingCardsFields = [
    "voting_cards_box_title",
    "voting_cards_show_modal_help",
    "voting_cards_show_abstain",
    "voting_cards_instructions"
  ];

  const toggleVotingCardsFields = () => {
    const isVotingCards = votingManifestSelect.value === "voting_cards";

    votingCardsFields.forEach((fieldName) => {
      const container = document.querySelector(`.${fieldName}_container`);
      if (container) {
        container.style.display = isVotingCards
          ? ""
          : "none";
      }
    });
  };

  toggleVotingCardsFields();

  votingManifestSelect.addEventListener("change", toggleVotingCardsFields);
});
