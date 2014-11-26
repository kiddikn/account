class AddMonthToLedgers < ActiveRecord::Migration
  def change
    add_column :ledgers, :month, :integer
  end
end
