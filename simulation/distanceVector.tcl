# Initialize the simulation
set ns [new Simulator]
set tracefile [open out.tr w]
$ns trace-all $tracefile

# Define nodes (routers)
set A [$ns node]
set B [$ns node]
set C [$ns node]
set D [$ns node]

# Create a duplex link between each pair of connected nodes with weights (link costs)
$ns duplex-link $A $B 1Mb 10ms DropTail
$ns duplex-link $A $C 4Mb 10ms DropTail
$ns duplex-link $B $C 2Mb 10ms DropTail
$ns duplex-link $C $D 3Mb 10ms DropTail

# Initialize distance vectors for each node (router)
set dist_A {A 0 B 1 C 4 D inf}
set dist_B {A 1 B 0 C 2 D inf}
set dist_C {A 4 B 2 C 0 D 3}
set dist_D {A inf B inf C 3 D 0}

# Procedure to simulate the distance vector algorithm
proc distance_vector_routing {} {
    global dist_A dist_B dist_C dist_D

    # Step 1: Routers exchange distance vectors
    puts "Exchanging distance vectors..."

    # Update A's distance vector based on B and C's vectors
    set new_dist_A {}
    foreach {node dist} $dist_A {
        if { $node == "A" } {
            lappend new_dist_A "A" 0
        } elseif { $node == "B" } {
            lappend new_dist_A "B" [expr {min([lindex $dist_B 1] + 1, [lindex $dist_A 1])}]
        } elseif { $node == "C" } {
            lappend new_dist_A "C" [expr {min([lindex $dist_C 1] + 4, [lindex $dist_A 1])}]
        } elseif { $node == "D" } {
            lappend new_dist_A "D" [expr {min([lindex $dist_D 1] + inf, [lindex $dist_A 1])}]
        }
    }
    set dist_A $new_dist_A

    # Repeat the process for B, C, and D
    set new_dist_B {}
    foreach {node dist} $dist_B {
        if { $node == "B" } {
            lappend new_dist_B "B" 0
        } elseif { $node == "A" } {
            lappend new_dist_B "A" [expr {min([lindex $dist_A 1] + 1, [lindex $dist_B 1])}]
        } elseif { $node == "C" } {
            lappend new_dist_B "C" [expr {min([lindex $dist_C 1] + 2, [lindex $dist_B 1])}]
        } elseif { $node == "D" } {
            lappend new_dist_B "D" [expr {min([lindex $dist_D 1] + inf, [lindex $dist_B 1])}]
        }
    }
    set dist_B $new_dist_B

    set new_dist_C {}
    foreach {node dist} $dist_C {
        if { $node == "C" } {
            lappend new_dist_C "C" 0
        } elseif { $node == "A" } {
            lappend new_dist_C "A" [expr {min([lindex $dist_A 1] + 4, [lindex $dist_C 1])}]
        } elseif { $node == "B" } {
            lappend new_dist_C "B" [expr {min([lindex $dist_B 1] + 2, [lindex $dist_C 1])}]
        } elseif { $node == "D" } {
            lappend new_dist_C "D" [expr {min([lindex $dist_D 1] + 3, [lindex $dist_C 1])}]
        }
    }
    set dist_C $new_dist_C

    set new_dist_D {}
    foreach {node dist} $dist_D {
        if { $node == "D" } {
            lappend new_dist_D "D" 0
        } elseif { $node == "A" } {
            lappend new_dist_D "A" [expr {min([lindex $dist_A 1] + inf, [lindex $dist_D 1])}]
        } elseif { $node == "B" } {
            lappend new_dist_D "B" [expr {min([lindex $dist_B 1] + inf, [lindex $dist_D 1])}]
        } elseif { $node == "C" } {
            lappend new_dist_D "C" [expr {min([lindex $dist_C 1] + 3, [lindex $dist_D 1])}]
        }
    }
    set dist_D $new_dist_D

    # Step 2: Print updated distance vectors
    puts "Updated distance vectors:"
    puts "A: $dist_A"
    puts "B: $dist_B"
    puts "C: $dist_C"
    puts "D: $dist_D"
}

# Simulate the distance vector algorithm for a few iterations
for {set i 0} {$i < 5} {incr i} {
    distance_vector_routing
}

# Run the simulation
$ns run

