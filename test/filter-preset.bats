setup() {
	load 'helper/bats-support/load'
	load 'helper/bats-assert/load'
}

## Preset Regexes ##
@test "preset rfc1918" {
	scenario() {
	cat <<-EOF | filter --preset rfc1918
		0.0.0.0
		192.167.0.0
		192.168.0.0
		192.168.1.1
		192.168.255.255
		192.169.255.255
		10.0.0.0
		10.1.1.1
		10.255.255.255
		172.16.0.0
		172.17.0.0
		172.18.0.0
		172.19.0.0
		172.20.0.0
		172.21.0.0
		172.22.0.0
		172.23.0.0
		172.24.0.0
		172.25.0.0
		172.26.0.0
		172.27.0.0
		172.28.0.0
		172.29.0.0
		172.30.0.0
		172.31.0.0
		172.31.255.255
		172.32.0.0
		255.255.255.255
		ignore
		100.0.0.0
		1.0.0.0
		1.1.1.1
		127.0.0.1
	EOF
	}
	run scenario
	cat <<-EOF | assert_output -
		192.168.0.0
		192.168.1.1
		192.168.255.255
		10.0.0.0
		10.1.1.1
		10.255.255.255
		172.16.0.0
		172.17.0.0
		172.18.0.0
		172.19.0.0
		172.20.0.0
		172.21.0.0
		172.22.0.0
		172.23.0.0
		172.24.0.0
		172.25.0.0
		172.26.0.0
		172.27.0.0
		172.28.0.0
		172.29.0.0
		172.30.0.0
		172.31.0.0
		172.31.255.255
	EOF
}

@test "preset ipv4" {
	scenario() {
	cat <<-EOF | filter --preset ipv4
		ignore
		...
		1.1.1.1
		1.1.1
		1.a.1.a
		0.0.0.0
		127.0.0.1
		255.255.255.255
		255.255.255.256
		1234.1.1.1
		11.11.11.11
		111.111.111.111
		999.999.999.999
	EOF
	}
	run scenario
	cat <<-EOF | assert_output -
		1.1.1.1
		0.0.0.0
		127.0.0.1
		255.255.255.255
		11.11.11.11
		111.111.111.111
	EOF
}

@test "preset ipv6" {
	scenario() {
	cat <<-EOF | filter --preset ipv6
		1:2:3:4:5:6:7:8
		1:2:3:4:5:6:7::
		1:2:3:4:5:6::8
		1:2:3:4:5::7:8
		1:2:3:4:5::8
		1:2:3:4::6:7:8
		1:2:3:4::8
		1:2:3::5:6:7:8
		1:2:3::8
		1:2::4:5:6:7:8
		1:2::8
		1::
		1::3:4:5:6:7:8
		1::4:5:6:7:8
		1::5:6:7:8
		1::6:7:8
		1::7:8
		1::8
		64:ff9b::192.0.2.33
		2001:db8:3:4::192.0.2.33
		fe80::7:8%1
		fe80::7:8%eth0
		::
		::2:3:4:5:6:7:8
		::8
		::255.255.255.255
		::ffff:0:255.255.255.255
		::ffff:255.255.255.255
		ignore
		192.168.1.1
	EOF
	}
	run scenario
	cat <<-EOF | assert_output -
		1:2:3:4:5:6:7:8
		1:2:3:4:5:6::8
		1:2:3:4:5::7:8
		1:2:3:4:5::8
		1:2:3:4::6:7:8
		1:2:3:4::8
		1:2:3::5:6:7:8
		1:2:3::8
		1:2::4:5:6:7:8
		1:2::8
		1::3:4:5:6:7:8
		1::4:5:6:7:8
		1::5:6:7:8
		1::6:7:8
		1::7:8
		1::8
		64:ff9b::192.0.2.33
		2001:db8:3:4::192.0.2.33
		fe80::7:8%1
		fe80::7:8%eth0
	EOF
	#TODO
	cat <<-MISSING
		1:2:3:4:5:6:7::
		1::
		::
		::2:3:4:5:6:7:8
		::8
		::255.255.255.255
		::ffff:0:255.255.255.255
		::ffff:255.255.255.255
	MISSING
}

@test "preset linklocal" {
	scenario() {
	cat <<-EOF | filter --preset linklocal
		169.253.255.255
		169.254.0.0
		169.254.169.254
		169.254.255.255
		169.255.0.0
		169.255.255.255
		ignore
		ffe80::0
		ffe80::1
		ffe80::1:1
		ffe80::1:1:1
		ffe80::1:1:1:1
		ffe80::1:1:1:1:1
		ffe80::1:1:1:1:1:1
		ffe80:1:1:1:1:1:1:1
		ffe80:ffff:ffff:ffff:ffff:ffff:ffff:ffff
	EOF
	}
	run scenario
	cat <<-EOF | assert_output -
		169.254.0.0
		169.254.169.254
		169.254.255.255
		ffe80::0
		ffe80::1
		ffe80::1:1
		ffe80::1:1:1
		ffe80::1:1:1:1
		ffe80::1:1:1:1:1
		ffe80::1:1:1:1:1:1
		ffe80:1:1:1:1:1:1:1
		ffe80:ffff:ffff:ffff:ffff:ffff:ffff:ffff
	EOF
}