# -*- encoding: utf-8 -*-

module RSpecProxies

  module ProxyChains

    # Sets up proxies all down the selector chain, until the last where
    # a simple method stub is created and on which the block is called.
    # Allows to set up stub chains quickly and safely.
    #
    # message_chain : a dot separated message chain, like the standard
    # message_chain expectation
    def proxy_message_chain(message_chain, &last_proxy_setup_block)
      proxy_message_chain_a((message_chain.split('.').map &:intern), &last_proxy_setup_block)
    end

    # Same as #proxy_message_chain but using an array of symbols as
    # message_chain instead of a dot separated string
    def proxy_message_chain_a(messages, &last_proxy_setup_block)
      first_message = messages.first
      return last_proxy_setup_block.call(receive(first_message)) if messages.size == 1

      receive(first_message).and_wrap_original do |m, *args, &original_block|
        result = m.call(*args, &original_block)
        allow(result).to proxy_message_chain_a(messages.drop(1), &last_proxy_setup_block)
        result
      end
    end

  end

end

RSpec::Core::ExampleGroup.include(RSpecProxies::ProxyChains)
