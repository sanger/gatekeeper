[![Ruby Tests](https://github.com/sanger/gatekeeper/actions/workflows/ruby_test.yml/badge.svg)](https://github.com/sanger/gatekeeper/actions/workflows/ruby_test.yml)
[![codecov](https://codecov.io/gh/sanger/gatekeeper/graph/badge.svg?token=VbxDtCNFAh)](https://codecov.io/gh/sanger/gatekeeper)

# <img src="public/images/gate-kk.svg" alt="Reflected K Logo" height="20pt" /> Gatekeeper

Gatekeeper is used to track the production and validation of batches of tag plates for sequencing.
It is designed to interface with the [Sequencescape](https://github.com/sanger/sequencescape) LIMS.

## Installation

1.  Install gems

        bundle install

## Setup

1.  Start Sequencescape server on port 3000

        # move to Sequencescape directory
        bundle exec rails server

2.  Setup config

        # This runs `lib/tasks/config.rake` which creates an file in the `environments` directory
        bundle exec rake config:generate

3.  Start Gatekeeper server on a different port (e.g. 3001)

        bundle exec rails server -p 3001

## Testing

To run unit tests:

    bundle exec rake

To run feature tests:

    bundle exec rspec spec

## Yard

To run the Yard server

    bundle exec yard server
