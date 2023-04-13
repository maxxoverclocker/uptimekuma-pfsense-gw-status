#!/bin/csh

# Add necessary directories to the system path
set path = ($path /bin /sbin /usr/bin /usr/local/bin /usr/local/sbin)

# Set the path of the script
set script_path = '/root/local-scripts/uptime-kuma-gateway-status'

# Uptime Kuma settings
set uptime_kuma_url = 'http://uptime-kuma.prochaska.pub:3001'
set uptime_kuma_gateway_dictionary = 'uptime-kuma-gateway-dictionary.txt'
@ uptime_kuma_heartbeat_interval = 15

# WAN interface names
set wan_interfaces = 'WAN_1_DHCP WAN_2_DHCP'

# Gateway health thresholds
@ latency_threshold_warn = 50
@ latency_threshold_error = 100
@ loss_threshold_warn = 5
@ loss_threshold_error = 10

# Loop indefinitely
while ( 1 == 1 )
    # Execute dpinger-gateway-status.py and redirect output to a file
    $script_path/dpinger-gateway-status.py > $script_path/dpinger-gateway-status.out

    # Process each WAN interface
    foreach wan ( $wan_interfaces )
        @ wan_error = 0
        @ wan_warn = 0

        # Initialize variable for message
        set msg = ()

        # Get the Uptime Kuma monitor push ID for the current WAN interface
        set uptime_kuma_monitor_push_id = `grep $wan $script_path/$uptime_kuma_gateway_dictionary | awk '{print $2}'`
        
        # Get the status of the current WAN interface from dpinger-gateway-status.out
        set dpinger_status = `grep $wan $script_path/dpinger-gateway-status.out`
        
        # Extract latency and loss values from dpinger status
        @ latency = `echo $dpinger_status | awk '{print $2}'`
        @ loss = `echo $dpinger_status | awk '{print $3}'`
        
        # Check if latency is above warning threshold
        if ( $latency >= $latency_threshold_warn ) then
            # Check if latency is above error threshold
            if ( $latency >= $latency_threshold_error ) then
                @ wan_error = ${wan_error} + 1
            else
                # Add 'LATENCY' to the message
                set msg = ( $msg 'LATENCY' )
                @ wan_warn = ${wan_warn} + 1
            endif
        endif
        
        # Check if loss is above warning threshold
        if ( $loss >= $loss_threshold_warn ) then
            # Check if loss is above error threshold
            if ( $loss >= $loss_threshold_error ) then
                @ wan_error = ${wan_error} + 1
            else
                # Add 'PACKETLOSS' to the message
                set msg = ( $msg 'PACKETLOSS' )
                @ wan_warn = ${wan_warn} + 1
            endif
        endif
        
        # If there are no warnings, set message to 'OK'
        if ( $wan_warn == 0 ) then
            set msg = ( 'OK' )
        endif

        # If there are no errors, set status to 'UP', otherwise set it to 'DOWN'
        if ( $wan_error == 0 ) then
            set gw_status = 'UP'
        else
            set gw_status = 'DOWN'
        endif
        
        # Print the gw_status, message, and latency
        echo    "Gateway: ${wan}"
        echo    "Status:  ${gw_status}"
        echo    "Message: ${msg}"
        echo    "Latency: ${latency}"
        echo -n "ApiPush: "
        curl --insecure --silent "${uptime_kuma_url}/api/push/${uptime_kuma_monitor_push_id}?status=${gw_status}&msg=${msg}&ping=${latency}"
        echo ""
		echo ""
    end
    echo "------------------------"
	echo ""
    sleep $uptime_kuma_heartbeat_interval
end
