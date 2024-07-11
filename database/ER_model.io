Table Users {
  id uuid [primary key]
  avatar_url varchar(255) [unique]
  username varchar(255) [not null, unique]
  email varchar(255) [not null, unique]

  indexes {
    username
  }
}

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
  content text [not null]
  created_at timestamp [not null]
}

Table Likes {
  id uuid [primary key]
  user uuid [not null, ref: > Users.id]
  post uuid [not null, ref: > Posts.id]
  Note: "(user, post) unique"
}

Table Follows {
  id uuid [primary key]
  from uuid [not null, ref: > Users.id]
  to uuid [not null, ref: > Users.id]
  Note: "(from, to) unique"
}

Table Chats {
  id uuid [primary key]
  user1 uuid [not null, ref: > Users.id]
  user2 uuid [not null, ref: > Users.id]
  Note: "(user1, user2) unique"
}

Table Messages {
  id uuid [primary key]
  image_url varchar(255) [unique]
  author uuid [not null, ref: > Users.id]
  chat uuid [not null, ref: > Chats.id]
  content text
  created_at timestamp [not null]
}
