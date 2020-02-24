# Gatekeeper

[![Build Status](https://travis-ci.org/sanger/gatekeeper.svg?branch=develop)](https://travis-ci.org/sanger/gatekeeper)

Gatekeeper is used to track the production and validation of batches of tag plates for Sequencing. It is designed to interface with the LIMS [Sequencescape](https://github.com/sanger/sequencescape).

Installation
------------

1. Install gems

        bundle install

1. Setup config

        rake config:generate

1. Start Sequencescape server

        # move to Sequencescape directory
        rails s

1. start Gatekeeper server on a different port (e.g. 3001)

        # move back to Gatekeeper directory
        rails s -p 3001
