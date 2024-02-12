module Gato
  class_getter message_processor = MessageProcessor.new

  class Runner
    def self.start(queue_name : String, &block : JSON::Any ->) : Nil
      Log.notice { "El gato esta maullando..." }

      AMQP::Client.start(Gato.configuration.amqp_url.to_s) do |c|
        c.channel do |ch|
          q = ch.queue queue_name
          ch.prefetch count: 100

          puts "Waiting for tasks. To exit press CTRL+C"

          q.subscribe(no_ack: false, block: true) do |msg|
            message = JSON.parse msg.body_io.to_s
            Log.notice { "Received a new Message" }
            
            block.call message
            
            Log.notice { "Done" }
          end
        end
      end
    end
  end
end
