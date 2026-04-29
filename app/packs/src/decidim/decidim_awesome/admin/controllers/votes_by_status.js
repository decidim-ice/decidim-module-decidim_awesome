import { Controller } from "@hotwired/stimulus";
import TomSelect from "tom-select/dist/cjs/tom-select.popular";

const SUFFIX = "_awesome_votes_enabled_states";
const OUR_CHECKBOX_SUFFIX = "_awesome_votes_enabled_by_status";
const VOTES_CHECKBOX_SUFFIX = "_votes_enabled";

export default class extends Controller {
  connect() {
    if (!this.element.id.endsWith(SUFFIX)) {
      return;
    }

    const baseId = this.element.id.slice(0, -SUFFIX.length);
    this.ourCheckbox = document.getElementById(`${baseId}${OUR_CHECKBOX_SUFFIX}`);
    this.votesCheckbox = document.getElementById(`${baseId}${VOTES_CHECKBOX_SUFFIX}`);

    if (!this.ourCheckbox || !this.votesCheckbox) {
      return;
    }

    this.tomSelect = new TomSelect(this.element, {
      plugins: ["remove_button"],
      create: false
    });

    this.statesContainer = this.element.closest(".awesome_votes_enabled_states_container");
    this.ourContainer = this.ourCheckbox.closest(".awesome_votes_enabled_by_status_container");

    this.handleChange = this.handleChange.bind(this);
    this.ourCheckbox.addEventListener("change", this.handleChange);
    this.votesCheckbox.addEventListener("change", this.handleChange);

    this.handleChange();
  }

  disconnect() {
    this.ourCheckbox?.removeEventListener("change", this.handleChange);
    this.votesCheckbox?.removeEventListener("change", this.handleChange);
    this.tomSelect?.destroy();
  }

  handleChange() {
    const votesOn = this.votesCheckbox.checked;
    const ourOn = this.ourCheckbox.checked;

    if (this.ourContainer) {
      this.ourContainer.hidden = !votesOn;
    }
    if (this.statesContainer) {
      this.statesContainer.hidden = !(votesOn && ourOn);
    }
  }
}
