require 'spec_helper'

describe CacheConcern do

  let(:cached_class) do
    Class.new do
      include CacheConcern

      def foo; 'foo'; end

      def args(*args); args; end

      def block; yield; end

      def bar; 'bar'; end

      def empty?; false; end

      def foo_bar; bar; end
    end
  end

  subject { cached_class.new }

  before(:each) { Rails.cache.clear }

  def setup &block
    cached_class.instance_eval &block
  end


  describe '::cache_method' do
    it 'should set up aliases' do
      setup { cache_method :foo }

      cached_class.instance_methods.should include :foo_with_cache, :foo_without_cache
      cached_class.instance_methods.should_not include :bar_with_cache, :bar_without_cache
    end

    it 'should handle multiple methods' do      
      setup { cache_method :foo, :bar }

      cached_class.instance_methods.should include :foo_with_cache, :bar_with_cache
    end
  end

  describe '::cached_attribute' do
    it 'should batch up attributes' do
      setup { cache_attribute :foo, :bar }

      cached_class.any_instance.should_receive(:foo_without_cache).once.and_call_original
      cached_class.any_instance.should_receive(:bar_without_cache).once.and_call_original

      2.times do
        cached_class.new.foo.should == 'foo'
        cached_class.new.bar.should == 'bar'
      end
    end

    it 'should handle multiple, interdependent methods' do
      setup { cache_attribute :foo_bar, :bar }

      subject.foo_bar.should == 'bar'
    end
  end

  describe '#cached_method' do
    it 'should be called for cached methods' do
      setup { cache_method :foo }
      setup { cache_method :bar }

      subject.should_receive(:cached_method).twice.and_call_original

      subject.foo.should == subject.foo_without_cache
      subject.bar.should == subject.bar_without_cache
    end

    it 'should handle punctuation' do
      setup { cache_method :empty? }

      subject.should_receive(:empty_without_cache?)
      subject.empty?
    end

    it 'should handle passed args' do
      setup { cache_method :args }

      subject.should_receive(:args_without_cache).once.with(1, 2, 3).and_call_original

      2.times { subject.args(1, 2, 3).should == [1, 2, 3] }
    end

    it 'should handle passed block' do
      setup { cache_method :block }

      subject.should_receive(:block_without_cache).once.and_call_original

      2.times { subject.block { 'yep' }.should == 'yep' }
    end

    it 'should cache the result' do
      setup { cache_method :foo }

      subject.should_receive(:foo_without_cache).once

      2.times { subject.foo }
    end

    it 'should cache the result with cache options' do
      setup { cache_method :foo, expires_in: 2.minutes }

      # this is getting called twice. currently blaming rspec. finding no
      # symptoms of the second call outside of rspec.
      Rails.cache.should_receive(:fetch).with(subject.cached_method_cache_key(:foo, []), {expires_in: 2.minutes}).and_call_original

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
