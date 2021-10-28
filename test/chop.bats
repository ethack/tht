setup() {
    load 'helper/bats-support/load'
    load 'helper/bats-assert/load'
}

HERE_BE_A_TAB='	' # use for copy-pasting when needed

# wrap chop in a function to avoid "bash -c ''" pattern
# https://bats-core.readthedocs.io/en/stable/gotchas.html#my-piped-command-does-not-work-under-run
chop() {
    local input="$1"
    shift
    $input | command chop "$@"
}

# Input Helpers #

zeek() {
    cat <<-EOF
	#separator \x09
	#set_separator	,
	#empty_field	(empty)
	#unset_field	-
	#fields	ts	uid	id.orig_h	id.orig_p	id.resp_h	id.resp_p	proto	service	duration	orig_bytes	resp_bytes	conn_state	local_orig	local_resp	missed_bytes	history	orig_pkts	orig_ip_bytes	resp_pkts	resp_ip_bytes	tunnel_parents
	#types	time	string	addr	port	addr	port	enum	string	interval	count	count	string	bool	bool	count	string	count	count	count	count	set[string]
	1517336042.090842	CW32gzposD5TUDUB	10.55.182.100	14291	10.233.233.5	80	tcp	-	3.000158	0	0	S0	-	-	0	S	2	104	0	0	-
	1517336042.279652	ComPBK1vso3uDC8KS2	192.168.88.2	55638	165.227.88.15	53	udp	dns	0.069982	61	81	SF	-	-	0	Dd	1	89	1	109	-
	EOF
}

json() {
    cat <<-EOF
	{"ts":1517336042.090842,"uid":"COwvHe36w8UnD8GXq5","id.orig_h":"10.55.182.100","id.orig_p":14291,"id.resp_h":"10.233.233.5","id.resp_p":80,"proto":"tcp","duration":3.0001580715179443,"orig_bytes":0,"resp_bytes":0,"conn_state":"S0","missed_bytes":0,"history":"S","orig_pkts":2,"orig_ip_bytes":104,"resp_pkts":0,"resp_ip_bytes":0}
	{"ts":1517336042.279652,"uid":"Cg2Xy9r27l6Z2iQ3h","id.orig_h":"192.168.88.2","id.orig_p":55638,"id.resp_h":"165.227.88.15","id.resp_p":53,"proto":"udp","service":"dns","duration":0.06998181343078613,"orig_bytes":61,"resp_bytes":81,"conn_state":"SF","missed_bytes":0,"history":"Dd","orig_pkts":1,"orig_ip_bytes":89,"resp_pkts":1,"resp_ip_bytes":109}
	EOF
}

csv_header() {
    { echo "alpha,bravo,charlie,delta,echo"; csv; }
}

csv() {
    cat <<-EOF
	do,re,mi,fa,so
    one,two,three,four,five
	EOF
}

tsv_header() {
    { echo "alpha	bravo	charlie	delta	echo"; tsv; }
}

tsv() {
    cat <<-EOF
	do	re	mi	fa	so
    one	two	three	four	five
	EOF
}

whitespace_header() {
    { echo "alpha  bravo  charlie  delta  echo"; whitespace; }
}

whitespace() {
    cat <<-EOF
	do  re  mi  fa  so
    one  two  three  four  five
	EOF
}

pipe_header() {
    { echo "alpha|bravo|charlie|delta|echo"; pipe; }
}

pipe() {
    cat <<-EOF
	do|re|mi|fa|so
    one|two|three|four|five
	EOF
}

empty() {
    echo
}

# Tests #
@test "no arguments should print help" {
    command chop | grep -q 'Usage:'
}

## Zeek ##
@test "zeek, name" {
    run chop zeek id.orig_h id.resp_h
    # TODO: figure out a better way to format expected output
    assert_output "\
10.55.182.100	10.233.233.5
192.168.88.2	165.227.88.15"
}

@test "zeek, name, retain header" {
    run chop zeek -H id.orig_h id.resp_h
    assert_output "\
id.orig_h	id.resp_h
10.55.182.100	10.233.233.5
192.168.88.2	165.227.88.15"
}

@test "zeek, index" {
    run chop zeek 3 5
    assert_output "\
id.orig_h	id.resp_h
10.55.182.100	10.233.233.5
192.168.88.2	165.227.88.15"
}

@test "zeek, index, retain header" {
    run chop zeek -H 3 5
    assert_output "\
id.orig_h	id.resp_h
10.55.182.100	10.233.233.5
192.168.88.2	165.227.88.15"
}

## JSON ##
@test "json, name" {
    run chop json id.orig_h id.resp_h
    assert_output "\
10.55.182.100	10.233.233.5
192.168.88.2	165.227.88.15"
}

@test "json, name, retain header" {
    run chop json -H id.orig_h id.resp_h
    # BUG: no header available in JSON output
    assert_output "\
10.55.182.100	10.233.233.5
192.168.88.2	165.227.88.15"
}

## CSV ##
@test "csv, header, name" {
    run chop csv_header bravo echo
    assert_output "\
re	so
two	five"
}

@test "csv, header, name, retain header" {
    run chop csv_header -H bravo echo
    assert_output "\
bravo	echo
re	so
two	five"
}

@test "csv, header, index" {
    run chop csv_header 2 5
    assert_output "\
bravo	echo
re	so
two	five"
}

@test "csv, no header, index" {
    run chop csv 2 5
    assert_output "\
re	so
two	five"
}

## TSV ##
@test "tsv, header, name" {
    run chop tsv_header bravo echo
    assert_output "\
re	so
two	five"
}

@test "tsv, header, name, retain header" {
    run chop tsv_header -H bravo echo
    assert_output "\
bravo	echo
re	so
two	five"
}

@test "tsv, header, index" {
    run chop tsv_header 2 5
    assert_output "\
bravo	echo
re	so
two	five"
}

@test "tsv, no header, index" {
    run chop tsv 2 5
    assert_output "\
re	so
two	five"
}

## Whitespace ##
@test "whitespace, header, name" {
    run chop whitespace_header bravo echo
    assert_output "\
re	so
two	five"
}

@test "whitespace, header, name, retain header" {
    run chop whitespace_header -H bravo echo
    assert_output "\
bravo	echo
re	so
two	five"
}

@test "whitespace, header, index" {
    run chop whitespace_header 2 5
    assert_output "\
bravo	echo
re	so
two	five"
}

@test "whitespace, no header, index" {
    run chop whitespace 2 5
    assert_output "\
re	so
two	five"
}

## Custom Delimeter ##
@test "pipe, header, name" {
    run chop pipe_header -d '|' bravo echo
    assert_output "\
re	so
two	five"
}

@test "pipe, header, name, retain header" {
    run chop pipe_header -d '|' -H bravo echo
    assert_output "\
bravo	echo
re	so
two	five"
}

@test "pipe, header, index" {
    run chop pipe_header -d '|' 2 5
    assert_output "\
bravo	echo
re	so
two	five"
}

@test "pipe, no header, index" {
    run chop pipe -d '|' 2 5
    assert_output "\
re	so
two	five"
}

## Empty
@test "empty" {
    run chop empty doesnotexist
    assert_failure
}