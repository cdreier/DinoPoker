# DinoPoker

Throw away the cards! This is your new way of planning poker! 
Use the arrow keys to jump and run, use the spacebar to be invisible for others.

![first planning](https://github.com/cdreier/DinoPoker/blob/master/first-planning.png)

## Client

simplest way: start a docker image: https://hub.docker.com/repository/docker/drailing/dino-poker-client

you just need to set the `SERVER` env, pointing to your server

### Building

export the client "web" project into the `deploy/client/game` folder. 
Now build the tiny webserver with go and you are good to go.

## Server

simplest way: start a docker imgage: https://hub.docker.com/repository/docker/drailing/dino-poker-server

you can configure the port and the maximum players with the env vars `PORT` and `MAX_PLAYERS`, defaults are 5000 and 10 - i think no need to tell which number is what setting

### Building

To run the server i use the [headless server binary](https://godotengine.org/download/server).
You need to export the server as .pck, into the server folder.
Now you can start the server binary.

## Assets

Assets are from [olanartworks - 2d forest pack](https://olanartworks.itch.io/2d-forest-asset-pack) and from [@ScissorMarks](https://twitter.com/ScissorMarks) - [the dino](https://arks.itch.io/dino-characters)

