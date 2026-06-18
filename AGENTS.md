# Agents Guide

This repository contains the local setup tooling for SchulCloud. Its purpose is to help developers provision, configure, start, stop, reset, and troubleshoot a local SchulCloud development environment by using the scripts in `scripts/`.

## Project Goal

Make it possible for developers to set up SchulCloud locally with minimal manual steps. The repository should document:

- which prerequisites are required,
- which setup scripts must be executed,
- what each script does,
- how to start and stop the local environment,
- how to reset or clean up the setup,
- and how to troubleshoot common setup issues.

## Script Guidelines

All setup scripts should live in `scripts/` and should be safe, readable, and repeatable where possible.

Recommended conventions:

- Use descriptive file names, for example:
  - `scripts/check-prerequisites.sh`
  - `scripts/install-dependencies.sh`
  - `scripts/setup.sh`
  - `scripts/start.sh`
  - `scripts/stop.sh`
  - `scripts/reset.sh`
  - `scripts/clean.sh`
- Prefer Bash for shell scripts.
- Start Bash scripts with:

  ```bash
  #!/usr/bin/env bash
  set -euo pipefail
  ```

- Print clear progress messages.
- Fail with actionable error messages.
- Avoid hard-coded user-specific paths.
- Make scripts idempotent whenever possible.
- Document required environment variables in the README.
- Do not commit secrets, tokens, local credentials, or generated private configuration.

## Expected Script Responsibilities

The concrete scripts may evolve, but the local setup should generally cover the following tasks:

### Prerequisite Check

A script should verify required tools before setup starts, for example Docker, Docker Compose, Git, Node.js, package managers, or other SchulCloud-specific dependencies.

### Dependency Installation

A script may install or prepare dependencies needed by the local environment. If dependencies cannot be installed automatically, the script should explain the manual steps.

### Initial Setup

A setup script should prepare the local environment, create required configuration files from templates, initialize services, and make the project ready to run.

### Start and Stop

Start and stop scripts should provide a simple entry point for developers to run or shut down the local SchulCloud environment.

### Reset and Cleanup

Reset or cleanup scripts should make it easy to remove generated state, containers, volumes, caches, or temporary files. Destructive scripts must clearly warn users before deleting data.

## README Expectations

The README should be written for developers who want to set up SchulCloud locally for the first time. It should explain the local setup process step by step.

Recommended README structure:

1. **Project Overview**
   - Explain that this repository contains local setup scripts for SchulCloud.

2. **Prerequisites**
   - List required tools and supported versions.
   - Mention operating system assumptions if relevant.

3. **Quick Start**
   - Provide the shortest successful path from a fresh checkout to a running local SchulCloud environment.

4. **Scripts**
   - Document every script in `scripts/`.
   - For each script, include:
     - purpose,
     - command to run,
     - required environment variables,
     - side effects,
     - whether it is safe to run multiple times.

5. **Configuration**
   - Explain local configuration files, templates, and environment variables.
   - Clearly mark which files are generated and which files should not be committed.

6. **Development Workflow**
   - Explain how to start, stop, restart, reset, and update the local environment.

7. **Troubleshooting**
   - Document common problems and fixes.
   - Include useful diagnostic commands.

8. **Cleanup**
   - Explain how to remove generated resources and return to a clean state.

## Contribution Guidelines for Agents

When modifying this repository:

- Keep setup instructions beginner-friendly and explicit.
- Prefer automation over manual steps, but document manual steps when automation is not safe or practical.
- Update the README whenever scripts are added, removed, or changed.
- Keep script names and README commands in sync.
- Do not introduce project-specific assumptions without documenting them.
- Do not commit generated files, local environment files, secrets, or machine-specific configuration.
- Test scripts from a clean checkout whenever possible.

## Validation Checklist

Before considering setup changes complete, verify:

- scripts are executable where appropriate,
- scripts fail clearly when prerequisites are missing,
- README commands match actual script paths,
- setup can be followed by a developer without hidden knowledge,
- cleanup/reset behavior is documented,
- no secrets or generated local files are committed.
