# DinoPoker

Throw away the cards! This is your new way of planning poker! 
Use the arrow keys to jump and run, use the spacebar to be invisible for others.

![first planning](https://github.com/cdreier/DinoPoker/blob/master/first-planning.png)

This is made with [Godot](https://godotengine.org/)

## Quickstart

with docker compose

```yml
version: '3.2'

services:
  server:
    image: drailing/dino-poker-server:latest
    environment:
      - MAX_PLAYERS=20
      - PORT=5000
    ports:
      - 5000:5000
  client:
    image: drailing/dino-poker-client:latest
    environment:
      - SERVER=ws://127.0.0.1:5000
    ports:
      - 8000:8000
```

## Client

simplest way: start a docker image: https://hub.docker.com/r/drailing/dino-poker-client

you just need to set the `SERVER` env, pointing to your server

### Building your own

export the client "web" project into the `deploy/client/game` folder. 
Now build the tiny webserver with go and you are good to go.

## Server

simplest way: start a docker image: https://hub.docker.com/r/drailing/dino-poker-server

you can configure the port and the maximum players with the env vars `PORT` and `MAX_PLAYERS`, defaults are 5000 and 10 - i think no need to tell which number is what setting

### Building your own

To run the server i use the [headless server binary](https://godotengine.org/download/server). Download the latest version, check if it is still the version in the docker file `CMD [ "./Godot_v3.2.1-stable_linux_server.64" ]`.
Now you need to export the server project as .pck, into the server folder.

Now you can start the server binary, or build the docker image.

## Assets

Assets are from [olanartworks - 2d forest pack](https://olanartworks.itch.io/2d-forest-asset-pack) and from [@ScissorMarks](https://twitter.com/ScissorMarks) - [the dino](https://arks.itch.io/dino-characters)

