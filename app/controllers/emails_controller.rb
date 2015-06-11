class EmailsController < ApplicationController
  def index
    respond_to do |format|
      format.any do
        if User.where(email: params[:email]).first
          head :ok
        else
          head :not_found
        end
      end
    end
  end
end
