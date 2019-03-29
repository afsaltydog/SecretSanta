class CreateWishlists < ActiveRecord::Migration[5.2]
  def change
    create_table :wishlists do |t|
      t.string :item
      t.text :description
      t.references :person, foreign_key: true

      t.timestamps
    end
  end
end
