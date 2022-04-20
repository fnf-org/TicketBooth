# frozen_string_literal: true

# Allows us to trigger a password reset from the client.
class PasswordsController < ApplicationController
  def reset
    email = params[:email].presence
    if email && user = User.where(email: email).first
      user.send_reset_password_instructions
    end

    redirect_to request.referrer, alert: 'A password reset link has been sent to your email!'
  end
end
