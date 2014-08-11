module CacheConcern
  extend ActiveSupport::Concern

  module ClassMethods
    def cache_method method, options = {}
      method_name, method_punctuation = method.to_s.split(/(?=[\?\!])/)

      define_method "#{method_name}_with_cache#{method_punctuation}" do |*args, &block|
        cached_method method_name, options, args, &block
      end

      alias_method_chain method, :cache
    end
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
      send "#{method_name}_without_cache#{method_punctuation}", *args, &block
    end
  end

end
