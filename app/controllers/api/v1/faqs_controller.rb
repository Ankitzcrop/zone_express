class Api::V1::FaqsController < ApplicationController
  skip_before_action :verify_authenticity_token
  
  # GET /api/v1/faqs
  def index
    faqs = ::Faq.all

    render json: {
      success: true,
      data: {
        faqs: faqs.map do |faq|
          {
            id: faq.id,
            category: faq.category,
            question: faq.question,
            answer: faq.answer
          }
        end
      }
    }, status: :ok
  end

  # POST /api/v1/faqs
  def create
    faq = ::Faq.new(faq_params)

    if faq.save
      render json: {
        success: true,
        message: "FAQ created successfully",
        data: {
          id: faq.id,
          category: faq.category,
          question: faq.question,
          answer: faq.answer
        }
      }, status: :created
    else
      render json: {
        success: false,
        message: "FAQ could not be created",
        errors: faq.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  private

  def faq_params
    params.permit(:category, :question, :answer)
  end
end
