module Wechat
  class CallbackService

    def initialize
      @wxservice = Wechat::CoreService.new
      @api = Wechat::ApiService.new
    end

    # 用于发送业务逻辑，处理业务逻辑问题
    #
    def notify(xmlbody, service = nil)
      result = Hash.from_xml(xmlbody)
      result = ActiveSupport::HashWithIndifferentAccess.new(result)

      # 处理错误结果
      pay_error_notify(result)

      wxpay = Wxpay.find_by(out_transaction_no: result[:xml][:out_trade_no])
      return false if wxpay.blank?

      callback_validate_sign(result)
      handle_success_deal_with_service(result[:xml])

      @wxservice.order_detail(result[:xml]) rescue (
        _attrs = { out_source_status: (result[:xml][:return_code] rescue nil) }
        wxpay.update!(_attrs)
      )
    end

    # 处理成功后的逻辑
    #
    def handle_success_deal_with_service(result)
      #  处理支付成功后的逻辑
    end

    private

    # 支付错误结果处理
    # 可能出现的错误
    #
    def pay_error_notify(result)
      if result[:xml][:return_code] != "SUCCESS"
        _msg = (<<-EOF
            ==============微信支付回调错误结果:
              result: #{result}
              return_msg: #{result['xml']['return_msg']}
            ==============
          EOF
        ).gsub(/\s/, "")

        raise Exceptions::Wechat::ApiServiceException, message: _msg
      end

      if result[:xml][:result_code] != "SUCCESS"
        _msg = (<<-EOF
          ==============微信支付回调错误结果:
            result: #{result}
            err_code: #{result[:xml][:err_code]}
            err_code_des: #{result[:xml][:err_code_des]}
          ==============
          EOF
        ).gsub(/\s/, "")

        raise Exceptions::Wechat::MainServiceException, message: _msg
      end
    end

    # 验证签名
    #
    def callback_validate_sign(result)
      unless @api.valid?(result[:xml].merge({ kind: @wxpay.kind }))
        _msg = (<<-EOF
        ==============微信支付回调错误结果:
          result: #{result}
          签名验证失败
        ==============
        EOF
        ).gsub(/\s/, "")

        raise Exceptions::Wechat::MainServiceException, message: _msg
      end
    end
  end
end