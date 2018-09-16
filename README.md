# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version
  2.5.1

* System dependencies

* Configuration

  > 其中有以下的支付方式
  ```ruby
    # 扫码支付参数
    def wxpay_code_params(**params)
      extended_field = self.base_order.extended_field

      {
        no: params[:no],
        body: params[:body],
        kind: "code",
        total_fee: params[:total_fee],
        out_trade_no: params[:transaction_no],
        spbill_create_ip: params[:remote_ip]
      }
    end

    # H5 支付参数
    def wxpay_h5_params(**params)
      {
        no: params[:no],
        body: params[:body],
        kind: 'h5',
        total_fee: params[:total_fee],
        out_trade_no: params[:transaction_no],
        spbill_create_ip: params['remote_ip'],
        scene_info: {
          h5_info: {
            type: "Wap",
            wap_url: params[:host],
            wap_name: "订单付款"
          }
        }
      }
    end

    # APP 支付参数
    def wxpay_app_params(**params)
      {
        no:                params[:no],
        body:              params[:body],
        out_trade_no:      params[:transaction_no],
        total_fee:         params[:total_fee],
        spbill_create_ip:  params[:remote_ip],
        kind:             'app'
      }
    end

    # 小程序支付需要的参数
    #
    def wxpay_small_params(**params)
      {
        no:               params[:no],
        body:             params[:body],
        spbill_create_ip: params[:remote_ip],
        out_trade_no:     params[:transaction_no],
        total_fee:        params[:total_fee],
        appid:            params[:appid],
        openid:           params[:openid],
        kind:             'applets',
      }
    end

    # 下单
    Wechat::MainService.new.create("wxpay_#{_kind.downcase}_params")

  ```
* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
