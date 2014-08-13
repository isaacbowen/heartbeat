module CacheConcern
  extend ActiveSupport::Concern

  included do
    cache_method :cached_attributes_hash

    cattr_accessor(:cached_attributes) { [] }

    delegate :cached_attribute?, to: :class
  end

  module ClassMethods
    def cache_method *args
      options = args.extract_options!
      methods = args

      methods.each do |method|
        method_name, method_punctuation = method.to_s.split(/(?=[\?\!])/)

        define_method "#{method_name}_with_cache#{method_punctuation}" do |*args, &block|
          if cached_attribute? method
            cached_attribute method
          else
            cached_method method, options, args, &block
          end
        end

        alias_method_chain method, :cache
      end
    end

    def cache_attribute *args
      cache_method *args

      self.cached_attributes = self.cached_attributes + args
    end

    def cached_attribute? method
      cached_attributes.include? method
    end
  end

  def cached_attribute attribute
    if @_retrieving_cached_attribute
      uncached_method attribute
    else
      begin
        @_retrieving_cached_attribute = true

        cached_attributes_hash[attribute]
      ensure
        remove_instance_variable :@_retrieving_cached_attribute
      end
    end
  end

  def cached_attributes_hash
    Hash[cached_attributes.map { |a| [a, uncached_method(a)] }]
  end

  def cached_method_cache_key method, args
    if respond_to? :cache_key
      "#{cache_key}/#{method}/#{Digest::MD5.hexdigest(args.inspect)}"
    else
      "#{self.class.name}/#{Digest::MD5.hexdigest(instance_variables.map { |v| [v, instance_variable_get(v)] }.inspect)}/#{method}/#{Digest::MD5.hexdigest(args.inspect)}"
    end
  end

  def cached_method method, options, args, &block
    method_name, method_punctuation = method.to_s.split(/(?=[\?\!])/)

    Rails.cache.fetch(cached_method_cache_key(method, args), options) do
      uncached_method method, *args, &block
    end
  end

  def uncached_method method, *args, &block
    method_name, method_punctuation = method.to_s.split(/(?=[\?\!])/)

    send "#{method_name}_without_cache#{method_punctuation}", *args, &block
  end

end
