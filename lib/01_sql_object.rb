require_relative 'db_connection'
require 'active_support/inflector'

class SQLObject
  def self.columns
    # gets the columns from the table and symbolizes them

    col_and_data = DBConnection.execute2(<<-SQL)
                      SELECT
                        *
                      FROM
                        #{table_name}
                    SQL

    col_and_data.first.collect! { |col_name_str| col_name_str.to_sym }
  end

  def self.finalize!
  end

  def self.table_name=(table_name)
    # sets the table name for the class
    @table_name = table_name
  end

  def self.table_name
    # gets the name of the table for the class
    # both .name or .to_s would work here
    @table_name || self.name.tableize
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
