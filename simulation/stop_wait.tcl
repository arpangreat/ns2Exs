# Initialize the simulation
set ns [new Simulator]
set tracefile [open out.tr w]
$ns trace-all $tracefile

# Define nodes
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

# Create agents for sender and receiver
set senderAgent [new Agent/UDP]
$sender attach $senderAgent

set receiverAgent [new Agent/Null]
$receiver attach $receiverAgent

# Connect the agents
$ns connect $senderAgent $receiverAgent

# Initialize variables for Stop-and-Wait
$senderAgent set ack_event_ ""
$senderAgent set ack_received_ 0

# Procedure to simulate Stop-and-Wait Protocol
proc stop_and_wait {src dst timeout} {
    # Initial frame number
    set frame 0

    # Recursive procedure to send frames
    proc send_frame {src dst frame timeout} {
        puts "Sending frame $frame"
        $src send "Frame $frame"

        # Schedule timeout for ACK
        set ackEvent [after $timeout "check_ack $src $dst $frame $timeout"]
        $src set ack_event_ $ackEvent
    }

    # Procedure to check for ACK
    proc check_ack {src dst frame timeout} {
        # If ACK is received, move to the next frame
        if {[$src set ack_received_] == 1} {
            $src set ack_received_ 0
            incr frame
            send_frame $src $dst $frame $timeout
        } else {
            # Timeout: Resend the frame
            puts "Timeout: Resending frame $frame"
            send_frame $src $dst $frame $timeout
        }
    }

    # Start sending the first frame
    send_frame $src $dst $frame $timeout
}

# Define timeout (in ms) for retransmission
set timeout 1000

# Start the Stop-and-Wait protocol
$ns at 1.0 "stop_and_wait $senderAgent $receiverAgent $timeout"

# Run the simulation
$ns run

