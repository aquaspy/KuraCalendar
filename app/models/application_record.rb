class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  def self.reclaim_space
    connection.execute("VACUUM")
  rescue ActiveRecord::StatementInvalid, SQLite3::Exception
    nil
  end
end
