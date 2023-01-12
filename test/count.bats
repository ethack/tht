setup() {
	load 'helper/bats-support/load'
	load 'helper/bats-assert/load'
	load 'helper/bats-file/load'
}

# Input Helpers #

headers() {
	cat <<-EOF
	#separator \x09
	#set_separator	,
	#empty_field	(empty)
	#unset_field	-
	#fields	ts	uid	id.orig_h	id.orig_p	id.resp_h	id.resp_p	proto	service	duration	orig_bytes	resp_bytes	conn_state	local_orig	local_resp	missed_bytes	history	orig_pkts	orig_ip_bytes	resp_pkts	resp_ip_bytes	tunnel_parents
	#types	time	string	addr	port	addr	port	enum	string	interval	count	count	string	bool	bool	count	string	count	count	count	count	set[string]
	EOF
}

# Tests #
@test "no arguments should ignore headers" {
	scenario() {
		{ headers; seq 20; } | count
	}
	run scenario
	assert_output 20

	scenario() {
		seq 20 | count
	}
	run scenario
	assert_output 20
}

@test "headers flag should count all lines" {
	scenario() {
		{ headers; seq 20; } | count --headers
		{ headers; seq 20; } | count --header
		{ headers; seq 20; } | count -H
		{ headers; seq 20; } | count --all
		
		seq 20 | count --headers
	}
	run scenario
	assert_output <<-EOF
		26
		26
		26
		26
		20
	EOF
}

@test "empty input should return 0" {
	scenario() {
		echo -n | count
	}
	run scenario
	assert_output 0

	scenario() {
		echo -n | count -H
	}
	run scenario
	assert_output 0
}

@test "count lines in files" {
	cd "$BATS_TEST_TMPDIR"
	
	{ headers; seq 10; } > conn.1.log
	assert_file_exist conn.1.log
	{ headers; seq 20; } > conn.2.log
	assert_file_exist conn.2.log
	
	run count conn.1.log
	assert_output 10

	run count conn.1.log conn.2.log
	assert_output <<-EOF
		conn.1.log:10
		conn.2.log:20
	EOF

	run count -H conn.2.log
	assert_output "26 conn.2.log"
	
	run count -H conn.1.log conn.2.log
	assert_output <<-EOF
		16 conn.1.log
		26 conn.2.log
		42 total
	EOF
}