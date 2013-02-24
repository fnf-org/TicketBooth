class TicketRequestsController < ApplicationController
  # GET /ticket_requests
  # GET /ticket_requests.json
  def index
    @ticket_requests = TicketRequest.all.sort_by(&:created_at).reverse

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @ticket_requests }
    end
  end

  # GET /ticket_requests/1
  # GET /ticket_requests/1.json
  def show
    @ticket_request = TicketRequest.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @ticket_request }
    end
  end

  # GET /ticket_requests/new
  # GET /ticket_requests/new.json
  def new
    @ticket_request = TicketRequest.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @ticket_request }
    end
  end

  # GET /ticket_requests/1/edit
  def edit
    @ticket_request = TicketRequest.find(params[:id])
  end

  # POST /ticket_requests
  # POST /ticket_requests.json
  def create
    @ticket_request = TicketRequest.new(params[:ticket_request])

    respond_to do |format|
      if @ticket_request.save
        format.html { redirect_to @ticket_request, notice: 'Your ticket request was successfully recorded.' }
        format.json { render json: @ticket_request, status: :created, location: @ticket_request }
      else
        format.html { render action: "new" }
        format.json { render json: @ticket_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /ticket_requests/1
  # PUT /ticket_requests/1.json
  def update
    @ticket_request = TicketRequest.find(params[:id])

    respond_to do |format|
      if @ticket_request.update_attributes(params[:ticket_request])
        format.html { redirect_to @ticket_request, notice: 'Ticket request was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @ticket_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ticket_requests/1
  # DELETE /ticket_requests/1.json
  def destroy
    @ticket_request = TicketRequest.find(params[:id])
    @ticket_request.destroy

    respond_to do |format|
      format.html { redirect_to ticket_requests_url }
      format.json { head :no_content }
    end
  end

  def approve
    @ticket_request = TicketRequest.find(params[:id])
    if @ticket_request.update_attributes(status: TicketRequest::STATUS_APPROVED)
      redirect_to ticket_requests_path,
        notice: "#{@ticket_request.name}'s request was approved"
    else
      redirect_to :back,
        notice: "Unable to approve #{@ticket_request.name}'s request"
    end
  end

  def decline
    @ticket_request = TicketRequest.find(params[:id])
    if @ticket_request.update_attributes(status: TicketRequest::STATUS_DECLINED)
      redirect_to :back,
        notice: "#{@ticket_request.name}'s request was declined"
    else
      redirect_to ticket_requests_path,
        notice: "Unable to decline #{@ticket_request.name}'s request"
    end
  end
end
