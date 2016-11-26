#-------Event scheduler object creation--------#
set ns [new Simulator]
#----------creating trace objects----------------#
set nt [open lab1.tr w]
$ns trace-all $nt
#----------creating nam objects----------------#
set nf [open lab1.nam w]
$ns namtrace-all $nf
#----------Optional--Setting color ID----------------#
$ns color 1 darkmagenta
$ns color 2 yellow
$ns color 3 blue
$ns color 4 green
$ns color 5 black
#---------- Creating Network----------------#

set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
#---------- Creating Duplex Link----------------#


$ns duplex-link $n1 $n2 2Mb 50ms DropTail
$ns duplex-link $n2 $n1 2Mb 50ms DropTail
$ns duplex-link-op $n1 $n2 orient right

$ns duplex-link $n2 $n3 2Mb 50ms DropTail
$ns duplex-link $n3 $n2 2Mb 50ms DropTail
$ns duplex-link-op $n2 $n3 orient down-left

$ns duplex-link $n3 $n4 2Mb 50ms DropTail
$ns duplex-link $n4 $n3 2Mb 50ms DropTail
$ns duplex-link-op $n3 $n4 orient right

#-------Optional-----Labelling----------------#
$ns at 0.0 "$n1 label NODE1"
$ns at 0.0 "$n2 label NODE2"
$ns at 0.0 "$n3 label NODE3"
$ns at 0.0 "$n4 label NODE4"

$ns at 0.0 "$n1 color blue"
$ns at 0.0 "$n2 color blue"
$ns at 0.0 "$n3 color blue"
$ns at 0.0 "$n4 color blue"
#------------Data Transfer between Nodes----------------#

# Defining a transport agent for sending
set tcp [new Agent/TCP]

# Attaching transport agent to sender node
$ns attach-agent $n2 $tcp

# Defining a transport agent for receiving
set sink [new Agent/TCPSink]

# Attaching transport agent to receiver node
$ns attach-agent $n3 $sink

#Connecting sending and receiving transport agents
$ns connect $tcp $sink

#Defining Application instance
set ftp [new Application/FTP]

# Attaching transport agent to application agent
$ftp attach-agent $tcp

# Setting flow color(optional) 
$tcp set fid_ 4

# data packet generation starting time
$ns at 1.0 "$ftp start"

# data packet generation ending time
$ns at 6.0 "$ftp stop"

#------------Data Transfer between Nodes----------------#

# Defining a transport agent for sending
set udp [new Agent/UDP]

# Attaching transport agent to sender node
$ns attach-agent $n1 $udp

# Defining a transport agent for receiving
set null [new Agent/Null]

# Attaching transport agent to receiver node
$ns attach-agent $n4 $null

#Connecting sending and receiving transport agents
$ns connect $udp $null

#Defining Application instance
set cbr [new Application/Traffic/CBR]

# Attaching transport agent to application agent
$cbr attach-agent $udp

# Setting flow color 
$udp set fid_ 3

# data packet generation starting time
$ns at 1.0 "$cbr start"

# data packet generation ending time
$ns at 6.0 "$cbr stop"

#---------finish procedure--------#

proc finish {} {
	   global ns nf nt 
	   $ns flush-trace
	   close $nf	
           close $nt		   
	   puts "running nam..."
	   exec nam lab1.nam &
	   exit 0
}

#Calling finish procedure
$ns at 10.0 "finish"
$ns run



