package main

import (
	"database/sql"
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
	_ "github.com/lib/pq"
)

type User struct {
	ID    int
	Name  string
	Email string
}

var db *sql.DB

func initDB() {
	err := godotenv.Load()
	if err != nil {
		log.Println(".env file not found")
	}

	connStr := fmt.Sprintf(
		"host=%s port=%s user=%s password=%s dbname=%s sslmode=require",
		os.Getenv("DB_HOST"),
		os.Getenv("DB_PORT"),
		os.Getenv("DB_USER"),
		os.Getenv("DB_PASSWORD"),
		os.Getenv("DB_NAME"),
	)

	db, err = sql.Open("postgres", connStr)
	if err != nil {
		log.Fatal(err)
	}

	createTable := `
	CREATE TABLE IF NOT EXISTS users (
		id SERIAL PRIMARY KEY,
		name TEXT,
		email TEXT
	);`

	_, err = db.Exec(createTable)
	if err != nil {
		log.Fatal(err)
	}

	fmt.Println("Database connected")
}

func main() {
	initDB()

	r := gin.Default()

	r.LoadHTMLGlob("templates/*")
	r.Static("/static", "./static")

	r.GET("/", func(c *gin.Context) {

		rows, err := db.Query("SELECT id, name, email FROM users ORDER BY id DESC")
		if err != nil {
			c.String(500, err.Error())
			return
		}

		var users []User

		for rows.Next() {
			var u User
			rows.Scan(&u.ID, &u.Name, &u.Email)
			users = append(users, u)
		}

		c.HTML(http.StatusOK, "index.html", gin.H{
			"users": users,
		})
	})

	r.POST("/users", func(c *gin.Context) {

		name := c.PostForm("name")
		email := c.PostForm("email")

		_, err := db.Exec(
			"INSERT INTO users(name, email) VALUES($1, $2)",
			name,
			email,
		)

		if err != nil {
			c.String(500, err.Error())
			return
		}

		c.Redirect(302, "/")
	})

	port := os.Getenv("PORT")

	r.Run(":" + port)
}