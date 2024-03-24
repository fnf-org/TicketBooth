# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  DEFAULT_SENDER_EMAIL = 'tickets@fnf.org'
  DEFAULT_REPLY_TO_EMAIL = 'tickets@fnf.org'

  layout 'email'

  abstract!
end
