class CreateComptes < ActiveRecord::Migration[5.0]
  def change
    create_table :comptes do |t|
      t.string :name

      t.timestamps
    end
  end
end
