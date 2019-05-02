class AdminMailer < ApplicationMailer
    def new_driver_request(params)
      @name = params[:name]
      @surname = params[:surname]
      @phone = params[:phone]
      @email = params[:email].present? ? params[:email] : 'Не вказано'
      @comment = params[:comment].present? ? params[:comment] : 'Не вказано'
      attachments[params[:cv].original_filename] = File.read(params[:cv].path) if params[:cv]
      mail from: params[:email].present? ? params[:email] : 'contact@cablook.taxi',
           to: 'contact@cablook.taxi',
           subject: 'Анкета водія на роботу | Cablook Taxi'
    end
  end
  