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
    # write a new SQL query that will fetch at most one record
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
    self.class.columns.map { |col_name| send(col_name.to_s+"=", ) }
    # call send on the instance to get the value

    # Once you have the #attribute_values method working, I passed this into DBConnection.execute using the splat operator
  end

  def insert
    # adds instance's values in to its table
    col_names = self.class.columns.join(",")
    question_marks = (["?"]*(self.class.columns.count)).join(",")
    DBConnection.execute(<<-SQL, col_names)
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{question_marks})
      SQL

    # When the DB inserts the record, it will assign the record an ID. After the INSERT query is run, we want to update our SQLObject instance with the assigned ID. Check out the DBConnection file for a helpful method.
  end

  def update
    # ...
  end

  def save
    # ...
  end
end
