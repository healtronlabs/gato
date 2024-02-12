module Gato
  class Runner
    def self.start(param : Array(NamedTuple(queue_name: String, message_handler: JSON::Any ->))) : Nil
      Log.notice { "El gato esta maullando..." }
      AMQP::Client.start(Gato.configuration.amqp_url.to_s) do |c|
        c.channel do |ch|
          param.each do |curr_param|
            q = ch.queue curr_param[:queue_name]
            ch.prefetch count: 1
  
            q.subscribe(no_ack: false, block: true) do |msg|
              message = JSON.parse msg.body_io.to_s
              Log.notice { "Received a new message for #{curr_param[:queue_name]} queue" }
              curr_param[:message_handler].call message
              msg.ack
              Log.notice { "Done processing the new message!" }
            end
          end
        end
      end
    end
  end
end
