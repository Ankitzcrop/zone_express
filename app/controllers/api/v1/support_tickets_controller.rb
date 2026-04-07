class Api::V1::SupportTicketsController < ApplicationController
  skip_before_action :verify_authenticity_token
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

  before_action :set_support_ticket, only: [:show, :update, :destroy]

  def index
    tickets = SupportTicket.includes(:user).order(created_at: :desc)

    render json: tickets.map { |ticket| serialize_ticket(ticket) }, status: :ok
  end

  def show
    render json: serialize_ticket(@support_ticket), status: :ok
  end

  def create
    ticket = SupportTicket.new(ticket_params)

    if ticket.save
      render json: serialize_ticket(ticket), status: :created
    else
      render json: { errors: ticket.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @support_ticket.update(update_ticket_params)
      render json: serialize_ticket(@support_ticket), status: :ok
    else
      render json: { errors: @support_ticket.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @support_ticket.destroy
    render json: { message: "Support ticket deleted successfully" }, status: :ok
  end

  private

  def set_support_ticket
    @support_ticket = SupportTicket.includes(:user).find(params[:id])
  end

  def ticket_params
    params.require(:support_ticket).permit(
      :user_id,
      :status,
      :subject,
      :problem_description
    )
  end

  def update_ticket_params
    params.require(:support_ticket).permit(
      :status,
      :subject,
      :problem_description
    )
  end

  def serialize_ticket(ticket)
    {
      id: ticket.id,
      ticket_number: ticket.ticket_number,
      status: ticket.status,
      status_label: ticket.status.titleize,
      subject: ticket.subject,
      problem_description: ticket.problem_description,
      created_at: ticket.created_at,
      created_at_formatted: ticket.created_at.strftime("%b %d, %Y %H:%M"),
      user: {
        id: ticket.user.id,
        name: ticket.user.name,
        email: ticket.user.email,
        phone_number: ticket.user.phone_number,
        country_code: ticket.user.country_code,
        initials: ticket.user.initials
      }
    }
  end
end