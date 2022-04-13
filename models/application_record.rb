# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  db_config = {
    "adapter" => "sqlite3",
    "pool" => 5,
    "timeout" => 5000,
    "database" => "db/wallet_application.sqlite3"
  }
  ActiveRecord::Base.establish_connection(db_config)
end
