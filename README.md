# Local SchulCloud Setup

Scripts for a local deployment of the [SchulCloud](https://github.com/hpi-schul-cloud/schulcloud-server).

## Steps for a local setup

1. `scripts/01-sync-schulcloud-repos.sh` — sync `schulcloud-server`, `nuxt-client`, and `schulcloud-client` into `repos/`
2. `scripts/02-install-schulcloud-node-deps.sh` — run `npm ci` in each repo
3. `scripts/03-start-mongodb.sh` — start MongoDB via Docker
4. `scripts/04-start-rabbitmq.sh` — start RabbitMQ via Docker
