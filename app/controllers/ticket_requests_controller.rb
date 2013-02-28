class TicketRequestsController < ApplicationController
  before_filter :authenticate_user!,
    only: [:index, :show, :edit, :update, :approve, :decline]
  before_filter :require_site_admin,
    only: [:index, :edit, :update, :approve, :decline]

  def index
    @ticket_requests = TicketRequest.all.sort_by(&:created_at).reverse
  end

  def show
    @ticket_request = TicketRequest.find(params[:id])
    return redirect_to root_path unless @ticket_request.can_view?(current_user)
  end

  def new
    if signed_in?
      existing_request = TicketRequest.where(user_id: current_user).first
      return redirect_to existing_request if existing_request.present?

      # Otherwise we're creating a ticket request as the signed-in user
      @user = current_user
    end

    @ticket_request = TicketRequest.new
  end

  def edit
    @ticket_request = TicketRequest.find(params[:id])
    @user = @ticket_request.user
  end

  def create
    @ticket_request = TicketRequest.new(params[:ticket_request])

    unless signed_in?
      # User parameters are included separately
      user = User.new(params.slice(:name, :email, :password, :password_confirmation))

      if user.save
        @ticket_request.user_id = user.id

        # Automatically sign in so that if there's something wrong with the
        # ticket request we don't need to create another user.
        sign_in(user)
      else
        # Add user errors to ticket validation since we're piggy-backing on the
        # ticket form
        user.errors.full_messages.each do |error|
          @ticket_request.errors[:base] << error
        end

        return render action: 'new'
      end
    end

    if @ticket_request.save
      flash[:notice] = 'Your ticket request was successfully recorded.'
      redirect_to @ticket_request
    else
      render action: 'new'
    end
  end

  def update
    @ticket_request = TicketRequest.find(params[:id])

    if @ticket_request.update_attributes(params[:ticket_request])
      flash[:notice] = 'Ticket request was successfully updated.'
      redirect_to @ticket_request
    else
      render action: 'edit'
    end
  end

  def approve
    @ticket_request = TicketRequest.find(params[:id])

    if @ticket_request.update_attributes(status: TicketRequest::STATUS_APPROVED)
      TicketRequestMailer.request_approved(@ticket_request).deliver

      flash[:notice] = "#{@ticket_request.user.name}'s request was approved"
      redirect_to ticket_requests_path
    else
      flash[:error] = "Unable to approve #{@ticket_request.user.name}'s request"
      redirect_to ticket_requests_path
    end
  end

  def decline
    @ticket_request = TicketRequest.find(params[:id])

    if @ticket_request.update_attributes(status: TicketRequest::STATUS_DECLINED)
      flash[:notice] = "#{@ticket_request.user.name}'s request was declined"
      redirect_to ticket_requests_path
    else
      flash[:error] = "Unable to decline #{@ticket_request.user.name}'s request"
      redirect_to ticket_requests_path
    end
  end
end
