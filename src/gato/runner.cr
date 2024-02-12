module Gato
  class Runner
    def self.start(param : Array(NamedTuple(queue_name: String, block: JSON::Any ->))) : Nil
      Log.notice { "El gato esta maullando..." }

      AMQP::Client.start(Gato.configuration.amqp_url.to_s) do |c|
        c.channel do |ch|
          q = ch.queue param[0][:queue_name]
          ch.prefetch count: 1

          q.subscribe(no_ack: false, block: true) do |msg|
            message = JSON.parse msg.body_io.to_s
            Log.notice { "Received a new Message" }
            param[0][:block].call message
            ch.basic_ack(msg.delivery_tag)
            Log.notice { "Done" }
          end
        end
      end
    end
  end
end
