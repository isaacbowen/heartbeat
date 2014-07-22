# see https://github.com/rails/rails/issues/11902, and specifically
# https://github.com/rails/rails/issues/11902#issuecomment-30219181

module ActiveRecord::ConnectionAdapters::PostgreSQLAdapter::OID
  class UUID < Type
    def type_cast(value)
      value == "" ? nil : value
    end
  end

  register_type 'uuid', UUID.new
end
