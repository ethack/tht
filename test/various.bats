setup() {
	load 'helper/bats-support/load'
	load 'helper/bats-assert/load'
}

# first
@test "first, default" {
    scenario() {
        seq 100 | shuf | first
    }
    run scenario
    assert_output 1
}

@test "first, custom argument" {
    scenario() {
        seq 100 | shuf | first 3
    }
    run scenario
    seq 3 | assert_output -
}

# last
@test "last, default" {
    scenario() {
        seq 100 | shuf | last
    }
    run scenario
    assert_output 100
}

@test "last, custom argument" {
        scenario() {
        seq 100 | shuf | last 12
    }
    run scenario
    seq 89 100 | assert_output -
}

# skip
@test "skip, default" {
    scenario() {
        seq 100 | command skip
    }
    run scenario
    seq 2 100 | assert_output -
}

@test "skip, custom argument" {
    scenario() {
        seq 10 | command skip 9
    }
    run scenario
    assert_output 10
}

# card
@test "card, base" {
    scenario() {
        seq 10 | card
    }
    run scenario
    assert_output 10
}

@test "card, overlapping" {
    scenario() {
        { seq 1 10; seq 3 13; } | card
    }
    run scenario
    assert_output 13
}

@test "card, disjoint" {
    scenario() {
        { seq 1 10; seq 11 20; } | card
    }
    run scenario
    assert_output 20
}

# domain
@test "domain, default" {
    scenario() {
        echo 1.2.3.example.com | domain
    }
    run scenario
    assert_output example.com
}

@test "domain, custom levels" {
    scenario() {
        echo 1.2.3.example.com | domain 3
    }
    run scenario
    assert_output 3.example.com

    scenario() {
        echo 1.2.3.example.com | domain 4
    }
    run scenario
    assert_output 2.3.example.com

    scenario() {
        echo 1.2.3.example.com | domain 1
    }
    run scenario
    assert_output com
}

@test "domain, multiple domains" {
    scenario() {
        { echo 1.2.3.example.com; echo 4.5.6.example.com; } | domain 3
    }
    run scenario
    { echo 3.example.com; echo 6.example.com; } | assert_output -
}

# TODO: 
# cidr2ip
# cols
# distinct
# freq
# headers
# ip2cidr
# ipcount
# ipdiff
# ipdiffs
# ipintersect
# ipunion
# lfo
# mfo
# setdiff
# setintersect
# setunion
# ts2

