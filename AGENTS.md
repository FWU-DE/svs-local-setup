# AGENTS.md

This repository provides scripts and documentation for setting up SchulCloud locally.

## Scope

Work in this repository should focus on the local SchulCloud setup only:

- setup automation in `scripts/`
- documentation for running the setup locally
- commands for starting, stopping, resetting, and cleaning the local environment
- troubleshooting information specific to the local SchulCloud setup

## Scripts

The `scripts/` directory should contain the commands developers use for the local setup.

Script file names must be prefixed with a two-digit number so the execution order is clear:

```text
scripts/01-check-prerequisites.sh
scripts/02-prepare-configuration.sh
...
```

When adding or changing scripts, make sure each script has a clear purpose and is documented in the README.

## README Requirements

The README should be the main entry point for developers who want to set up SchulCloud locally.

It should include:

- required tools and versions
- initial setup steps
- the command sequence for a fresh local setup
- a list of numbered scripts in `scripts/` with their purpose and execution order
- required environment variables or local configuration files
- start, stop, reset, and cleanup instructions
- troubleshooting for known local setup problems

Keep README commands in sync with the actual scripts.

## Agent Instructions

- keep changes focused on the local SchulCloud setup
- place setup automation in `scripts/`
- update the README when script behavior changes
