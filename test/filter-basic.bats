setup() {
	load 'helper/bats-support/load'
	load 'helper/bats-assert/load'
	load 'helper/bats-file/load'
}

@test "literal string" {
	scenario() {
	cat <<-EOF | filter three
		one two three
		four five six
	EOF
	}
	run scenario
	assert_output "one two three"
}

@test "inverted literal string" {
	scenario() {
	cat <<-EOF | filter --invert-match three
		one two three
		four five six
	EOF
	}
	run scenario
	assert_output "four five six"
}

@test "string with dot" {
	scenario() {
	cat <<-EOF | filter google.com
		google.com
		googlescom
	EOF
	}
	run scenario
	assert_output "google.com"
}

@test "string with space" {
	scenario() {
	cat <<-EOF | filter "User Agent"
		User Agent
		User
		Agent
	EOF
	}
	run scenario
	assert_output "User Agent"
}

# TODO there is still a problem when combining quotes and word boundaries
# @test "string with quote" {
# 	scenario() {
# 		cat <<-EOF | filter '"evil"'
# 		"evil"
# 		evil
# 		EOF
# 	}
# 	run scenario
# 	assert_output "\
# \"evil\""
# }

@test "multiple strings" {
	scenario() {
	cat <<-EOF | filter one two three
		one
		two
		three
		four
		one two three
		one two three four
	EOF
	}
	run scenario
	cat <<-EOF | assert_output -
		one two three
		one two three four
	EOF
}

@test "inverted multiple strings" {
	scenario() {
	cat <<-EOF | filter --invert-match one two three
		one
		two
		three
		four
		one two three
		one two three four
	EOF
	}
	run scenario
	cat <<-EOF | assert_output -
		one
		two
		three
		four
	EOF
}

@test "or multiple strings" {
	scenario() {
	cat <<-EOF | filter --or one two three
		one
		two
		three
		four
		one two three
		one two three four
	EOF
	}
	run scenario
	cat <<-EOF | assert_output -
		one
		two
		three
		one two three
		one two three four
	EOF
}

@test "inverted or multiple strings" {
	scenario() {
	cat <<-EOF | filter --invert-match --or one two three
		one
		two
		three
		four
		one two three
		one two three four
	EOF
	}
	run scenario
	cat <<-EOF | assert_output -
		four
	EOF
}

@test "regex" {
	scenario() {
	cat <<-EOF | filter --regex 'admin.*\.corp'
		adminicorp
		admin.corp
		admin1.corp
		admin2.corp
		administrator.corp
		sales.corp
	EOF
	}
	run scenario
	cat <<-EOF | assert_output -
		admin.corp
		admin1.corp
		admin2.corp
		administrator.corp
	EOF
}

@test "multiple regexes" {
	scenario() {
	cat <<-EOF | filter --regex '192\.168\.\d*\.1' '(macOS|iPad|iPhone)'
		192.168.2.1 macOS 
		192.168.2.1 Windows
		192.168.2.2 iPad
		192.168.3.1 iPhone
		192.168.3.1 Linux
		192.168.3.3 macOS
	EOF
	}
	run scenario
	cat <<-EOF | assert_output -
		192.168.2.1 macOS 
		192.168.3.1 iPhone
	EOF
}

@test "or multiple regexes" {
	scenario() {
	cat <<-EOF | filter --or --regex 'admin.*\.corp' 'it.*\.corp'
		admin.corp
		admin1.corp
		admin2.corp
		it.corp
		it1.corp
		it2.corp
		sales.corp
	EOF
	}
	run scenario
	cat <<-EOF | assert_output -
		admin.corp
		admin1.corp
		admin2.corp
		it.corp
		it1.corp
		it2.corp
	EOF
}

@test "starts with" {
	scenario() {
	cat <<-EOF | filter --starts-with 10.10
		"192.168.10.10"
		"1.10.10.1"
		"10.100.0.0"
		"10.10.1.2"
	EOF
	}
	run scenario
	cat <<-EOF | assert_output -
		"10.10.1.2"
	EOF
}

