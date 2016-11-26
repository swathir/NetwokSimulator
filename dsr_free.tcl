#===================================================
# Define options
#===================================================
set val(chan)           Channel/WirelessChannel    ;# channel type
set val(prop)           Propagation/FreeSpace        ;# radio-propagation model
set val(netif)           Phy/WirelessPhy                ;# network interface type
set val(mac)           Mac/802_11                      ;# MAC type
set val(ifq)              Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)                LL                                    ;# link layer type
set val(ant)             Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)          50                                   ;# max packet in ifq
set val(nn)              20                                     ;# number of mobilenodes
set val(rp)              DSR                              ;# routing protocol  
set val(sc)	    "./scenario"		       ;# scenario file
set val(x)	    500.0	                    ;
set val(y)	    400.0	                    ;
set val(simtime)      10.0			         ; #sim time
set val(drate)	     2.0e6	                     ; #default datarate
set val(dist)	     100			         ;
#===============================================================
# Main Program
#===============================================================

if { $argc != 2} {
        puts "Wrong no. of cmdline args."
        puts "Usage: ns sim.tcl -dist <x>"
        exit 0
}


proc getopt {argc argv} {
        global val
        lappend optlist dist
 
        for {set i 0} {$i < $argc} {incr i} {
                set arg [lindex $argv $i]
                if {[string range $arg 0 0] != "-"} continue
 
                set name [string range $arg 1 end]
                set val($name) [lindex $argv [expr $i+1]]
        }

}



getopt $argc $argv

#
# Initialize Global Variables
#
set ns_		[new Simulator]
set tracefd     [open assign6.tr w]
$ns_ trace-all $tracefd

#$ns_ use-newtrace

# set up topography object
set topo       [new Topography]

$topo load_flatgrid $val(x) $val(y)
set namtrace [open assign6.nam w]           ;# for nam tracing

$ns_ namtrace-all-wireless $namtrace $val(x) $val(y)

#
# Create God
#

set god_ [ create-god $val(nn) ]

$val(netif) set Pt_ 0.100
$val(netif) set RXThresh_ 7.94328e-13
$val(netif) set CSThresh_ 6.30957e-14



$val(mac) set dataRate_ $val(drate)


#Shadowing Model Parameters
#$val(prop) set std_db_ 4.0
#$val(prop) set pathlossExp_ 3.5


#
#  Create the specified number of mobilenodes [$val(nn)] and "attach" them
#  to the channel.

# configure node


        $ns_ node-config -adhocRouting $val(rp) \
			 -llType $val(ll) \
			 -macType $val(mac) \
			 -ifqType $val(ifq) \
			 -ifqLen $val(ifqlen) \
			 -antType $val(ant) \
			 -propType $val(prop) \
			 -phyType $val(netif) \
			 -channelType $val(chan) \
			 -topoInstance $topo \
			 -agentTrace ON \
			 -routerTrace ON \
			 -macTrace ON \
			 -movementTrace OFF



	for {set i 0} {$i < $val(nn) } {incr i} {
		set node_($i) [$ns_ node]	
		$node_($i) random-motion 0		;# disable random motion
	}




#
# Provide initial (X,Y, Z=0) co-ordinates for mobilenodes
#

#Node 0 is the source, Node 1 is the dst


	$node_(0) set X_ 100.0
	$node_(0) set Y_ 200.0
	$node_(0) set Z_ 0.0
	

	$node_(1) set X_ [expr 100.0 + $val(dist)]
	$node_(1) set Y_ 200.0
	$node_(1) set Z_ 0.0


# Define node initial position in nam

for {set i 0} {$i < $val(nn)} {incr i} {

    # 20 defines the node size in nam, must adjust it according to your scenario
    # The function must be called after mobility model is defined
    

	$node_($i) set X_ [expr 200.0 + $val(dist)*$i]
	$node_($i) set Y_ [expr 200.0 + $val(dist)*($i%2)]
	$node_($i) set Z_ 0.0
	

    $ns_ initial_node_pos $node_($i) 20
}


#for {set i 0} {$i < $val(nn) } {incr i} {
#    $ns_ at $val(stop).0 "$node_($i) reset";
#}
#$ns_ at $val(stop).0002 "puts \"NS EXITING...\" ; $ns_ halt"



#Attach a data-sink to destination
 
	set null_(0) [new Agent/Null]
	$ns_ attach-agent $node_(11) $null_(0)


		
	
	
#traffic...make src talk to dst
		set udp_(0) [new Agent/UDP]
		$ns_ attach-agent $node_(13) $udp_(0)
				
		set cbr_(0) [new Application/Traffic/CBR]
		$cbr_(0) set packetSize_ 512
		$udp_(0) set packetSize_ 512
		$cbr_(0) set interval_ 0.0008
		$cbr_(0) set random_ 0.96749
		$cbr_(0) set maxpkts_ 1000000
		$cbr_(0) attach-agent $udp_(0)
		$ns_ connect $udp_(0) $null_(0)
		$ns_ at 0.0 "$cbr_(0) start"



	
#
# Tell nodes when the simulation ends
#
for {set i 0} {$i < $val(nn) } {incr i} {
    $ns_ at $val(simtime) "$node_($i) reset";
}
$ns_ at $val(simtime) "stop"
$ns_ at $val(simtime).01 "puts \"NS EXITING...\" ; $ns_ halt"
proc stop {} {
    global ns_ tracefd namtrace
    $ns_ flush-trace
     close $tracefd
     close $namtrace
     exec nam assign6.nam &
     exit 0

}

puts "Starting Simulation..."
$ns_ run
