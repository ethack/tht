#!/bin/bash

# tht --dev run <<\EOF
# #echo /usr/local/test/*.bats /usr/local/bin/* | entr /usr/local/test/bats/bin/bats /usr/local/test
# /usr/local/test/bats/bin/bats /usr/local/test
# EOF

# tht --dev -- 'echo /usr/local/test/*.bats | entr /usr/local/test/bats/bin/bats /usr/local/test'

# tht --dev -- /usr/local/test/bats/bin/bats /usr/local/test
tht --dev -c "/usr/local/test/bats/bin/bats /usr/local/test"