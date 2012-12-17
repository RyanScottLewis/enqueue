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
arguments:
  name (Symbol, to_sym) The name of the adapter to mixin.
```

##### Instance Methods

```ruby
enqueue(message, options={})

Push a message to a queue.

aliases: push, send, unshift, <<
returns: Object - The 'message' that was enqueued.
```

###### Arguments

*message* \<Object> The message to push. Note that some adapters require this to be a String.  
*options* \<Hash, #to_hash, #to_h> The adapter-specific options.

###### Options

`:to` \<Symbol, #to_sym, String, #to_s> The name of the queue to push the message to. 
Enqueue will attempt to create a new queue, if one cannot be found (lazily-created). 
Note that the queue name is global, meaning that the same Symbol will correspond to the same queue 
no matter which instance is pushing to it. 
Default is `:global`.

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
dequeue(options={})

Pop a message off a queue.

aliases: pop, receive, shift
returns: Object, nil
```

###### Arguments

**options** \<Hash, #to_hash, #to_h> The adapter-specific options.

###### Options

`:from` \<Symbol, #to_sym, String, #to_s> The name of the queue to pop the message from. 
Enqueue will attempt to create a new queue, if one cannot be found (lazily-created). 
Note that the queue name is global, meaning that the same Symbol will correspond to the same queue 
no matter which instance is pushing to it. 
Default is `:global`.

### Example

#### Ruby Queue

By default, Enqueue uses the [Queue][queue] class from the Ruby standard library.

> Enqueue utilizes the [`service`][service] gem to push and pop messages to a queue within a run-loop that is running in it's own Thread.
> 
> Service gives simply allows you to run your code that is within the execute method in four different ways: 
> once (execute), once in a new Thread (execute!), in a loop (start/run), or in a loop within a new Thread (start!/run!)

```ruby
require 'enqueue'

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
  def execute
    sleep rand(10)
    enqueue 'Hello, World!'
  end
end

class Subscriber < Enqueue::Subscriber
  def execute
    message = dequeue
    puts message unless message.nil?
  end
end

publisher_threads = (0...5).collect { Publisher.new }.collect(&:run!)
subscriber_threads = (0...5).collect { Subscriber.new }.collect(&:run!)

[publisher_threads, subscriber_threads].flatten.each(&:join)
```

#### Multiple Queues

```ruby
require 'enqueue'

class HelloWorldPublisher < Enqueue::Publisher
  def execute
    sleep rand(10)
    push
  end
end

class HelloPublisher < HelloWorldPublisher
  def push
    enqueue 'Hello, ', to: :hello_queue
  end
end

class WorldPublisher < HelloWorldPublisher
  def push
    enqueue 'World!', to: :world_queue
  end
end

class HelloWorldSubscriber < Enqueue::Subscriber
  # Publishers and Subscribers do not define #initialize so you do not need to remember to call `super` =)
  def initialize
    setup_instance_variables
    setup_signals
    setup_publishers
    
    run
  end
  
  def execute
    message = dequeue from: @buffer.empty? ? :hello_queue : :world_queue
    @buffer << message unless message.nil?
    
    if @buffer.length == 2
      puts @buffer.join
      @buffer.clear
    end
  end
  
  protected
  
  def setup_instance_variables
    @publisher_threads, @buffer = [], []
  end
  
  def setup_signals
    trap('INT') do
      print 'Killing all publishers... '
      @publisher_threads.each(&:kill)
      puts 'Done!'
      
      print 'Stopping subscriber... '
      stop
      puts 'Done!'
    end
    puts "Press CTRL-C to exit."
  end
  
  def setup_publishers
    @publisher_threads += (0...3).collect { HelloPublisher.new }.collect(&:run!)
    @publisher_threads += (0...3).collect { WorldPublisher.new }.collect(&:run!)
  end
end

HelloWorldSubscriber.new
# => Hello, World!
# => Hello, World!
# => ...
```

#### Subscriber Helpers

##### `subscribe` Class Method

You can "subscribe" an instance method to a queue by using the `subscribe` class method.

For example, the following:

```ruby
class Subscriber < Enqueue::Subscriber
  def execute
    message = dequeue
    puts message unless message.nil?
  end
end
```

Can be written as:

```ruby
class Subscriber < Enqueue::Subscriber
  subscribe :print_message
  
  def print_message(message)
    puts message
  end
end
````

Which is the same as:

```ruby
class Subscriber < Enqueue::Subscriber
  subscribe :print_message
  
  def print_message(message)
    puts message
  end
  
  def execute
    run_subscriptions
  end
end
````

##### `run_subscriptions` Instance Method

The `run_subscriptions` instance method will call `run_subscription` with all of the subscriptions defined 
on the instance's class in the order they were defined.

##### `run_subscription` Instance Method

The `run_subscription` instance method will call `dequeue` with the options given to the `subscribe` method 
and call the instance method subscribed to the queue, if the message is not nil.

If the `:condition` option was passed to the `subscribe` method, then the instance method subscribed will be 
called if the proc given to the `:condition` option returns true.

For example, the following:

```ruby
class Subscriber < Enqueue::Subscriber
  def execute
    message = dequeue
    puts message unless message.nil?
  end
end
```

Can be written as:

```ruby
class Subscriber < Enqueue::Subscriber
  subscribe :print_message
  
  def print_message(message)
    puts message
  end
  
  def execute
    run_subscription :print_message
  end
end
````

#### Adapters

##### RabbitMQ

```ruby
class Publisher < Enqueue::Publisher
  adapter :rabbit_mq
  # This class now has RabbitMQ specific class and
  # instance methods:
  host 'localhost'
  port 5672
  
  def notify(message)
    enqueue message, to: 'my_scope.my_message_queue'
  end
end

class Subscriber < Enqueue::Subscriber
  adapter :rabbit_mq
  # This class now has RabbitMQ specific class and instance methods:
  host 'localhost'
  port 5672
  
  subscribe :print_message, to: 'my_scope.my_message_queue'
  
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