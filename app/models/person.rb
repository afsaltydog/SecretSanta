class Person < ApplicationRecord
  belongs_to :group
  has_many :wishlists
  
  has_many :wish_list, class_name: "Wishlist", foreign_key: "person_id"
  has_many :my_wishes, through: :wish_list, source: :person

  has_many :is_my_wishlist, class_name: "Wishlist", foreign_key: "id"
  has_many :my_wishlist, through: :is_my_wishlist, source: :wishlist
  # has_many :not_my_friends, through: :friends_with_me, source: :friend
end
