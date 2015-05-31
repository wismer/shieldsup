$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'socket'
require 'twitter'
require 'logger'
require 'yaml'
require 'pry'
require 'mysql'
require 'sequel'
require 'shieldsup/client'
require 'shieldsup/db_handler'
require 'shieldsup/server'

module ShieldsUp
  def self.start!
    File.delete CONFIG['socket_file'] if File.exist? CONFIG['socket_file']
    server = Server.new
    # maybe put in a condition to check if the DB connected properly
    until server.closed?
      # do the thing that the thing asked for
      client = Client.new(server.accept)
      Thread.start(client) do |c|
        Thread.current['conn'] = {}
        Thread.current['client'] = c
        server.handle_client
      end
    end
  end
end