@test "ends with" {
	scenario() {
	cat <<-EOF | filter --ends-with 10.10
		"192.168.10.10"
		"1.10.10.1"
		"10.100.0.0"
		"10.10.1.2"
	EOF
	}
	run scenario
	cat <<-EOF | assert_output -
		"192.168.10.10"
	EOF
}

@test "no arguments" {
	scenario() {
	cat <<-EOF | filter
		one
		two
		three
	EOF
	}
	run scenario
	cat <<-EOF | assert_output -
		one
		two
		three
	EOF
}

# TODO: not finding the file in CICD with temp_make
# @test "file input->no arguments" {
# 	local temp_dir=$(temp_make)
# 	cat <<-EOF > "$temp_dir/conn.log"
# 		one
# 		two
# 		three
# 	EOF
# 	assert_file_exist "$temp_dir/conn.log"
	
# 	scenario_dry_run() {
# 		cd "$temp_dir"
# 		filter --dry-run
# 	}
# 	run scenario_dry_run
# 	assert_output --partial 'conn.log'
	
# 	scenario() {
# 		cd "$temp_dir"
# 		filter
# 	}
# 	run scenario 
# 	cat <<-EOF | assert_output -
# 		one
# 		two
# 		three
# 	EOF
# 	temp_del "$temp_dir"
# }

@test "empty string argument" {
	scenario() {
	cat <<-EOF | filter ""
		one
		two
		three
	EOF
	}
	run scenario
	assert_output ""
}

@test "pattern file" {
	scenario() {
	cat <<-EOF | filter --or --file <(printf 'one\ntwo\nthree')
		one
		two
		three
		four
		five
	EOF
	}
	run scenario
	cat <<-EOF | assert_output -
		one
		two
		three
	EOF
}

@test "pattern file with empty line" {
	scenario() {
	cat <<-EOF | filter --or --file <(printf 'one\n\ntwo\nthree')
		one
		two
		three
		four
		five
	EOF
	}
	run scenario
	cat <<-EOF | assert_output -
		one
		two
		three
	EOF
}

@test "empty pattern file" {
	scenario() {
	cat <<-EOF | filter --or --file <(printf '')
		one
		two
		three
		four
		five
	EOF
	}
	run scenario
	# acts the same as if you passed no arguments (i.e. cat)
	cat <<-EOF | assert_output -
		one
		two
		three
		four
		five
	EOF
}

@test "case-insensitive matching" {
	scenario() {
	cat <<-EOF | filter -i example
		example
		eXaMpLe
		EXAMPLE
		ignore
	EOF
	}
	run scenario
	cat <<-EOF | assert_output -
		example
		eXaMpLe
		EXAMPLE
	EOF
}

@test "only matching" {
	scenario() {
	cat <<-EOF | filter -o two
		one two three
	EOF
	}
	run scenario
	cat <<-EOF | assert_output -
		two
	EOF
}

# TODO: not finding the file in CICD with temp_make
# @test "files with matches" {
# 	local temp_dir=$(temp_make)
# 	cat <<-EOF > "$temp_dir/conn.1.log"
# 		one
# 		all
# 	EOF
# 	assert_file_exist "$temp_dir/conn.1.log"
# 	cat <<-EOF > "$temp_dir/conn.2.log"
# 		two
# 		all
# 	EOF
# 	assert_file_exist "$temp_dir/conn.2.log"
	
# 	scenario_one() {
# 		cd "$temp_dir"
# 		filter -l one
# 	}
# 	run scenario_one
# 	assert_output './conn.1.log'

# 	scenario_two() {
# 		cd "$temp_dir"
# 		filter -l two
# 	}
# 	run scenario_two
# 	assert_output './conn.2.log'
	
# 	scenario_all() {
# 		cd "$temp_dir"
# 		filter -l all | sort
# 	}
# 	run scenario_all
# 	cat <<-EOF | assert_output -
# 		./conn.1.log
# 		./conn.2.log
# 	EOF

# 	temp_del "$temp_dir"
# }