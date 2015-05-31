module ShieldsUp
  class Server
		def initialize(config={})
			@base_dir = CONFIG['base_dir']
			@socket   = UNIXServer.new(CONFIG['socket_file'])
			@temp_dir = CONFIG['temp_dir']
		end

    def read
      @socket.read
    end

		def handle_client
			conn, client = Thread.current['conn'], Thread.current['client']
      client.authenticate

      if client.authenticated?
        client.handle_request
      else
        client.close
      end
		end

		def accept
			@socket.accept
		end

		def closed?
			@socket.closed?
		end
	end
end
