class WebHookController < ApplicationController
  include Mandrill::Rails::WebHookProcessor

  def handle_inbound(payload)
    MandrillMailer.inbound_email(payload['msg']).deliver
  end
end
