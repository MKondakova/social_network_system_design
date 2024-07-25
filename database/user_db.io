Table Follows {
  from uuid [not null, ref: > Users.id]
  to uuid [not null, ref: > Users.id]
  indexes {
    (from, to) [pk]
  }
}

Table Users {
  id uuid [primary key]
  avatar_url varchar(255) [unique]
  username varchar(255) [not null, unique]
  email varchar(255) [not null, unique]

  indexes {
    username
  }
}
