FROM mhart/alpine-node:14 AS build

WORKDIR /usr/src/app
COPY . .

# Replace prod with prod-min to exclude the optional dbms dependencies
# and uncomment the needed one below to build a smaller Docker image.
RUN npm run prod
#RUN npm install --no-package-lock pg
#RUN npm install --no-package-lock aws-sdk
#RUN npm install --no-package-lock memcached
#RUN npm install --no-package-lock mongodb
#RUN npm install --no-package-lock ioredis
#RUN npm install --no-package-lock rethinkdbdash

FROM mhart/alpine-node:slim-14
RUN apk add --no-cache curl

WORKDIR /app
COPY --from=build /usr/src/app .

ENV PORT=7777
EXPOSE ${PORT}
STOPSIGNAL SIGINT
ENTRYPOINT [ "node", "server.js" ]

HEALTHCHECK --interval=30s --timeout=5s --start-period=5s \
    --retries=1 CMD curl -sS -o /dev/null localhost:${PORT} || exit 1

CMD [ "npm", "start" ]
