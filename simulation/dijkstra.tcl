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

# Define adjacency list for the graph (network topology)
set adj_list {
    A {B 1 C 4}
    B {A 1 C 2}
    C {A 4 B 2 D 3}
    D {C 3}
}

# Initialize distances and predecessors
set distances {A 0 B inf C inf D inf}
set predecessors {A {} B {} C {} D {}}

# Procedure to implement Dijkstra's Algorithm
proc dijkstra {source adj_list distances predecessors} {
    # Initialize the unvisited nodes (using a list)
    set unvisited_nodes [dict keys $adj_list]
    set visited_nodes {}

    # Set initial distances to infinity for all nodes except the source
    foreach node [dict keys $adj_list] {
        if {$node != $source} {
            dict set distances $node inf
        }
    }
    dict set distances $source 0

    # Main loop of Dijkstra's Algorithm
    while {[llength $unvisited_nodes] > 0} {
        # Find the node with the smallest distance
        set min_dist_node ""
        set min_dist inf
        foreach node $unvisited_nodes {
            set dist [dict get $distances $node]
            if {$dist < $min_dist} {
                set min_dist $dist
                set min_dist_node $node
            }
        }

        # Remove the node with the smallest distance from unvisited list
        set unvisited_nodes [lsearch -all $unvisited_nodes $min_dist_node]
        set unvisited_nodes [lreplace $unvisited_nodes 0 0]

        # Mark the node as visited
        lappend visited_nodes $min_dist_node

        # Relax the edges of the current node
        set neighbors [dict get $adj_list $min_dist_node]
        foreach {neighbor weight} $neighbors {
            if {![lsearch $visited_nodes $neighbor]} {
                set new_dist [expr {[dict get $distances $min_dist_node] + $weight}]
                set old_dist [dict get $distances $neighbor]
                if {$new_dist < $old_dist} {
                    dict set distances $neighbor $new_dist
                    dict set predecessors $neighbor $min_dist_node
                }
            }
        }
    }

    return $distances
}

# Run Dijkstra's algorithm from node A
set distances [dijkstra A $adj_list $distances $predecessors]

# Output the results
puts "Shortest distances from A:"
foreach node [dict keys $distances] {
    set dist [dict get $distances $node]
    puts "$node: $dist"
}

# Run the simulation
$ns run

