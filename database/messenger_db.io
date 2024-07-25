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

Table MessagesReadability {
  chat uuid [ref :> Chats.id]
  last_read uuid [ref :> Messages.id]
  user uuid [ref :> Users.id]
  readed_at timestamp
  indexes {
    (user, chat) [pk]
  }
}
