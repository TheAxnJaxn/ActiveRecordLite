require_relative 'db_connection'
require 'active_support/inflector'

class SQLObject
  def self.columns
    # ...
  end

  def self.finalize!
  end

  def self.table_name=(table_name)
    # sets the table name for the class
    @table_name = table_name
  end

  def self.table_name
    # gets the name of the table for the class
    @table_name || self.name.tableize
    # both .name or .to_s would work here
  end

  def self.all
    # ...
  end

  def self.parse_all(results)
    # ...
  end

  def self.find(id)
    # ...
  end

  def initialize(params = {})
    # ...
  end

  def attributes
    # ...
  end

  def attribute_values
    # ...
  end

  def insert
    # ...
  end

  def update
    # ...
  end

  def save
    # ...
  end
end
