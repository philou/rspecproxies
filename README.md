# RSpecProxies

Special RSpec extensions to simplify mocking by providing proxies.

Here are the goals of mock proxies :

* simplify mock setup
* minimize method calls verifications
* capture return values and calls

## Installation

Add this line to your application's Gemfile:

    gem 'rspecproxies'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rspecproxies

## Usage

Just as inspiration, here are a few sample usages :

### Verify caching with capture_results_from

```ruby
it 'caches users' do
  users = User.capture_results_from(:load)

  controller.login('joe', 'secret')
  controller.login('joe', 'secret')

  expect(users).to have_exactly(2).items
end
```

### Verify loaded data with capture_result_from

```ruby
it 'loads the actual user' do
  capture_result_from(User, :load, into: :user)

  controller.login('joe', 'secret')

  expect(response).to redirect_to(@user.homepage)
end
```

### Simulate unreliable network with on_call_to

```ruby
it 'retries on error' do
   i = 0
   Resource.on_call_to(:get) do |*args|
      i++
      raise RuntimeError.new if i % 3==0
   end

   resources = Resource.get_at_least(10)

   expect(resources).to have_exactly(9).items
end
```

### Setup deep stubs with proxy_chain

```ruby
it 'rounds the completion ratio' do
   RenderingTask.proxy_chain(:load, :completion_ratio) {|s| s.and_return(0.2523) }

   renderingController.show

   expect(response).to include('25%')
end
```

### Get best of both worlds with in memory databases

Combine proxies with an inmemory database (like SQLite) while testing, and you'll get clear, straightforward and fast tests !

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
