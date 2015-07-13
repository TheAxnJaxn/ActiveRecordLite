require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    # adds the ability to search using ::where
    where_line = params.keys.map { |key| "#{key} = ?" }.join(" AND ")
    splat_param = params.values

    results = DBConnection.execute(<<-SQL, *splat_param)
                SELECT
                  *
                FROM
                  #{self.table_name}
                WHERE
                  #{where_line}
              SQL

    parse_all(results)
  end
end

class SQLObject
  # Mixes in Searchable
  extend Searchable
end
