# frozen_string_literal: true

class EmailsController < ApplicationController
  def index
    respond_to do |format|
      format.any do
        if User.where(email: email_params[:email]).first
          head :ok
        else
          head :not_found
        end
      end
    end
  end

  private

  def email_params
    params.permit(:email)
  end
end
