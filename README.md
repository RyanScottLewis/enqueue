# Enqueue

__enqueue__ _verb_ _\en′kyü\_ __:__ To add an item to a queue.

Enqueue is an interface to [message queues][message_queue] for easy parallel processing and 
multi-threading.

## Install

### Bundler: `gem 'enqueue'`

### RubyGems: `gem install enqueue`

## Usage

### Publisher

A publisher is any object that can find and push messages to a queue.

#### Defining

You can define a publisher by subclassing `Enqueue::Publisher` or by including/extending 
`Enqueue::Publisher::Base`.

#### Global Methods

Besides the methods that are mixed into publisher by an adapter, all publishers 
will have the following methods:

#### Class

`adapter(name)`  
*returns: true, false*

**name** <Symbol, #to_sym> The name of the adapter to mixin.

Remove any previous adapter specific methods and include the module associated with the given Symbol.

> Note: Adapters *will* overwrite any instance/class method that it uses.  
> Not all adapters have the same set of methods so you may have to investigate which methods 
> not to use when integrating the ability to publish to a queue onto an existing object.

#### Instance

`enqueue(message, options={})`  
*aliases: push, shift, <<*  
*returns: Enqueue::Message*

**message** \<Object> The message to push. Note that some adapters require this to be a String.  
**options** \<Hash, #to_hash, #to_h> The adapter-specific options.

Push a message to the/a queue.

### Subscriber

A subscriber is any object that can find and pop messages off a queue.

#### Defining

Just like a publisher, you can define a subscriber by subclassing `Enqueue::Subscriber` or by 
including/extending `Enqueue::Subscriber::Base`.

#### Global Methods

Besides the methods that are mixed into publisher by an adapter, all publishers 
will have the following methods:

#### Class

`adapter(name)`  
*returns: true, false*

**name** <Symbol, #to_sym> The name of the adapter to mixin.

Remove any previous adapter specific methods and include the module associated with the given Symbol.

#### Instance

`pop(options={})`  
*aliases: dequeue, unshift*  
*returns: Enqueue::Message*

**options** <Hash, #to_hash, #to_h> The adapter-specific options.

Push a message to the/a queue.

`run`  

In a loop, wait until the queue has a message. When it does, pop it off.

> Note: All adapters overwrite this method.

`run!`  
*returns: Thread*

Call `run` in a new thread.

### Example

#### Ruby Queue

By default, Enqueue uses the [Queue][queue] class from the Ruby standard library.

`my_pub_sub`

```ruby
#!/usr/bin/env ruby

subscribers, publishers, threads = [], [], []

trap('INT') do
  print 'Killing all publishers... '
  publishers.each(&:disconnect)
  puts 'Done!'
  
  print 'Killing all subscribers... '
  subscribers.each(&:disconnect)
  puts 'Done!'
end
puts "Press CTRL-C to exit."

5.times do
  publisher = Enqueue::Publisher.new
  publishers << publisher
  threads << Thread.new do
    loop do
      sleep rand(10)
      publisher.push 'Hello, World!'
    end
  end
end

5.times do
  subscriber = Enqueue::Subscriber.new
  subscribers << subscriber
  threads << subscriber.run!
end
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