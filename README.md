# gato

Gato is a lightweight wrapper tailored for effortless integration of LavinMQ, a robust messaging system, within the Lucky framework. Designed to streamline the utilization of AMQP (Advanced Message Queuing Protocol) in Lucky applications, Gato simplifies the process of publishing and subscribing to queues, all while focusing on the unique features and capabilities of LavinMQ.

### Key Features:

- Seamless integration of LavinMQ functionality into Lucky applications.
- Abstracts away complexities in configuration, minimizing setup overhead.
- Enables smooth publishing and subscribing to queues, optimizing message exchange processes.

With Gato, harness the power of LavinMQ in your Lucky applications with ease, enhancing communication and workflow efficiency.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   # shard.yml

   dependencies:
     gato:
       github: healtronlabs/gato
   ```

2. Run `shards install`

3. Open to this file `src/shards.cr` and add this line of code:
```crystal
# src/shards.cr

require "gato"
```

4. Go inside config folder, and create a new file `gato.cr`

5. Add this config to the file you created on the previous step:

```crystal
# config/gato.cr

Gato.configure do |settings|
  settings.amqp_url = ENV["LAVINMQ_URL"] # this code requires you to have an env variable under the name of LAVINMQ_URL which is the url to connect to lavinmq server
end
```

## Usage

### Publishing messages directly to the queue
Use `publish` method from `Gato::Publisher` class

```crystal
Gato::Publisher.publish stringified_object, queue_name
```

### Subscribing to messages
You will have to run it as a worker

```crystal
# worker.cr

require "./app"
require "./lavin_handlers/**"

Habitat.raise_if_missing_settings!

if LuckyEnv.development?
  Avram::Migrator::Runner.new.ensure_migrated!
  Avram::SchemaEnforcer.ensure_correct_column_mappings!
end

# Disable query cache because all jobs run in the
# same fiber which means infinite cache
Avram.settings.query_cache_enabled = false

lavin_handlers = [
  {
    queue_name:      "new_lefa",
    message_handler: ->(msg : JSON::Any) { CreateLefa.handle_create_lefa(msg) },
  },
  {
    queue_name:      "update_lefa",
    message_handler: ->(msg : JSON::Any) { UpdateLefa.handle_update_lefa(msg) },
  },
]

Gato::Subscriber.subscribe lavin_handlers
```

The following are details for params passed to the `subscribe` method:

The subscribe method expect an array of named tuples, whereby each tuple gets a name of the queue and a method that will handle any message that will be published to that queue, the `handler_method` needs to be passed as an anonymous function that expects to receive a `msg` param that represents a published message to the queue that is defined in the same tuple. That message object is expected to be of type `JSON::Any`.

## Contributing

:warning: This package needs more contributors whereby we still haven't covered all of the LavinMQ capabilities, such as streamings, exchanges, ... :warning:

1. Fork it (<https://github.com/healtronlabs/gato/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [descholar-ceo](https://github.com/descholar-ceo) - creator and maintainer
