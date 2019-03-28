class Wishlist < ApplicationRecord
  belongs_to :person, foreign_key: "person_id", class_name: "Person"
end
