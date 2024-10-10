# Gatekeeper

[![Build Status](https://travis-ci.org/sanger/gatekeeper.svg?branch=develop)](https://travis-ci.org/sanger/gatekeeper)

Gatekeeper is used to track the production and validation of batches of tag plates for sequencing.
It is designed to interface with the [Sequencescape](https://github.com/sanger/sequencescape) LIMS.

## Installation

1. Install gems

        bundle install

## Setup


1. Start Sequencescape server on port 3000

        # move to Sequencescape directory
        bundle exec rails server


2. Setup config

        # This runs `lib/tasks/config.rake` which creates an file in the `environments` directory
        bundle exec rake config:generate

3. Start Gatekeeper server on a different port (e.g. 3001)

        bundle exec rails server -p 3001

## Testing

To run tests:

    bundle exec rake

## Yard

To run the Yard server

    bundle exec yard server
