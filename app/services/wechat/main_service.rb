# 微信支付的业务接口
# 各接口可能返回的错误集合
#
module Wechat
  class MainService

    def initialize
      @api = Wechat::ApiService.new
    end

    # 创建订单
    # 订单号 为 payment transaction_no
    #
    # kind:   code, h5, app, applets
    #
    def create(params = {})
      params = trans_request_params(params)
      @wxpay = search_order_exist?(params[:out_trade_no])

      if @wxpay.nil?
        Wxpay.transaction do
          _attrs = {
            request_params:   YAML.dump(params),
            source_no:        params[:no],
            transaction_no:   params[:out_trade_no],
            total_fee:        params[:total_fee],
            trade_type:       params[:trade_type],
            kind:             params[:kind],
            openid:           params[:openid],
            appid:            params[:appid]
          }

          result = @api.unifiedorder(params)

          _attrs.merge!({
            response_params: YAML.dump(result),
            prepay_id: result[:prepay_id],
            code_url: result[:code_url],
            mweb_url: result[:mweb_url],
            transaction_id: result[:transaction_id],
            out_source_status: "NOTPAY"
          })
          @wxpay = Wxpay.create!(_attrs)
        end
      end

      # 增加 transaction_id
      # 返回参数
      case params[:kind]
      when "applets", "app" then @wxpay.prepay_id   # 小程序/APP 支付返回
      when "code" then  @wxpay.code_url # 扫码支付返回
      when "h5" then @wxpay.mweb_url # H5 支付返回
      else ; end
    end

    # 查询订单
    # 根据 payment no 去查找
    def order_detail(params = {})
      params = completion_request_parameter(params)
      @wxpay = Wxpay.find_by(transaction_no: params[:transaction_no])

      # 更新订单状态
      Wxpay.transaction do
        result = @api.orderquery(params)
        _attrs = {
          out_source_status: result[:trade_state],
          transaction_id: result[:transaction_id]
        }
        @wxpay.update!(_attrs)
      end

      @wxpay
    end

    # 取消订单
    def cancel(params = {})
      params = completion_request_parameter(params)
      @api.closeorder(params)
      order_detail(params)
    end

    # 退款
    #
    def refund(params = {})
      completion_request_parameter(params)
      @api.refund(params)
    end

    # 查询退款
    #
    def refund_query(params = {})
      params = completion_request_parameter(params)
      @api.refundquery(params)
    end

    # 获取签名
    def front_sign_attrs(base_order)
      payment = base_order.payment
      wxpay = Wxpay.find_by(transaction_no: payment.transaction_no)

      params = {
        appid:            wxpay.appid,
        kind:             wxpay.kind,
        openid:           wxpay.openid,
        prepay_id:        wxpay.prepay_id,
      }
      @api.sign_attrs(params)
    end

    private

    # SUCCESS—支付成功
    # REFUND—转入退款
    # NOTPAY—未支付
    # CLOSED—已关闭
    # REVOKED—已撤销（刷卡支付）
    # USERPAYING--用户支付中
    # PAYERROR--支付失败(其他原因，如银行返回失败)
    def search_order_exist?(payment_no)
      wxpay = Wxpay.find_by(transaction_no: payment_no)
      return if wxpay.nil?

      params = {
        source_no:        wxpay.source_no,
        kind:             wxpay.kind,
        openid:           wxpay.openid,
        appid:            wxpay.appid,
        no:               wxpay.source_no,
        out_trade_no:     wxpay.transaction_no
      }
      wxpay = order_detail(params)
      if wxpay.out_source_status != "NOTPAY"
        _msg = "订单发起支付失败，该订单状态#{@wxpay.out_source_status}"
        raise Exceptions::Wechat::MainServiceException, _msg
      end

      wxpay
    end

    # 补全参数
    #
    def completion_request_parameter(params = {})
      params = trans_request_params(params)
      wxpay = Wxpay.find_by(transaction_no: params[:transaction_no])
      if wxpay.nil?
        _msg = "订单号不存在, 请重试"
        raise Exceptions::Wechat::MainServiceException, _msg
      end

      params.merge!({ kind: wxpay.kind }) if params[:kind].nil?
      params.merge!({ openid: wxpay.openid }) if params[:openid].nil?
      params.merge!({ appid: wxpay.appid }) if params[:appid].nil?
      params.merge!({ out_trade_no: wxpay.transaction_no }) if params[:out_trade_no].nil?
      params
    end

    # 参数转化 并设定默认的APPID
    def trans_request_params(params = {})
      params.merge!({ transaction_no: params[:out_trade_no] }) if params[:transaction_no].nil?

      params
    end

    # 二次签名, 主要用于APP
    def app_pay_second_sign(params = {})
      params[:timestamp] = Time.now.to_i
      params[:kind] = "app"

      params = trans_request_params(params)
      @api.app_pay_second_sign(params)
    end

  end
end