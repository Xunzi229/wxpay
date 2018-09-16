# 支付请求的统一接口
# kind参数币传 来 确定 请求支付类型
# @pay = Wxservice::ApiBaseService.new()
# @pay.unifiedorder({ kind: 'code' ...})
#
module Wechat
  class ApiService

    # 微信支付
    # 下单接口
    #
    def unifiedorder(options = {})
      source = get_source(options[:kind])
      request_params = conf(options)

      # 完整的URL
      _url = File.join(request_params[:host], "/pay/unifiedorder")
      # 请求
      request_xmls = source.unifiedorder(request_params)

      Wechat::HttpRequest.post(request_xmls, _url)
    end

    # 查询接口
    def orderquery(options = {})
      source = get_source(options[:kind])
      request_params = conf(options)

      # 完整的URL
      _url = File.join(request_params[:host], "/pay/orderquery")
      # 请求
      request_xmls = source.orderquery(request_params)

      Wechat::HttpRequest.post(request_xmls, _url)
    end

    # 关闭订单
    def closeorder(options = {})
      source = get_source(options[:kind])
      request_params = conf(options)

      _url = File.join(request_params[:host], "/pay/closeorder")
      request_xmls = source.closeorder(request_params)

      Wechat::HttpRequest.post(request_xmls, _url)
    end

    # 申请退款
    # 此时需要证书
    def refund(options = {})
      source = get_source(options[:kind])
      request_params = conf(options)

      _url = File.join(request_params[:host], "/secapi/pay/refund")
      request_xmls = source.refund(request_params)

      # 该接口需要传证书
      Wechat::HttpRequest.post(request_xmls, _url, request_params[:mch_id])
    end

    # 查询退款
    def refundquery
      source = get_source(options[:kind])
      request_params = conf(options)

      _url = File.join(request_params[:host], "/pay/refundquery")
      request_xmls = source.refundquery(request_params)

      Wechat::HttpRequest.post(request_xmls, _url)
    end

    # 验证接口
    #
    def valid?(options = {})
      source = get_source(options.delete(:kind))
      _config = Wxservice::Configable.new(options[:appid])
      options.merge!({ key: _config.key })

      source.valid?(options)
    end

    # 前端获取签名参数
    def sign_attrs(options = {})
      source = get_source(options[:kind])
      request_params = conf(options)

      source.sign_attrs(request_params)
    end

    # APP支付二次签名
    def app_pay_second_sign(params = {})
      source = get_source(params[:kind])
      request_params = conf(params)

      source.second_sign(request_params)
    end

    private
    # KIND:
    # small 小程序支付
    # code 扫码支付
    # h5   H5 支付
    # app  APP 支付
    #
    def get_source(kind)
      "Wxchat::WxParams::#{kind.camelize}Pay".constantize.new
    end

    # 获取完整的账号配置
    def conf(options = {}, appid = nil)
      appid ||= options[:appid]
      config = Wxchat::Config.new(appid)

      options.merge!({
        host:       config.host,
        key:        config.key,
        mch_id:     config.mch_id,
        notify_url: File.join(Rails.configuration.services['host'], config.notify_url),
        package:    config.package
      })
      options.delete_if {|_k, _v| _v.blank? }

      options
    end

  end
end