# -*- encoding: utf-8 -*-

require 'spec_helper'

module RSpecProxies

  class User
    def self.load(name)
      User.new(name)
    end

    def initialize(name)
      @name = name
    end
    attr_reader :name

    def url
      case name
      when 'Joe'
        'http://www.greatjoe.net'
      when 'Jim'
        'http://www.bigjim.net'
      when 'Joe'
        "http://www.#{name}.net"
      end
    end

    def ==(o)
      o.class == self.class && o.name == self.name
    end

  end

  class ProfileController

    def render(name)
      view_for(User.load(name))
    end

    private

    def view_for(user)
      "<html><body><a href='#{user.url}'>#{user.name}</a></body></html>"
    end
  end

  describe 'proxies' do

    before :each do
      @controller = ProfileController.new
    end

    it 'hooks on return from a method' do
      user = nil

      User.on_result_from(:load) {|u| user = u}

      @controller.render('Joe')

      expect(user).to eq(User.new('Joe'))
    end

    it 'has a shortcut to collect return values from a method' do
      users = User.capture_results_from(:load)

      @controller.render('Joe')
      @controller.render('Jim')

      expect(users).to eq([User.new('Joe'), User.new('Jim')])
    end

    it 'has a shortcut to collect the latest return value from a method' do
      capture_result_from(User, :load, into: :user)

      html = @controller.render('Joe')

      expect(html).to include(@user.url)
    end

    it 'hooks on arguments before a method call' do
      User.on_call_to(:load) do |name|
        raise RuntimeError.new if name == 'Jim'
      end

      expect(@controller.render('Joe')).not_to be_nil
      expect{@controller.render('Jim')}.to raise_error(RuntimeError)
    end

    it "can setup deep stubs on yet unloaded instances" do
      User.proxy_chain(:load, :url) {|s| s.and_return('http://pirates.net')}

      html = @controller.render('Jack')

      expect(html).to include('http://pirates.net')
    end
  end
end
