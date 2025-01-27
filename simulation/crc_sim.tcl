# Initialize the simulation
set ns [new Simulator]
set tracefile [open out.tr w]
$ns trace-all $tracefile

# Define nodes
set n0 [$ns node]
set n1 [$ns node]

# Create a duplex link
$ns duplex-link $n0 $n1 1Mb 10ms DropTail

set errModel [new ErrorModel]
$errModel set rate_ 0.01  ;# Set the error rate to 1%
$errModel set unit_ pkt   ;# Apply errors at the packet level
$errModel ranvar [new RandomVariable/Uniform]
$errModel drop-target [new Agent/Null]

$ns lossmodel $errModel $n0 $n1
# CRC encoding procedure
proc crc_encode {data generator} {
    # Calculate the number of zeros to append
    set num_zeros [expr {[string length $generator] - 1}]
    set data "$data[string repeat 0 $num_zeros]"

    # Perform XOR division
    for {set i 0} {$i <= [expr {[string length $data] - [string length $generator]}]} {incr i} {
        if {[string index $data $i] == "1"} {
            for {set j 0} {$j < [string length $generator]} {incr j} {
                set bit1 [string index $data [expr {$i + $j}]]
                set bit2 [string index $generator $j]
                set data [string replace $data [expr {$i + $j}] [expr {$i + $j}] [expr {$bit1 != $bit2}]]
            }
        }
    }
    return $data
}

# CRC decoding procedure
proc crc_decode {data generator} {
    set remainder [crc_encode $data $generator]
    if {[string trimleft $remainder 0] == ""} {
        return "No Error"
    } else {
        return "Error Detected"
    }
}

# Application logic
proc send_data {src dst data generator} {
    set encoded_data [crc_encode $data $generator]
    puts "Encoded Data: $encoded_data"
    $src send $encoded_data
}

# Receive data and check CRC
Agent/Null instproc recv {data} {
    $self instvar generator
    set status [crc_decode $data $generator]
    puts "Received Data: $data, Status: $status"
}

# Create a UDP agent for the sender node
set udpAgent [new Agent/UDP]
$n0 attach $udpAgent

# Create a Null agent for the receiver node
set nullAgent [new Agent/Null]
$n1 attach $nullAgent

# Connect the sender and receiver agents
$ns connect $udpAgent $nullAgent

# Send data from sender to receiver
proc send_data {srcAgent data generator} {
    set encoded_data [crc_encode $data $generator]
    puts "Encoded Data: $encoded_data"
    $srcAgent send "$encoded_data"
}

# Configure the CRC generator polynomial
set generator "1101" ;# Example CRC-3 polynomial

# Schedule data transmission
$ns at 1.0 "send_data $udpAgent 101101 $generator"
# Run the simulation
$ns run

