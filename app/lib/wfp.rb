# class to generate Wayforpay request for adding new card
class Wfp
  DEFAULTS = {
    straightWidget: true,
    merchantDomainName: ENV['WAYFORPAY_DOMAIN'],
    merchantTransactionType: 'AUTH',
    holdTimeout: 60,
    authorizationType: 'SimpleSignature',
    amount: '1',
    currency: 'UAH',
    productName: 'Удержание за добавление карты',
    productPrice: '1',
    transactionType: 'VERIFY',
    productCount: '1',
    paymentSystem: 'card',
    merchantAccount: ENV['WAYFORPAY_MERCHANT']
  }.freeze

  attr_reader :params

  def initialize(user, url)
    date = Time.now.to_i
    ref = OpenSSL::Digest::MD5.new("#{date} #{user.auth_token}").to_s
    @params = {
      clientPhone: user.phone_number,
      clientEmail: user.email,
      orderDate: date,
      orderReference: ref,
      serviceUrl: url,
      merchantSignature: sign(ref, date)
    }.merge(DEFAULTS)
  end

  def sign(ref, date)
    signature = "#{ENV['WAYFORPAY_MERCHANT']};#{ENV['WAYFORPAY_DOMAIN']};#{ref};#{date};#{DEFAULTS[:amount]};#{DEFAULTS[:currency]};#{DEFAULTS[:productName]};1;1"
    OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('md5'), Wayforpay.encrypt_secret_key, signature)
  end
end
