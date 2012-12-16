# Enqueue

__enqueue__ _verb_ _\en′kyü\_ __:__ To add an item to a queue.

Enqueue is an interface to [message queues][message_queue] for easy parallel processing and 
multi-threading.

## Install

### Bundler: `gem 'enqueue'`

### RubyGems: `gem install enqueue`

## Usage

### Publisher

***

A publisher is any object that can find and push messages to a queue.

#### Defining

You can define a publisher by subclassing `Enqueue::Publisher` or by including/extending 
`Enqueue::Publisher::Base`.

#### Global Methods

Besides the methods that are mixed into publisher by an adapter, all publishers 
will have the following methods:

##### Class Methods

```ruby
adapter(name)

Remove any previous adapter specific methods and include the module associated with the given Symbol.

returns: true, false
```

###### Arguments

*name* \<Symbol, #to_sym> The name of the adapter to mixin.

##### Instance Methods

```ruby
enqueue(message, options={})

Push a message to a queue.

aliases: push, shift, <<
returns: Enqueue::Message
```

###### Arguments

*message* \<Object> The message to push. Note that some adapters require this to be a String.  
*options* \<Hash, #to_hash, #to_h> The adapter-specific options.

###### Options

`:to` \<Symbol, #to_sym, String, #to_s> The name of the queue to push the message to. 
Enqueue will attempt to create a new queue, if one cannot be found. Default is `:default`.

### Subscriber

***

A subscriber is any object that can find and pop messages off a queue.

#### Defining

Just like a publisher, you can define a subscriber by subclassing `Enqueue::Subscriber` or by 
including/extending `Enqueue::Subscriber::Base`.

#### Global Methods

Besides the methods that are mixed into publisher by an adapter, all publishers 
will have the following methods:

##### Class Methods

```ruby
adapter(name)

Remove any previous adapter specific methods and include the module associated with the given Symbol.

returns: true, false
```

###### Arguments

*name* \<Symbol, #to_sym> The name of the adapter to mixin.

##### Instance Methods

```ruby
pop(options={})

Pop a message off a queue.

aliases: dequeue, unshift
returns: Enqueue::Message
```

###### Arguments

**options** \<Hash, #to_hash, #to_h> The adapter-specific options.

### Example

#### Ruby Queue

By default, Enqueue uses the [Queue][queue] class from the Ruby standard library.

> Note: This example implements the [`service`][service] gem to push and pop messages to a queue within a run-loop that is running in it's own Thread.

`my_pub_sub`

```ruby
#!/usr/bin/env ruby

require 'enqueue'
require 'service'

publisher_threads, subscriber_threads = [], []

trap('INT') do
  print 'Killing all publishers... '
  publisher_threads.each(&:kill)
  puts 'Done!'
  
  print 'Killing all subscribers... '
  subscriber_threads.each(&:kill)
  puts 'Done!'
end
puts "Press CTRL-C to exit."

class Publisher < Enqueue::Publisher
  include Service::Base
  
  def execute
    sleep rand(10)
    push 'Hello, World!'
  end
end

class Subscriber < Enqueue::Subscriber
  include Service::Base
  
  def execute
    sleep rand(10)
    puts pop
  end
end

publisher_threads = (0...5).collect { Publisher.new }.collect(&:run!)
subscriber_threads = (0...5).collect { Subscriber.new }.collect(&:run!)

[publisher_threads, subscriber_threads].flatten.each(&:join)
```

#### RabbitMQ

`my_pub_sub`

```ruby
#!/usr/bin/env ruby

class Publisher < Enqueue::Publisher
  adapter :rabbit_mq
  # This class now has RabbitMQ specific class and
  # instance methods:
  host 'localhost'
  port 5672
  
  def notify(message)
    enqueue message, to: 'my_message_queue'
  end
end

class Subscriber < Enqueue::Subscriber
  adapter :rabbit_mq
  # This class now has RabbitMQ specific class and
  # instance methods:
  host 'localhost'
  port 5672
  
  subscribe :print_message, to: 'my_message_queue'
  
  def print_message(message)
    puts message
  end
end

subscribers, publishers, threads = [], [], []

trap('INT') do
  print 'Disconnecting all publishers... '
  publishers.each(&:disconnect)
  puts 'Done!'
  
  print 'Disconnecting all subscribers... '
  subscribers.each(&:disconnect)
  puts 'Done!'
end
puts "Press CTRL-C to exit."

5.times do
  publisher = Publisher.new
  publishers << publisher
  publisher.connect
  threads << Thread.new do
    loop do
      sleep rand(10)
      publisher.notify 'Hello, World!'
    end
  end
end

5.times do
  subscriber = Subscriber.new
  subscribers << subscriber
  subscriber.connect
  threads << subscriber.run!
end
```

## Copyright

Copyright © 2012 Ryan Scott Lewis <ryan@rynet.us>.

The MIT License (MIT) - See LICENSE for further details.

[message_queue]: http://en.wikipedia.org/wiki/Message_queue
[queue]: http://rubydoc.info/stdlib/thread/Queue
[service]: https://github.com/RyanScottLewis/service