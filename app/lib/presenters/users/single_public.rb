class Presenters::Users::SinglePublic < Presenters::BaseSingle
  properties :id, :email, :phone_number, :referral_code, :trips_count, :vip
end
