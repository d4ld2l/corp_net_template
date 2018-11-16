docker run --name mongo -d mongo:3.0 --smallfiles
docker run --name rocketchat -p 8080:3000 --link mongo rocketchat/rocket.chat