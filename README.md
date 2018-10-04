# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version
  2.5.1

* System dependencies

* Configuration
  1. 支持多账号
  账号设定
  ```yml
    wxpay:
      accounts:
        - appid: xxxxxx
          mch_id: xxxxxx
          key: xxxxxx
          notify_url: xxxxx
          package: Sign=WXPay
  ```

  2. 创建支付订单
  > 其中有以下的支付方式
  ```ruby
    # 扫码 支付参数
    def wxpay_code_params(**params)
      {
        no:               params[:no],
        body:             params[:body],
        kind:             "code",
        appid:            params[:appid],
        total_fee:        params[:total_fee],
        out_trade_no:     params[:transaction_no],
        spbill_create_ip: params[:remote_ip]
      }
    end

    # H5 支付参数
    def wxpay_h5_params(**params)
      {
        no:               params[:no],
        body:             params[:body],
        kind:             'h5',
        appid:            params[:appid],
        total_fee:        params[:total_fee],
        out_trade_no:     params[:transaction_no],
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
        kind:             'app',
        appid:            params[:appid],
      }
    end

    # 小程序 支付参数
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

    ## 公众号 支付参数
    def wxpay_pub_params(**params)
      {
        no:               params[:no],
        body:             params[:body],
        spbill_create_ip: params[:remote_ip],
        out_trade_no:     params[:transaction_no],
        total_fee:        params[:total_fee],
        appid:            params[:appid],
        openid:           params[:openid],
        kind:             'pub'
      }
    end

    # 下单
    Wechat::MainService.new.create("wxpay_#{_kind.downcase}_params")

  ```
    3. 退款
    ```ruby

      def wechat_pay_refund(params = {})
        wxpay = Wxpay.find_by(out_transaction_no: "xxxx")

        params = {
          out_refund_no:  params[:out_refund_no],         # 退款单号，一个单号 只能退一次
          total_fee:      params[:total_fee],             # 总支付金额
          refund_fee:     params[:refund_fee],            # 退款金额
          out_trade_no:   wxpay.try(:out_transaction_no), # 支付单号
        }
        result = Wechat::MainService.new
        response = result.refund(params)
      end
    ```

    4. 回调
    > 1. 首先微信的回调都是xml，如果是 用grape的话 需要指定 content_type ,format
    > 最重要的是指定 status 为 200 ，默认post是201  ，导致 微信那边一直不通，就会一直 给我们回调

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
