class Presenters::DriversApp::Driver::Single < Presenters::BaseSingle
  properties :id, :name, :auth_token, :car, :balance

  property :card_number, exec_context: :decorator

  def card_number
    represented.card_number.gsub!(/\d(?<=\d{5})(?=\d{4})/, '*').scan(/.{1,4}/).join(' ')
  end
end
