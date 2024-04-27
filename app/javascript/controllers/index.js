// This file is auto-generated by ./bin/rails stimulus:manifest:update
// Run that command whenever you add a new controller or create them with
// ./bin/rails generate stimulus controllerName

import { application } from "./application"

import FlatpickrController from "./flatpickr_controller"
application.register("flatpickr", FlatpickrController)

import FlashController from "./flash_controller"
application.register("flash", FlashController)

import PaymentsController from "./payments_controller"
application.register("payments", PaymentsController)

import PopoversController from "./popovers_controller"
application.register("popovers", PopoversController)

import TicketRequestsController from "./ticket_requests_controller"
application.register("ticket-requests", TicketRequestsController)
