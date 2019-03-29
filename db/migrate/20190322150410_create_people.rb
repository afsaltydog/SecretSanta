class CreatePeople < ActiveRecord::Migration[5.2]
  def change
    create_table :people do |t|
      t.string :name
      t.string :spouse
      t.string :last_yr
      t.string :last_2yr
      t.string :current
      t.references :group, foreign_key: true

      t.timestamps
    end
  end
end
