gqlgen-echo-sample
====

Sample implementation of a Golang GraphQL server using gqlgen and Echo. 

## Description

We combined gqlgen, a GraphQL library, and Echo, a web framework, to build a GraqhQL server implemented in the Go language.

[https://tech.fusic.co.jp/posts/2020-04-12-gqlgen-echo-sample/](https://tech.fusic.co.jp/posts/2020-04-12-gqlgen-echo-sample/)

## Screen Shot

![Mutation Sample](https://user-images.githubusercontent.com/8074640/79082385-816da380-7d60-11ea-8461-b42b72680879.png)

![Query Sample](https://user-images.githubusercontent.com/8074640/79082387-83cffd80-7d60-11ea-9a98-2ed204e5d2ee.png)

## Usage


```bash
$ go get github.com/yuuu/gqlgen-echo-sample
```

1. Create the database `gqlgen-echo-sample` in PosgtreSQL beforehand.
2. Modify `db/dbconf.yml` appropriately.
3. Change the argument of `gorm.Open()` in `main.go` as needed.

```bash
$ goose up
$ docker-compose up --build
$ go run main.go
```

Go to [http://localhost:3000/playground](http://localhost:3000/playground).

task create
```bash
mutation {
  createTask(
    input: {
    	title: "Title",
    	note: "Note..." 
    }
  ) {
    id
    title
    note
    completed
    created_at
    updated_at
  }
}
```

Get all task
```bash
{
  tasks {
    id
    title
    note
    completed
    created_at
    updated_at
  }
}
```


Tutorial to make golang GraphQL server with gqlgen + Echo
Hello, this is Okazaki.

In this article, I will introduce in a tutorial format how to create a GraqhQL server implemented in Go language by combining gqlgen, which is a GraphQL library, and Echo , which is a web framework .

GraphQL Mutation

The source code is published below.

https://github.com/yuuu/gqlgen-echo-sample

Library to use
gqlgen
As of April 2020, the following two are candidates for implementing GraphQL server in Go language.

graphql-go/graphql (Star 6.2k)
99designs/gqlgen (Star 4.2k)
In terms of the number of stars, the former is dominant and it is easy to obtain information in Japanese, but I used the latter this time in anticipation of the following strengths.

Schema first

Code is automatically generated so you can focus on implementing logic
Easy to share schema with frontend
More active development than the former
Echo
A web framework for the Go language. With Go language, a simple web server can be created with net / http , and gqlgen also has a function as a web server by itself. There are many Go language web frameworks besides Echo.

Among them, Echo has "a set of functions required for Web applications". I chose Echo with the expectation that JWT authentication and various security measures will be added in the future.

others
Use goose as the ORM and goose as the migration tool .

Implemented a simple web server
Go get the required libraries
Go get the required libraries. Since we are using Go Modules, GO111MODULEbe careful not to forget the export environment variable.

$ export GO111MODULE=on 
$ go mod init github.com/yuuu/gqlgen-echo-sample
$ go get bitbucket.org/liamstask/goose
$ go get github.com/99designs/gqlgen
$ go get github.com/labstack/echo
$ go get github.com/jinzhu/gorm
Echo implementation
main.goAnd write the following code.

package main

import (
	"log"
	"net/http"

	"github.com/labstack/echo"
	"github.com/labstack/echo/middleware"
)

func main() {
	e := echo.New()

	e.Use(middleware.Logger())
	e.Use(middleware.Recover())

	e.GET("/", welcome())

	err := e.Start(":3000")
	if err != nil {
		log.Fatalln(err)
	}
}

func welcome() echo.HandlerFunc {
	return func(c echo.Context) error {
		return c.String(http.StatusOK, "Welcome!")
	}
}
To start the server go run.

$ go run main.go
When I access http: // localhost: 3000 , the message "Welcome!" Is displayed in the browser.

Welcome!

Migration using goose
Create a migration file for connection with the DB.

Log in to PostgreSQL in advance and execute the following query to create a database.

CREATE DATABASE "gqlgen-echo-sample";
To connect to this database, db/dbconfig.ymlcreate and describe as follows.

development:
  driver: postgres
  open: user={{PostgreSQLのユーザ名}} password={{PostgreSQLのパスワード}} dbname=gqlgen-echo-sample sslmode=disable
Execute the following command to check the connection with the database. If the output is obtained in the same way, the connection is successful.

$ goose status
goose: status for environment 'development'
    Applied At                  Migration
    =======================================
Next, create a migration file.

$ goose create CreateTasks sql
Edit the created file as follows.

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

-- +goose Down
-- SQL section 'Down' is executed when this migration is rolled back
DROP INDEX task_id;
DROP TABLE tasks;
Execute the following command to execute the migration.

$ goose up
goose: migrating db environment 'development', current version: 0, target: 20200413055140
OK    20200413055140_CreateTasks.sql
Introduction of gorm
main.goAdd the connection process with DB to the beginning part of.

package main

import (
	"fmt"
	"log"
	"net/http"

	"github.com/jinzhu/gorm"
	_ "github.com/jinzhu/gorm/dialects/postgres"

	"github.com/labstack/echo"
	"github.com/labstack/echo/middleware"
)

func main() {
	_, err := gorm.Open(
		"postgres",
		fmt.Sprintf(
			"host=%s port=%d user=%s dbname=%s password=%s sslmode=disable",
			"127.0.0.1", 5432, "{{PostgreSQLのユーザ名}}", "gqlgen-echo-sample", "{{PostgreSQLのパスワード}}",
		),
	)
	if err != nil {
		log.Fatalln(err)
	}

	e := echo.New()

  // 省略
}

// 省略
Implemented GraphQL
Implemented Mutation
First of all, run the gqlgen generator.

$ gqlgen init
A sample GraphQL schema and the source code to implement it will be generated. Modify the GraphQL schema ( graph/schema.graphqls) as follows:

type Task {
  id: ID!
  title: String!
  note: String!
  completed: Int!
  created_at: String!
  updated_at: String!
}

input NewTask {
  title: String!
  note: String!
}

type Mutation {
  createTask(input: NewTask!): Task!
}
Now that we have modified the schema, we will regenerate the source code.

$ rm graph/schema.resolvers.go
$ gqlgen
Describe the process equivalent to Mutation in graph/schema.resolvers.go.

package graph

// This file will be automatically regenerated based on the schema, any resolver implementations
// will be copied through when generating and any unknown code will be moved to the end.

import (
	"context"
	"time"

	"github.com/yuuu/gqlgen-echo-sample/graph/generated"
	"github.com/yuuu/gqlgen-echo-sample/graph/model"
)

func (r *mutationResolver) CreateTask(ctx context.Context, input model.NewTask) (*model.Task, error) {
  // ここから追記
	timestamp := time.Now().Format("2006-01-02 15:04:05")

	task := model.Task{
		Title:     input.Title,
		Note:      input.Note,
		Completed: 0,
		CreatedAt: timestamp,
		UpdatedAt: timestamp,
	}
	r.DB.Create(&task)

	return &task, nil
  // ここまで追記
}

// Mutation returns generated.MutationResolver implementation.
func (r *Resolver) Mutation() generated.MutationResolver { return &mutationResolver{r} }

type mutationResolver struct{ *Resolver }
In order to be able to use gorm in the Resolver method, graph/resolver.goadd to.

package graph

import "github.com/jinzhu/gorm"

// This file will not be regenerated automatically.
//
// It serves as dependency injection for your app, add any dependencies you require here.

type Resolver struct {
	DB *gorm.DB // ここを追記
}
Connection with Echo
Add to to connect the implemented Mutation and Echo main.go.

package main

import (
	"fmt"
	"log"
	"net/http"

	"github.com/99designs/gqlgen/graphql/handler"
	"github.com/99designs/gqlgen/graphql/playground"
	"github.com/jinzhu/gorm"
	_ "github.com/jinzhu/gorm/dialects/postgres"
	"github.com/yuuu/gqlgen-echo-sample/graph"
	"github.com/yuuu/gqlgen-echo-sample/graph/generated"

	"github.com/labstack/echo"
	"github.com/labstack/echo/middleware"
)

func main() {
	db, err := gorm.Open( // 修正
		"postgres",
		fmt.Sprintf(
			"host=%s port=%d user=%s dbname=%s password=%s sslmode=disable",
			"127.0.0.1", 5432, "postgres", "gqlgen-echo-sample", "postgres",
		),
	)
	if err != nil {
		log.Fatalln(err)
	}

	e := echo.New()

	e.Use(middleware.Logger())
	e.Use(middleware.Recover())

	e.GET("/", welcome())

	// 追記ここから
	graphqlHandler := handler.NewDefaultServer(
		generated.NewExecutableSchema(
			generated.Config{Resolvers: &graph.Resolver{DB: db}},
		),
	)
	playgroundHandler := playground.Handler("GraphQL", "/query")

	e.POST("/query", func(c echo.Context) error {
		graphqlHandler.ServeHTTP(c.Response(), c.Request())
		return nil
	})

	e.GET("/playground", func(c echo.Context) error {
		playgroundHandler.ServeHTTP(c.Response(), c.Request())
		return nil
	})
	// 追記ここまで

	err = e.Start(":3000")
	if err != nil {
		log.Fatalln(err)
	}
}

func welcome() echo.HandlerFunc {
	return func(c echo.Context) error {
		return c.String(http.StatusOK, "Welcome!")
	}
}
Finally, the one generated by gqlgen is server.gounnecessary this time, so let's delete it.

$ rm server.go
Mutation operation check
Start the server.

$ go run main.go
Go to http: // localhost: 3000 / playground in your browser .

Let's try the following Mutation.

mutation {
  createTask(
    input: {
    	title: "Title",
    	note: "Note..." 
    }
  ) {
    id
    title
    note
    completed
    created_at
    updated_at
  }
}
You can get the result by clicking the triangle button in the center.

GraphQL Mutation

Implement Query
Add to the schema.

type Task {
  id: ID!
  title: String!
  note: String!
  completed: Int!
  created_at: String!
  updated_at: String!
}

input NewTask {
  title: String!
  note: String!
}

type Mutation {
  createTask(input: NewTask!): Task!
}

# ここから追記
type Query {
  tasks: [Task!]!
}
# ここまで追記
Now that we've modified the schema, we'll regenerate the code.

$ gqlgen
Describe the process equivalent to Query in graph/schema.resolvers.go.

package graph

// This file will be automatically regenerated based on the schema, any resolver implementations
// will be copied through when generating and any unknown code will be moved to the end.

import (
	"context"
	"time"

	"github.com/yuuu/gqlgen-echo-sample/graph/generated"
	"github.com/yuuu/gqlgen-echo-sample/graph/model"
)

// 省略

func (r *queryResolver) Tasks(ctx context.Context) ([]*model.Task, error) {
	// ここから追記
	tasks := []*model.Task{}

	r.DB.Find(&tasks)

	return tasks, nil
	// ここまで追記
}

// Mutation returns generated.MutationResolver implementation.
func (r *Resolver) Mutation() generated.MutationResolver { return &mutationResolver{r} }

// Query returns generated.QueryResolver implementation.
func (r *Resolver) Query() generated.QueryResolver { return &queryResolver{r} }

type mutationResolver struct{ *Resolver }
type queryResolver struct{ *Resolver }
Query operation check
Start the server again.

$ go run main.go
Go to http: // localhost: 3000 / playground in your browser .

Let's try the following query.

{
  tasks {
    id
    title
    note
    completed
    created_at
    updated_at
  }
}
You can get the result by clicking the triangle button in the center.

GraphQL Mutation

summary
I was able to easily implement a GraphQL server by combining gqlgen and Echo. Please give it a try.

references
how to access echo.context in resolver?
Go API with echo, gorm, and GraphQL