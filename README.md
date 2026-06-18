# Local SchulCloud Setup

Scripts for a local deployment of the [SchulCloud](https://github.com/hpi-schul-cloud/schulcloud-server).

## Steps for a local setup

1. `scripts/01-sync-schulcloud-repos.sh` — sync `schulcloud-server`, `nuxt-client`, and `schulcloud-client` into `repos/`
2. `scripts/02-install-schulcloud-node-deps.sh` — run `npm ci` in each repo
3. `scripts/03-start-mongodb.sh` — start MongoDB via Docker
4. `scripts/04-start-rabbitmq.sh` — start RabbitMQ via Docker
5. `scripts/05-seed-mongodb.sh` — seed the MongoDB by running `npm run setup:db:seed` in `schulcloud-server`
6. `scripts/06-start-backend.sh` — start the backend with `npm run nest:start:dev` in `schulcloud-server`
7. `scripts/07-install-nodemon.sh` — install `nodemon` globally for the legacy client
8. `scripts/08-build-and-watch-schulcloud-client.sh` — run `npm run build` and then `npm run watch` in `schulcloud-client`
