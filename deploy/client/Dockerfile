FROM debian:stable-slim

RUN mkdir /app
WORKDIR /app

ADD ./game game
ADD ./webserver .

EXPOSE 8000

CMD [ "./webserver" ]
