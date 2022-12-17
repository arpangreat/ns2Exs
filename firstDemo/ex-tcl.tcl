proc test {} {
	set a 23
	set b 43

	set c [expr $a + $b]

	set d [expr [expr $a - $b] * $c]

	for {set k 0} {$k < 10} {incr c} {
		if {$k < 5} {
			puts "k < 5, pow"
		} else {
			puts "k < 10, mod = [expr $d % $k]"
		}
	}
}

test
