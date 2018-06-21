<a href="https://github.com/philou/rspecproxies"><img style="position: absolute; top: 0; right: 0; border: 0;" src="https://s3.amazonaws.com/github/ribbons/forkme_right_red_aa0000.png" alt="Fork me on GitHub"></a>

[![Build Status](https://travis-ci.org/philou/rspecproxies.svg?branch=master)](https://travis-ci.org/philou/rspecproxies) [![Test Coverage](https://codeclimate.com/github/philou/rspecproxies/badges/coverage.svg)](https://codeclimate.com/github/philou/rspecproxies) [![Code Climate](https://codeclimate.com/github/philou/rspecproxies/badges/gpa.svg)](https://codeclimate.com/github/philou/rspecproxies)

# RSpecProxies

Simplify [RSpec](http://rspec.info) mocking with test proxies !

## Why ?

As you might know after the [Is TDD Dead ?](http://martinfowler.com/articles/is-tdd-dead/) debate, [Mockists are dead, long live to classicists](https://www.thoughtworks.com/insights/blog/mockists-are-dead-long-live-classicists). Heavy mocking is getting out of fashion because it makes tests unreliable and difficult to maintain.

Test proxies mix the best of both worlds, they behave like the real objects but also provide hooks to perform assertions or to inject test code. RSpec now features minimal supports for proxies with partial mocks, spies and the ```and_call_original``` and ```and_wrap_original``` expectations. RSpecProxies goes one step further with more specific expectations. Using RSpecProxies should help you to use as little mocking as possible.

More specifically, RSpecProxies helps to :

* Simplify the setup of mocks by relying on the real objects
* Write reliable tests that use the real code
* Capture return values and arguments to the real calls
* Setup nested proxies when needed

RSpecProxies will not make your tests as fast as heavy mocking, but for that you can :

* Use in-memory databases to run your tests (such as [SQLite](http://www.sqlite.org))
* Split your system in sub-systems
* Write in-memory fakes of your sub-systems to use in your tests

## Installation

Add this line to your application's Gemfile:

    gem 'rspecproxies'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rspecproxies

## Usage

RSpecProxies is used on top of RSpec's ```and_return_original``` and ```and_wrap_original``` expectations. The syntax is meant to be very similar. Just as inspiration, here are a few sample usages.

### Verify caching

NB: this is an illustration of the built-in spy features that RSpec now provides

By definition, caching should not change the behaviour of your system. But some methods should not be called many times. This used to be a good place to use mocks. RSpec spies now helps to deal with that in an unintrusive way :

```ruby
it 'caches users' do
  allow(User).to receive(:load).and_return_original

  controller.login('joe', 'secret')
  controller.login('joe', 'secret')

  expect(users).to have_received(:load).once
end
```

### Verify loaded data

Sometimes, the verifications you want to make in your test depends on the data that has been loaded. The best way to handle that is to know what data is going to be loaded, but that is not always easy or possible. An alternative is heavy mocking with will take you down the setup hell road, is often not a good choice at all. Using proxies, it is possible to win on both aspects.

```ruby
it 'can check that the correct data is used (using and_after_calling_original)' do
  user = nil
  allow(User).to receive(:load).and_after_calling_original { |result| user = result }

  controller.login('joe', 'secret')

  expect(response).to include(user.created_at.to_s)
end

it 'can check that the correct data is used (using and_capture_result_into)' do
  allow(User).to receive(:load).and_capture_result_into(self, :user)

  controller.login('joe', 'secret')

  expect(response).to include(@user.created_at.to_s)
end

it 'can check that the correct data is used (using and_collect_results_into)' do
  users = []
  allow(User).to receive(:load).and_collect_results_into(users)

  controller.login('joe', 'secret')

  expect(response).to include(users.first.created_at.to_s)
end
```

### Simulate unreliable network

In this case, you might want to fail a call from time to time, and call the original otherwise. This should not require complex mock setup.

```ruby
it 'retries on error' do
   i = 0
   allow(Resource).to receive(:get).and_before_calling_original { |*args|
      i++
      raise RuntimeError.new if i % 3==0
   }

   resources = Resource.get_at_least(10)

   expect(resources).to have_exactly(10).items
end
```

### Shortcut a long deep call

Sometimes, you want to mock a particular method of some particular object. RSpec provides ```receive_message_chain``` just for that, but it creates a full mock object which will fail if sent another message. You'd ratherwant this object to otherwise behave normally, that's what you get with nested proxies.

```ruby
it 'rounds the completion ratio' do
   Allow(RenderingTask).to proxy_message_chain("load.completion_ratio") {|s| s.and_return(0.2523) }

   controller.show

   expect(response).to include('25%')
end
```

### CAUTION : {...} vs do...end

In ruby, the convention is to use {...} blocks for one liners, and do...end otherwise. Unfortunately, the two don't have the same precedence, which means that they don't exactly work the same way. RSpecProxies in particular does not support do...end out of the box. That's why all the examples above use {...}, even for multi lines blocks.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

### A word on docker and docker-compose

If you want to contribute to RSpecProxies, you can make use of the docker-compose configuration to quickly setup an isolated ruby environment. Make sure you have [docker](https://docs.docker.com/engine/installation/) and [docker-compose](https://docs.docker.com/compose/install/) installed, then type :

```bash
docker-compose run rubybox
bundle install
```

and you should be in a brand new container, ready to hack.

## Authors

* [Philippe Bourgau](http://philippe.bourgau.net)
