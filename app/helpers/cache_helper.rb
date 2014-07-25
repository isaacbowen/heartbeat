module CacheHelper

  def cached? name = {}, options = nil
    controller.fragment_exist? cache_fragment_name(name, options), options
  end

end
