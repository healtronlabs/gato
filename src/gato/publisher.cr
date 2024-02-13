module Gato
  class Publisher
    def self.publish(data : String, queue_name : String)
      AMQP::Client.start(Gato.configuration.amqp_url.to_s) do |c|
        c.channel do |ch|
          unless LuckyEnv.production?
            Log.notice { "Publishing to #{queue_name}..." }
          end
          q = ch.queue queue_name
          q.publish_confirm data
          unless LuckyEnv.production?
            Log.notice { "Successfully published to lavinmq!" }
          end
        end
      end
    end
  end
end
