module Gato
  class Runner
    def self.start(routing_key : String)
      Log.notice { "El gato esta maullando..." }

      array_to_hash = ->(array : Array(String)) : Hash(String, String) {
        hash = Hash(String, String).new

        (0...array.size).step(2) do |index|
          hash[array[index]] = array[index + 1] if array[index + 1]
        end

        hash
      }

      AMQP::Client.start(Gato.configuration.amqp_url.to_s) do |c|
        c.channel do |ch|
          q = ch.queue(routing_key)
          ch.prefetch(count: 1)

          puts "Waiting for tasks. To exit press CTRL+C"

          q.subscribe(no_ack: false, block: true) do |msg|
            message = JSON.parse(msg.body_io.to_s)
            Log.notice { "Received: #{message}" }

            Log.notice { "Done" }
          end
        end
      end
    end
  end
end
