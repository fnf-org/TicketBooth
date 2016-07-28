require 'tempfile'
require 'csv'

# Handles payments for early access/late departure passes.
class EaldPaymentsController < ApplicationController
  before_filter :set_event
  before_filter :require_event_admin, except: %i[new create complete]

  include ActionView::Helpers::NumberHelper

  def index
    @eald_payments = EaldPayment.where(event_id: @event)
                                .order('created_at DESC')
                                .to_a
  end

  def new
    # TODO: Remove once we have auto shutdown enabled
    redirect_to root_path, notice: 'EA/LD sales have closed'

    email = params.fetch(:email, '')
    full_name = params.fetch(:name, '')
    early_arrival_passes = params.fetch(:early_arrival_passes, 1)
    late_departure_passes = params.fetch(:late_departure_passes, 1)
    @eald_payment = EaldPayment.new(event_id: @event.id,
                                    email: email,
                                    name: full_name,
                                    early_arrival_passes: early_arrival_passes,
                                    late_departure_passes: late_departure_passes)
  end

  def create
    @eald_payment = EaldPayment.new(params[:eald_payment])

    if @eald_payment.save_and_charge!
      EaldPaymentMailer.eald_payment_received(@eald_payment).deliver
      redirect_to complete_event_eald_payments_path(@event)
    else
      render action: 'new'
    end
  end

  def complete
    render
  end

  def download
    temp_csv = Tempfile.new('csv')

    CSV.open(temp_csv.path, 'wb') do |csv|
      csv << %w[name email transaction_id early_arrival_passes late_departure_passes timestamp]
      EaldPayment.where(event_id: @event).find_each do |p|
        csv << [p.name,
                p.email,
                p.stripe_charge_id,
                p.early_arrival_passes,
                p.late_departure_passes,
                p.created_at.to_i]
      end
    end

    temp_csv.close
    send_file(temp_csv.path,
              filename: "#{@event.name} EALD Passes.csv",
              type: 'text/csv')
  end

  private

  def set_event
    @event = Event.find(params[:event_id])
  end
end
