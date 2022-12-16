#!/bin/bash

# run tests in interactive mode for better output
tht --dev -- /usr/local/test/bats/bin/bats /usr/local/test

# run tests in non-interactive mode to simulate github actions environment
# tht --dev -c "/usr/local/test/bats/bin/bats /usr/local/test"