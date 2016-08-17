# -*- encoding: utf-8 -*-

module RSpecProxies
  module Proxies

    # Will call the given block with all the actual arguments every time
    # the method is called
    def and_before_calling_original
      self.and_wrap_original do |m, *args, &block|
        yield *args
        m.call(*args, &block)
      end
    end

    # Will call the given block with it's result every time the method
    # returns
    def and_after_calling_original
      self.and_wrap_original do |m, *args, &block|
        result = m.call(*args, &block)
        yield result
        result
      end
    end

    # Will capture all the results of the method into the given
    # array
    def and_collect_results_into(collector)
      self.and_after_calling_original { |result| collector << result }
    end

    # Will capture (or override) result from the target's method in
    # the specified instance variable of target
    def and_capture_result_into(target, instance_variable_name)
      self.and_after_calling_original do |result|
        target.instance_variable_set("@#{instance_variable_name}", result)
      end
    end

  end
end

RSpec::Mocks::Matchers::Receive.include(RSpecProxies::Proxies)
