# frozen_string_literal: true
module V1
  class Callbacks < V1::Base
    resources :callbacks do

      namespace :xml do
        format :xml
        content_type :xml, 'text/xml'

        desc '微信支付回调', skip_auth: true
        post :wxpay_notify do
          status 200

          request_body = request.body.read.force_encoding(Encoding::UTF_8).dup

          Rails.logger.info <<-XML
            ======== 微信支付回调 ============
                #{request_body}
            ================================
          XML

          callback = Wechat::CallbackService.new
          callback.notify(request_body)

          response = <<-XML
            <xml>
              <return_code>
                <![CDATA[SUCCESS]]>
              </return_code>
              <return_msg>
                <![CDATA[OK]]>
              </return_msg>
            </xml>
          XML

          response.gsub(/\s/, "")
        end
      end
    end
  end
end
