Table Posts {
  id uuid [primary key]
  image_url varchar(255) [unique]
  content text
  geolocation point [not null]
  author uuid [not null, ref: > Users.id]
  created_at timestamp
}

Table Comments {
  id uuid [primary key]
  author uuid [not null, ref: > Users.id]
  post uuid [not null, ref: > Posts.id]
  reply uuid [ref: > Comments.id]
  content text [not null]
  created_at timestamp [not null]
}

Table Likes {
  user uuid [not null, ref: > Users.id]
  post uuid [not null, ref: > Posts.id]
  indexes {
    (user, post) [pk]
  }
}

