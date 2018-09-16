module Wechat
  module HttpRequest

    class << self
      def get(params = {})
      end

      def post(_payload_string, url, mch_id = nil)
        Rails.logger.info "微信支付请求接口: \n #{url} #{_payload_string}"

        params = {
          method:   :post,
          url:      url,
          payload:  _payload_string,
          headers: { content_type: 'application/xml' }
        }

        params.merge!(get_ssl_options(mch_id)) if mch_id.present?
        begin
          response = RestClient::Request.execute(params)
        rescue
          _msg = "微信支付接口请求错误: #{$!}"
          raise Exceptions::Wechat::ApiServiceException, _msg.gsub(/\s/, "")
        end

        result = response.body.force_encoding(Encoding::UTF_8)
        Rails.logger.info "微信支付请求返回参数: #{result}"

        result = Hash.from_xml(result)

        format_api_response(result)
        format_service_respose(result)
      end

      def format_api_response(result)
        if result["xml"]["return_code"] != "SUCCESS"
          _msg = <<-EOF
            return_msg: #{result['xml']['return_msg']}
          EOF
          raise Exceptions::Wechat::ApiServiceException, _msg.gsub(/\s/, "")
        end
      end

      def format_service_respose(result)
        if result['xml']['result_code'] != "SUCCESS"
          _msg = <<-EOF
            err_code_des: #{result['xml']['err_code_des']}
          EOF
          raise Exceptions::Wechat::ApiServiceException, _msg.gsub(/\s/, "")
        end

        ActiveSupport::HashWithIndifferentAccess.new(result['xml'])
      end

      # 获取证书所在文件目录
      def get_ssl_options(mch_id)
        _root = File.join(Rails.root, "config", "wechat_certs", "cert_#{mch_id}")
        _cert = File.join(_root, "apiclient_cert.pem")
        _key  = File.join(_root, "apiclient_key.pem")
        _file = File.join(_root, "rootca.pem")

        options = {
          ssl_client_cert: OpenSSL::X509::Certificate.new(File.read(_cert)),
          ssl_client_key:  OpenSSL::PKey::RSA.new(File.read(_key)),
          ssl_ca_file:     _file,
          verify_ssl:      OpenSSL::SSL::VERIFY_NONE
        }
      end
    end

  end
end