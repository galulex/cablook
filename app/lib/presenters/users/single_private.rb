class Presenters::Users::SinglePrivate < Presenters::BaseSingle
  properties :id, :email, :phone_number, :auth_token
end
