import {Controller} from "@hotwired/stimulus";
import flatpickr from "flatpickr";

// Connects to data-controller="flatpickr"
export default class FlatpickrController extends Controller {
  connect() {
    flatpickr(".flatpickr-date-time", {
          enableTime: true,
          altInput: false,
          dateFormat: "m/d/Y, h:i K",
          minDate: "today",
        }
    );

    // this isn't in use at the moment
    flatpickr(".flatpickr-date", {
          altInput: false,
          enableTime: false,
          dateFormat: "m/d/Y",
        }
    );
  }
}
