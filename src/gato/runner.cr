module Gato
  class Runner < Gato::MessageProcessor
    def self.start(routing_key : String)
      Log.notice { "El gato esta maullando..." }

      AMQP::Client.start(Gato.configuration.amqp_url.to_s) do |c|
        c.channel do |ch|
          q = ch.queue(routing_key)
          ch.prefetch(count: 1)

          puts "Waiting for tasks. To exit press CTRL+C"

          q.subscribe(no_ack: false, block: true) do |msg|
            message = JSON.parse(msg.body_io.to_s)
            Log.notice { "Received a new Message" }
            get_message message
            Log.notice { "Done" }
          end
        end
      end
    end
  end
end
