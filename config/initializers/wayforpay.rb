Wayforpay.configure do |config|
  config.merchant_account = ENV['WAYFORPAY_MERCHANT']
  config.merchant_domain_name = ENV['WAYFORPAY_DOMAIN']
  config.encrypt_secret_key = ENV['WAYFORPAY_SECRET']
end
