import {Controller} from "@hotwired/stimulus";
import flatpickr from "flatpickr";

// Connects to data-controller="flatpickr"
export default class FlatpickrController extends Controller {
  connect() {
    this.flatpickrInit();
  }

  flatpickrInit = function() {
    window.flatpickr(".flatpickr-date-time", {
          enableTime: true,
          altInput: false,
          dateFormat: "m/d/Y, h:i K",
          minDate: "today",
        }
    );

    // this isn't in use at the moment
    window.flatpickr(".flatpickr-date", {
          altInput: false,
          enableTime: false,
          dateFormat: "m/d/Y",
        }
    );
  }
}
