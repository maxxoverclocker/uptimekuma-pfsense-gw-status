#!/bin/csh
set path = ($path /bin /sbin /usr/bin /usr/local/bin /usr/local/sbin)

set script_path = '/root/local-scripts/uptime-kuma-gateway-status'

## Uptime Kuma
set uptime_kuma_url = 'http://uptime-kuma.example.com:3001'
set uptime_kuma_gateway_dictionary = 'uptime-kuma-gateway-dictionary.txt'
@ uptime_kuma_heartbeat_interval = 15

## WAN Interface Names
set wan_interfaces = 'WAN_1 WAN_2'

## Gateway Heath Thresholds
@ latency_threshold_warn = 50
@ latency_threshold_error = 100
@ loss_threshold_warn = 5
@ loss_threshold_error = 10

while ( 1 == 1 )
    $script_path/dpinger-gateway-status.py > $script_path/dpinger-gateway-status.out

    foreach wan ( $wan_interfaces )
        @ wan_error = 0
        @ wan_warn = 0
        set msg = ()
        set uptime_kuma_wan_id = `grep $wan $script_path/$uptime_kuma_gateway_dictionary | awk '{print $2}'`
        set dpinger_status = `grep $wan $script_path/dpinger-gateway-status.out`
        @ ping = `echo $dpinger_status | awk '{print $2}'`
        @ loss = `echo $dpinger_status | awk '{print $3}'`
        
        if ( $ping >= $latency_threshold_warn ) then
            if ( $ping >= $latency_threshold_error ) then
                @ wan_error = ${wan_error} + 1
            else
                set msg = ( $msg 'LATENCY' )
                @ wan_warn = ${wan_warn} + 1
            endif
        endif
        
        if ( $loss >= $loss_threshold_warn ) then
            if ( $loss >= $loss_threshold_error ) then
                @ wan_error = ${wan_error} + 1
            else
                set msg = ( $msg 'PACKETLOSS' )
                @ wan_warn = ${wan_warn} + 1
            endif
        endif
        
        if ( $wan_warn == 0 ) then
            set msg = ( 'OK' )
        endif

        if ( $wan_error == 0 ) then
            curl --insecure --silent "${uptime_kuma_url}/api/push/${uptime_kuma_wan_id}?msg=${msg}&ping=${ping}"
        endif
    end
    
    sleep $uptime_kuma_heartbeat_interval
