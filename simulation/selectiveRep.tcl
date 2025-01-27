# Initialize the simulation
set ns [new Simulator]
set tracefile [open out.tr w]
$ns trace-all $tracefile

# Define nodes (sender and receiver)
set sender [$ns node]
set receiver [$ns node]

# Create a duplex link between sender and receiver
$ns duplex-link $sender $receiver 1Mb 10ms DropTail

# Add a noisy channel (error model)
set errModel [new ErrorModel]
$errModel set rate_ 0.1   ;# 10% error rate
$errModel set unit_ pkt
$errModel ranvar [new RandomVariable/Uniform]
$errModel drop-target [new Agent/Null]
$ns lossmodel $errModel $sender $receiver

# Create UDP agents for sender and receiver
set senderAgent [new Agent/UDP]
$sender attach $senderAgent

set receiverAgent [new Agent/Null]
$receiver attach $receiverAgent

# Connect the sender and receiver agents
$ns connect $senderAgent $receiverAgent

# Define window size for Selective Repeat protocol
set window_size 4

# Initialize variables for Selective Repeat
set seq_num 0
set ack_received [list]
set buffer {}

# Function to simulate the Selective Repeat protocol
proc selective_repeat {src dst window_size timeout} {
    global seq_num ack_received buffer

    # Recursive procedure to send frames
    proc send_frame {src dst seq_num window_size timeout} {
        global buffer
        if {[llength $buffer] < $window_size} {
            set frame [expr {$seq_num % $window_size}]
            puts "Sending frame $frame"
            $src send "Frame $frame"

            # Schedule timeout for frame
            set ackEvent [after $timeout "check_ack $src $dst $frame timeout"]
            $src set ack_event_ $ackEvent
            lappend buffer $frame
        }
    }

    # Procedure to check for ACK
    proc check_ack {src dst frame timeout} {
        global seq_num ack_received buffer

        if {[$src set ack_received_] == 1} {
            puts "ACK received for frame $frame"
            lappend ack_received $frame
            set buffer [lrange $buffer 1 end] ;# Remove the acknowledged frame
            # Move window and send new frames if any
            set seq_num [expr {$seq_num + 1}]
        } else {
            # Timeout: Resend the frame
            puts "Timeout: Resending frame $frame"
            send_frame $src $dst $frame $timeout
        }
    }

    # Start sending the first frame
    send_frame $src $dst $seq_num $window_size $timeout
}

# Define timeout (in ms) for retransmission
set timeout 1000

# Start the Selective Repeat protocol
$ns at 1.0 "selective_repeat $senderAgent $receiverAgent $window_size $timeout"

# Run the simulation
$ns run

