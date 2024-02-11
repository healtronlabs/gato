module Gato
  class_getter configuration = Configuration.new

  def self.configure(&block) : Nil
    yield configuration
  end

  class Configuration
    property amqp_url : String?
    property validated = false

    def validate
      return if @validated
      @validated = true

      if amqp_url.nil?
        message = <<-error
          Gato cannot start because the amqp connection string hasn't been provided.
  
          For example, in your application config do:
  
          Gato.configure do |settings|
            settings.amqp_url = (ENV["AMQP_TLS_URL"]? || ENV["AMQP_URL"]? || "amqps://guest:guest@localhost")
          end
  
          error

        raise message
      end
    end
  end
end
