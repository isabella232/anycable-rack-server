# frozen_string_literal: true

require "json"

module AnyCable
  module Rack
    # Sends pings to sockets
    class Pinger
      INTERVAL = 3

      def initialize
        @_sockets = []
        @_stopped = false
      end

      def add(socket)
        @_sockets << socket
      end

      def remove(socket)
        @_sockets.delete(socket)
      end

      def stop
        @_stopped = true
      end

      def run
        Thread.new do
          loop do
            break if @_stopped

            unless @_sockets.empty?
              msg = ping_message(Time.now.to_i)
              @_sockets.each do |socket|
                socket.transmit(msg)
              end
            end

            sleep(INTERVAL)
          end
        end
      end

      private

      def ping_message(time)
        {type: :ping, message: time}.to_json
      end
    end
  end
end
