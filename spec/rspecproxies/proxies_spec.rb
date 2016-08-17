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
      allow(User).to receive(:load).and_after_calling_original {|u| user = u}

      @controller.render('Joe')

      expect(user).to eq(User.new('Joe'))
    end

    it 'calls the original method with the given block when hooking on return' do
      allow(Array).to receive(:new).and_after_calling_original {}

      array = Array.new(2) { 4 }

      expect(array).to eq([4,4])
    end

    it 'has a shortcut to collect return values from a method' do
      users = []
      allow(User).to receive(:load).and_collect_results_into(users)

      @controller.render('Joe')
      @controller.render('Jim')

      expect(users).to eq([User.new('Joe'), User.new('Jim')])
    end

    it 'has a shortcut to collect the latest return value from a method' do
      allow(User).to receive(:load).and_capture_result_into(self, :user)

      html = @controller.render('Joe')

      expect(html).to include(@user.url)
    end

    it 'hooks on arguments before a method call' do
      allow(User).to receive(:load).and_before_calling_original { |name|
        raise RuntimeError.new if name == 'Jim'
      }

      expect(@controller.render('Joe')).not_to be_nil
      expect{@controller.render('Jim')}.to raise_error(RuntimeError)
    end

    it 'calls the original method with the given block when hooking on arguments' do
      allow(Array).to receive(:new).and_before_calling_original {}

      array = Array.new(2) { 4 }

      expect(array).to eq([4,4])
    end

    it 'can setup deep stubs on yet unloaded instances' do
      puts self.class.superclass

      allow(User).to proxy_message_chain("load.url") {|s| s.and_return('http://pirates.net')}

      html = @controller.render('Jack')

      expect(html).to include('http://pirates.net')
    end

    it 'calls original methods with the given block when creating deep proxies' do
      allow(Array).to proxy_message_chain('new.map') { |s| s.and_call_original }

      array = Array.new(2) { 4 }.map {|i| i+1}

      expect(array).to eq([5,5])
    end
  end
end
