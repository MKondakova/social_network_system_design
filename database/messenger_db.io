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
  readed bool [default: false]
  created_at timestamp [not null]
}
