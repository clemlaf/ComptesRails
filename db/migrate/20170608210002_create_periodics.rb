class CreatePeriodics < ActiveRecord::Migration[5.0]
  def change
    create_table :periodics do |t|
      t.date :lastdate
      t.references :cpS, foreign_key: true
      t.references :cpD, foreign_key: true
      t.string :com
      t.integer :pr
      t.integer :days
      t.integer :months
      t.references :moyen, foreign_key: true
      t.references :category, foreign_key: true

      t.timestamps
    end
  end
end
