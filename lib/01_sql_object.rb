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
    # creates getter and setter methods for each column
    columns.each do |col|
      define_method("#{col}") do
        attributes[col]
      end
      define_method("#{col}=") do |value|
        attributes[col] = value
      end
    end
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
    # fetches all the records from the database
    results = DBConnection.execute(<<-SQL)
                SELECT
                  *
                FROM
                  #{table_name}
              SQL
    parse_all(results)
  end

  def self.parse_all(results)
    # turn each of the Hashes into instances of the Class
    obj_array = []
    results.each do |hash|
      obj_array << self.new(hash)
    end
    obj_array
  end

  def self.find(id)
    # returns a single object with the given id
    results = DBConnection.execute(<<-SQL)
                SELECT
                  *
                FROM
                  #{table_name}
                WHERE
                  id = #{id}
              SQL
    parse_all(results).first
  end

  def initialize(params = {})
    # takes in a single params hash and iterates through it to:
    #  raise error if the attr_name is not among the columns
    #  or set the attribute by calling the setter method and #send
    params.each do |attr_name, attr_value|
      raise "unknown attribute '#{attr_name}'" unless self.class.columns.include?(attr_name.to_sym)
      send(attr_name.to_s + "=", attr_value)
    end
  end

  def attributes
    # initializes @attributes to an empty hash
    # or stores any new values added to it
    @attributes ||= {}
  end

  def attribute_values
    # returns an array of the values for each attribute
    self.class.columns.map { |col_name| self.send(col_name) }
  end

  def insert
    # adds instance's values in to its table
    col_names = self.class.columns.join(", ")
    question_marks = (["?"]*(self.class.columns.count)).join(", ")
    DBConnection.execute(<<-SQL, *attribute_values)
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{question_marks})
      SQL

    # updates SQLObject instance with newly assigned ID after insert
    self.id = DBConnection.last_insert_row_id
  end

  def update
    # changes attributes
    col_set = self.class.columns.map { |attr| "#{attr} = ?"}.join(", ")
    DBConnection.execute(<<-SQL, *attribute_values, id)
      UPDATE
        #{self.class.table_name}
      SET
        #{col_set}
      WHERE
        #{self.class.table_name}.id = ?
    SQL
  end

  def save
    # calls insert/update as appropriate
    id.nil? ? insert : update
  end
end
