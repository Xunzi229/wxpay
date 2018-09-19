module Exceptions
  module Wechat
    class MainServiceException < RuntimeError; end
    class ApiServiceException < RuntimeError; end
    class ApiParamsIncompleteException < RuntimeError; end
  end
end