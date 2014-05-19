# -*- encoding: utf-8 -*-

class Object

  # Will call the given block with it's result every time the method
  # returns
  def on_result_from(method_name)
    stock_response = self.original_response(method_name)

    self.stub(method_name) do |*args, &block|
      result = stock_response.call(*args, &block)
      yield result
      result
    end
  end

  # Will capture all the results of the method into the returned
  # array
  def capture_results_from(method_name)
    all_results = []
    on_result_from(method_name) {|result| all_results << result }
    all_results
  end

  # Will capture (or override) result from the target's method in
  # the details[:into] instance variable
  def capture_result_from(target, method_name, details)
    into = details[:into]
    target.on_result_from(method_name) {|result| instance_variable_set("@#{into}", result)}
  end

  # Will call the given block with all the actual arguments every time
  # the method is called
  def on_call_to(method_name)
    stock_response = self.original_response(method_name)

    self.stub(method_name) do |*args, &block|
      yield *args
      stock_response.call(*args, &block)
    end

  end

  # Sets up proxies all down the selector chain, until the last where
  # a simple method stub is created and on which the block is called.
  # Allows to set up stub chains quickly and safely.
  def proxy_chain(*selectors, &block)
    if selectors.count == 1
      final_stub = self.stub(selectors.first)
      block.call(final_stub) unless block.nil?
    else
      self.on_result_from(selectors.first) do |result|
        result.proxy_chain(*selectors[1..-1], &block)
      end
    end
  end

  protected

  # Lambda that calls the original implementation of a method
  def original_response(method_name)
    if self.methods.include?(method_name)
      self.method(method_name)
    else
      lambda do |*args, &block|
        self.send(:method_missing, method_name, *args, &block)
      end
    end
  end

end
