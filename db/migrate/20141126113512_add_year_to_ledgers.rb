class AddYearToLedgers < ActiveRecord::Migration
  def change
    add_column :ledgers, :year, :integer
  end
end
