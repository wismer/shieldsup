module ShieldsUp
  CONFIG = YAML.load_file File.join('./conf.yaml.sample')
  DB = Sequel.mysql(
    CONFIG['db']['database'],
    host: CONFIG['db']['host'],
    user: CONFIG['db']['username'],
    password: CONFIG['db']['password']
  )
  
  class Client
    attr_reader :socket, :twitter_user_id

    def initialize(socket)
      @socket = socket
    end

    def create_job(key)
      keys = { userid: @twitter_user_id.id, added: Time.now, status: "RUNNING" }
      Job.insert keys.merge(key)
      @current_request = key.first[1]
    end

    def handle_request
      until @socket.eof?
        command = @socket.gets.chop
        case command
        when /^User (.*)$/
          create_job(target_username: $1)
        when /^rt (.*)$/
          # probably needs a different regex?
        when "go"
          get_user_timeline(username: @current_request)
        end
      end
    end

    def close
      @socket.close
    end

    def authenticate(keys=[])
      4.times { keys << @socket.gets.chop }

      @twitter_client = Twitter::REST::Client.new do |config|
        config.consumer_key = keys[0]
        config.consumer_secret = keys[1]
        config.access_token = keys[2]
        config.access_token_secret = keys[3]
      end

      begin
        @twitter_user_id = @twitter_client.verify_credentials
      rescue Twitter::Error::Unauthorized => error
        # insert logger statement
        @twitter_user_id = false
      end
    end

    def authenticated?
      @twitter_user_id
    end
  end
end
