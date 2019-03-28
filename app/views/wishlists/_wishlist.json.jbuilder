json.extract! wishlist, :id, :item, :description, :person_id, :created_at, :updated_at
json.url wishlist_url(wishlist, format: :json)
