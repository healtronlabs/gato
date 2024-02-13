module Gato
  class Subscriber
    def self.subscribe(param : Array(NamedTuple(queue_name: String, message_handler: JSON::Any ->))) : Nil
      unless LuckyEnv.production?
        Log.notice { "El gato esta maullando..." }
      end
      AMQP::Client.start(Gato.configuration.amqp_url.to_s) do |c|
        c.channel do |ch|
          param.each do |curr_param|
            q = ch.queue curr_param[:queue_name], durable: true
            ch.prefetch count: 1

            q.subscribe(no_ack: false, block: false) do |msg|
              message = JSON.parse msg.body_io.to_s
              unless LuckyEnv.production?
                Log.notice { "Received a new message for #{curr_param[:queue_name]} queue" }
              end
              curr_param[:message_handler].call message
              msg.ack
              unless LuckyEnv.production?
                Log.notice { "Done processing the new message!" }
              end
            end
          end
          sleep
        end
      end
    end
  end
end
