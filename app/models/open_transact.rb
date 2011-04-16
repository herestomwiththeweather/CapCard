require 'oauth/consumer'
module OpenTransact 
    
  def self.included(model)

    model.send(:include, InstanceMethods)
    model.send(:extend, ClassMethods)

  end
  
  module ClassMethods
    
    def service_name
      OPEN_TRANSACT_NAME
    end
    
    def consumer
      @consumer||=OAuth::Consumer.new OPEN_TRANSACT_CONSUMER_KEY, OPEN_TRANSACT_CONSUMER_SECRET, :site=>OPEN_TRANSACT_URL
    end

    def get_request_token(callback_url,scope)
      consumer.get_request_token({:oauth_callback=>callback_url},:scope => scope)
    end
    
    protected
    
    def credentials
      @credentials||=OAUTH_CREDENTIALS[service_name]
    end
    
  end
  
  module InstanceMethods
    
    # Main client for interfacing with remote service. Override this to use
    # preexisting library eg. Twitter gem.
    def client
      @client||=OAuth::AccessToken.new self.class.consumer,token,secret
    end
    
    def exchange_request_token!(token,secret,oauth_verifier)
      logger.info "create_from_request_token"
      request_token=OAuth::RequestToken.new self.class.consumer,token,secret
      access_token=request_token.get_access_token :oauth_verifier=>oauth_verifier
      logger.info self.inspect
      self.token=access_token.token
      self.secret=access_token.secret
      save
      access_token
    end

    def asset=(a)
      @asset = a
    end

    def asset
      @asset || OPEN_TRANSACT_ASSET
    end

    def transacts_path
      @transacts_path ||= (asset.empty? ? "/transacts" : "/transacts/#{asset}")
    end
    
    def transactions
      @transactions||=JSON.parse(client.get(transacts_path + ".json").body)
    end
    
    def withdraw(amount)
      JSON.parse(client.post(transacts_path,{:amount=>amount,:memo=>"Withdrawal",:to=>OPERATOR_ACCOUNT},{'Accept'=>'application/json'}).body)
    end
    
  end
  
end
