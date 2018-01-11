Wayforpay.configure do |config|
    config.merchant_account = ENV['WAYFORPAY_MERCHANT_ACCOUNT'] # Seller identifier. This value is assigned to You from the side of WayForPay
    config.merchant_domain_name = ENV['WAYFORPAY_MERCHANT_DOMAIN_NAME']
    config.encrypt_secret_key = ENV['WAYFORPAY_ENCRYPT_SECRET_KEY']
end
