class AddParentToCompte < ActiveRecord::Migration[5.0]
  def change
    add_reference :comptes, :parent, foreign_key: true
  end
end
