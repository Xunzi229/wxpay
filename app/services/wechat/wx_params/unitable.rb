# 公共处理逻辑
# 参数转化过程
# 签名过程
#
module Wechat
  module WxParams
    module Unitable
      extend ActiveSupport::Concern

      included do
        # 这是 商户设置的key
        attr_accessor :key
      end

      # 订单查询参数
      def orderquery(params = {})
        @key = params.delete(:key)

        request_params = {
          appid:          params[:appid],
          mch_id:         params[:mch_id],
          out_trade_no:   params[:out_trade_no],
          sign_type:      "MD5"
        }

        request_params.each do |_key, _value|
          if _value.blank?
            _msg = "微信支付查询接口参数不全: #{_key}"
            raise Exceptions::Wechat::ApiParamsIncompleteException, _msg
          end
        end

        common_deal_with(request_params)
      end

      # 订单关闭 参数
      def closeorder(params = {})
        @key = params.delete(:key)

        request_params = {
          appid:         params[:appid],
          mch_id:        params[:mch_id],
          out_trade_no:  params[:out_trade_no],
          sign_type:     "MD5"
        }

        request_params.each do |_key, _value|
          if _value.blank?
            _msg = "微信支付订单关闭接口参数不全: #{_key}"
            raise Exceptions::Wechat::ApiParamsIncompleteException, _msg
          end
        end

        common_deal_with(request_params)
      end

      # 订单退款参数
      def refund(params = {})
        @key = params.delete(:key)

        request_params = {
          appid:         params[:appid],
          mch_id:        params[:mch_id],
          sign_type:     "MD5",
          out_trade_no:  params[:out_trade_no],
          out_refund_no: params[:out_refund_no],
          total_fee:     (params[:total_fee].to_f * 100).to_i,
          refund_fee:    (params[:refund_fee].to_f * 100).to_i,
        }

        request_params.each do |_key, _value|
          if _value.blank?
            _msg = "微信支付订单退款接口参数不全: #{_key}"
            raise Exceptions::Wechat::ApiParamsIncompleteException, _msg
          end
        end

        common_deal_with(request_params)
      end

      # 验证
      #
      def valid?(params = {})
        @key = params.delete(:key)

        _osign = params.delete(:sign)
        _nsign = valid(params)

        _osign == _nsign
      end

      # 微信APP支付的二次签名
      def second_sign(params = {})
        @key = params.delete(:key)
        request_params = {
          appid:     params[:appid],
          partnerid: params[:mch_id],
          prepayid:  params[:prepay_id],
          timestamp: params[:timestamp],
          package:   params[:package]
        }
        request_params.merge!({ noncestr: generate_nonce_str })
        request_params = sort_request_params(request_params)
        request_params.merge!({ sign: generate_sign(request_params) })

        "{#{request_params.map { |k, v| "\"#{k.to_s}\": \"#{v.to_s}\"" }.join(",")}}"
      end

      private

      def common_deal_with(request_params = {})
        # 获取随机字符串
        request_params.merge!({ nonce_str: generate_nonce_str })
        # 排序
        request_params = sort_request_params(request_params)
        # 加密随机字符串
        request_params.merge!({ sign: generate_sign(request_params) })
        # 转化随机字符串
        xmlparams_payload(request_params)
      end

      def xmlparams_payload(params = {})
        "<xml>\n#{params.map { |k, v| "<#{k}>#{v}</#{k}>" }.join("\n")}\n</xml>"
      end

      # 去创建随机字符串
      def generate_sign(params = {})
        preload = params.inject("") { |sum, m| sum + "&#{m[0]}=#{m[1]}"  }.sub(/&/, "")
        string_temp = "#{preload}&key=#{key}"

        Digest::MD5.hexdigest(string_temp).upcase
      end

      # 生成随机字符串
      def generate_nonce_str
        SecureRandom.hex(10)
      end

      def sort_request_params(params = {})
        params.sort.to_h
      end

      def valid(params = {})
        request_params = sort_request_params(params)
        generate_sign(request_params)
      end

    end
  end
end