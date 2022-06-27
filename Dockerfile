FROM node:12-alpine
WORKDIR /app

Run npm install -g yapi-cli

EXPOSE 3000 9090

ENTRYPOINT [ "yapi", "server" ]
