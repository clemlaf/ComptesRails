class CreateEntries < ActiveRecord::Migration[5.0]
  def change
    create_table :entries do |t|
      t.date :date
      t.references :cpS
      t.references :cpD
      t.string :com
      t.integer :pr
      t.boolean :poS
      t.boolean :poD
      t.references :moyen
      t.references :category

      t.timestamps
    end
  end
end
