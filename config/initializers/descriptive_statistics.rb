require 'descriptive_statistics/safe'

module Enumerable

  # slightly less evil version than what descriptive_statistics ships with
  (DescriptiveStatistics.instance_methods - Enumerable.instance_methods).each do |m|
    define_method m, DescriptiveStatistics.instance_method(m)
  end

end
