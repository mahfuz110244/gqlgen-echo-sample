
-- +goose Up
-- SQL in section 'Up' is executed when this migration is applied
CREATE TABLE tasks (
   id SERIAL NOT NULL,
   title varchar(255) DEFAULT NULL,
   note text DEFAULT NULL,
   completed integer DEFAULT 0,
   created_at TIMESTAMP DEFAULT NULL,
   updated_at TIMESTAMP DEFAULT NULL,
   PRIMARY KEY(id)
);
CREATE INDEX task_id on tasks (id);


CREATE TABLE authors (
	id INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
	created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'),
   updated_at TIMESTAMP WITHOUT TIME ZONE,
	deleted_at TIMESTAMP WITHOUT TIME ZONE,
	created_by TEXT,
	updated_by TEXT,
	"name" TEXT NOT NULL,
	biography TEXT
);

CREATE TABLE books (
	id INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
	created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'),
   updated_at TIMESTAMP WITHOUT TIME ZONE,
	deleted_at TIMESTAMP WITHOUT TIME ZONE,
	created_by TEXT,
	updated_by TEXT,
	title TEXT NOT NULL,
   price NUMERIC(10,2) NOT NULL,
	isbn_no TEXT NOT NULL,
   author_id INT NOT NULL,
   constraint fk_books_authors foreign key (author_id) references authors(id)
);
CREATE INDEX books_author_id on books (author_id) USING btree;
-- +goose Down
-- SQL section 'Down' is executed when this migration is rolled back
-- DROP INDEX task_id;
-- DROP TABLE tasks;


