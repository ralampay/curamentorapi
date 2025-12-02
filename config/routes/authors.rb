post "/publications/:publication_id/authors", to: "authors#create"
delete "/publications/:publication_id/authors/:id", to: "authors#delete"
get "/publications/:publication_id/authors", to: "authors#index"
