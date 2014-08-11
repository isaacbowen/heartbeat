require 'spec_helper'

describe CacheConcern do

  let(:cached_class) do
    Class.new do
      include CacheConcern

      def foo; 'foo'; end

      def args(*args); args; end

      def block; yield; end

      def bar; 'bar'; end

      cache_method :foo, expires_in: 2.minutes
      cache_method :args
      cache_method :block
    end
  end

  subject { cached_class.new }

  before(:each) { Rails.cache.clear }

  describe '::cache_method' do
    it 'should set up aliases' do
      cached_class.instance_methods.should include :foo_with_cache, :foo_without_cache
      cached_class.instance_methods.should_not include :bar_with_cache, :bar_without_cache
    end
  end

  describe '#cached_method' do
    it 'should be called for cached methods' do
      subject.should_receive(:cached_method).and_call_original

      subject.foo.should == subject.foo_without_cache
    end

    it 'should handle passed args' do
      subject.should_receive(:args_without_cache).once.with(1, 2, 3).and_call_original

      2.times { subject.args(1, 2, 3).should == [1, 2, 3] }
    end

    it 'should handle passed block' do
      subject.should_receive(:block_without_cache).once.and_call_original

      2.times { subject.block { 'yep' }.should == 'yep' }
    end

    it 'should cache the result' do
      subject.should_receive(:foo_without_cache).once

      2.times { subject.foo }
    end

    it 'should cache the result with cache options' do
      Rails.cache.should_receive(:fetch) do |key, options|
        options.should == {expires_in: 2.minutes}
        key.should == subject.cached_method_cache_key(:foo, [])
      end

      subject.foo
    end
  end

  describe '#cached_method_cache_key' do
    def cached_method_cache_key
      subject.cached_method_cache_key :foo, ['bar']
    end

    context 'without #cache_key' do
      it 'should vary with instance variables' do
        key = cached_method_cache_key

        cached_method_cache_key.should == key

        subject.instance_variable_set(:@foo, 'bar')

        cached_method_cache_key.should_not == key
      end
    end

    context 'with #cache_key' do
      it 'should invoke #cache_key' do
        cached_class.send(:define_method, :cache_key) { 'foobar' }

        cached_method_cache_key.should include 'foobar'
      end
    end
  end

end
