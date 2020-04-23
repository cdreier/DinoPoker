package main

import (
	"html/template"
	"log"
	"net/http"
	"os"

	"github.com/urfave/cli/v2"
)

type indexData struct {
	Server string
}

func main() {

	app := &cli.App{
		Name:  "jump n running poker",
		Usage: "start the webserver with ws server",
		Flags: []cli.Flag{
			&cli.StringFlag{
				Name:    "server",
				Value:   "ws://127.0.0.1",
				EnvVars: []string{"SERVER"},
				Usage:   "set the server of the websocket server",
			},
		},
		Action: func(c *cli.Context) error {

			http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
				if r.URL.Path == "/" {
					// handle index file
					tmpl, err := template.ParseFiles("./game/index.html")
					if err != nil {
						http.Error(w, err.Error(), http.StatusInternalServerError)
						return
					}

					tmpl.Execute(w, indexData{
						Server: c.String("server"),
					})
					return
				}
				http.FileServer(http.Dir("./game")).ServeHTTP(w, r)
			})

			log.Println("starting on port 8000")
			return http.ListenAndServe(":8000", nil)
		},
	}

	err := app.Run(os.Args)
	if err != nil {
		log.Fatal("cannot start", err.Error())
	}
}
