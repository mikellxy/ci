package main

import "github.com/gin-gonic/gin"

func main() {
	r := gin.Default()

	r.GET("/home", func(c *gin.Context) {
		c.Writer.Write([]byte("Hello from gin!"))
	})

	r.Run(":8090")
}