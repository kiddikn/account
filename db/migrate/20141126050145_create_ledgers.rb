class CreateLedgers < ActiveRecord::Migration
  def change
    create_table :ledgers do |t|
      t.string :no
      t.date :processing
      t.string :group
      t.string :manager
      t.string :item
      t.text :resume
      t.integer :amount
      t.text :note

      t.timestamps
    end
  end
end
