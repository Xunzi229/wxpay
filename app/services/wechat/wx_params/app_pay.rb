# 微信APP支付
# 参数处理逻辑
# 返回 一个 XML字符串
#
module Wechat
  module WxParams
    class AppPay
      include Wechat::WxParams::Unitable

      # 这是 商户设置的key
      attr_accessor :key

      # 下单参数转化
      def unifiedorder(params = {})
        @key = params.delete(:key)

        request_params = {
          appid:             params[:appid],
          mch_id:            params[:mch_id],
          body:              params[:body],
          out_trade_no:      params[:out_trade_no],
          total_fee:         (params[:total_fee].to_f * 100).to_i,
          spbill_create_ip:  params[:spbill_create_ip],
          notify_url:        params[:notify_url],
          trade_type:        "APP",
          sign_type:         "MD5"
        }
        request_params.each do |_key, _value|
          if _value.blank?
            _msg = "微信APP支付下单接口参数不全: #{_key}"
            raise Exceptions::Wechat::ApiParamsIncompleteException, _msg
          end
        end
        common_deal_with(request_params)
      end

      # 订单退款查询参数
      def refundquery(params = {})
        @key = params.delete(:key)

        request_params = {
          appid: params[:appid],
          mch_id: params[:mch_id],
          out_trade_no: params[:out_trade_no]
        }

        request_params.each do |_key, _value|
          if _value.blank?
            _msg = "微信支付订单退款接口参数不全: #{_key}"
            raise Exceptions::Wechat::ApiParamsIncompleteException, _msg
          end
        end

        common_deal_with(request_params)
      end

    end
  end
end