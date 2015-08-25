require_relative '03_associatable'

module Associatable

  def has_one_through(name, through_name, source_name)
    # defines a method that will fetch 1 associated object
    define_method(name) do
      # sets through options information for SQL query
      through_options = self.class.assoc_options[through_name]
      through_table_name = through_options.table_name
      through_primary_key = through_options.primary_key
      through_foreign_key = through_options.foreign_key

      # sets source options information for SQL query
      source_options = through_options.model_class.assoc_options[source_name]
      source_table_name = source_options.table_name
      source_primary_key = source_options.primary_key
      source_foreign_key = source_options.foreign_key

      # now that the two sets of options are set, time to query:
      key_value = self.send(through_foreign_key)
      results = DBConnection.execute(<<-SQL, key_value)
        SELECT
          #{source_table_name}.*
        FROM
          #{through_table_name}
        JOIN
          #{source_table_name}
        ON
          #{through_table_name}.#{source_foreign_key} = #{source_table_name}.#{source_primary_key}
        WHERE
          #{through_table_name}.#{through_primary_key} = ?
      SQL

      source_options.model_class.parse_all(results).first
    end

  end
end
