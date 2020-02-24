# Gatekeeper

[![Build Status](https://travis-ci.org/sanger/gatekeeper.svg?branch=develop)](https://travis-ci.org/sanger/gatekeeper)

Gatekeeper is used to track the production and validation of batches of tag plates for sequencing.
It is designed to interface with the [Sequencescape](https://github.com/sanger/sequencescape) LIMS.

## Installation

1. Install gems

        bundle install

## Setup

1. Setup config

        bundle exec rake config:generate

1. Start Sequencescape server

        # move to Sequencescape directory
        bundle exec rails server

1. start Gatekeeper server on a different port (e.g. 3001)

        # move back to Gatekeeper directory
        bundle exec rails server -p 3001

## Testing

To run tests:

    bundle exec rake

## Yard

To run the Yard server

    bundle exec yard server
