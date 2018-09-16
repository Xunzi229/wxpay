module Wechat
  class Config

    CONFIG = Rails.configuration.services

    # yml_example
    # wxpay:
    #   accounts:
    #     - appid: 'xxxxxxxxxxxx'
    #       mch_id: "xxxxxxxxx"
    #       key: 'xxxxx'
    #       notify_url: "xxxx"
    #
    HOST = CONFIG[:host].freeze

    def initialize(appid)
      accounts = CONFIG[:accounts]
      appids = accounts.map {|account| account[:appid] }

      dex = appids.index(appid)
      @account = accounts[dex]
    end

    def key
      @account['key']
    end

    def notify_url
      @account['notify_url']
    end

    def mch_id
      @account['mch_id']
    end

    def package
      @account['package']
    end

  end
end