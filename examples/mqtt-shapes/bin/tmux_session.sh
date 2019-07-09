#! /usr/bin/env bash
#
# (c) 2019 Copyright, Real-Time Innovations, Inc.  All rights reserved.
#
# RTI grants Licensee a license to use, modify, compile, and create derivative
# works of the Software.  Licensee has the right to distribute object form
# only for use with RTI products.  The Software is provided "as is", with no
# warranty of any type, including any warranty for fitness for any purpose.
# RTI is under no obligation to maintain or support the Software.  RTI shall
# not be liable for any incidental or consequential damages arising out of the
# use or inability to use the software.
#

DEMO_DIR="${RTI_MQTTSHAPES_DEMO_DIR:-$(pwd)}"

#== initialization
set -o nounset

readonly session_name="${RTI_MQTTSHAPES_TMUX_SESSION:-DEMO}"

readonly window0_name="SH"
readonly window1_name="DATA"
readonly window2_name="BROKER"



#== function definitions

function send_tmux_commands {
    
    # Create sessions first, then windows, then panes, then send commands to 
    # panes. This parallelizes commands best as commands in all windows to can 
    # start parallel, but we may need to sequence some commands in some panes.  
    # Additionally there's less variability on sessions/windows than 
    # panes/commands so this way we are making it easier to compose where 
    # there's more variability.


    # window creation
    # the first window doesn't need to be created because session creates it
    tmux new-window  -t  "$session_name:1" -n "$window1_name"
    tmux new-window  -t  "$session_name:2" -n "$window2_name"
    # tmux new-window  -t  "$session_name:3" -n "$window3_name"
    # tmux new-window  -t  "$session_name:4" -n "$window4_name"

    # ignore normal instant-messaging activity in the comm window
    # tmux setw -t "$session_name:1" monitor-activity off

    # ignore activity in the misc window
    # tmux setw -t "$session_name:3" monitor-activity off

    ## pane creation

    # note: pane creation syntax:
    #   * create a pane to the right of the current pane, width 66% of current
    #     pane, with:  split-window -h -p 66
    #   * create a pane below the current pane, height 66% of current pane's,
    #     with: split-window -v -p 66

    # window 1 panes (domain_A):
    # ------------------------------
    # |             |              |
    # | agent-dds   | monitor      |
    # |             |              |
    # ------------------------------
    tmux split-window -t "$session_name:1.0" -v -p 50
    tmux split-window -t "$session_name:1.0" -h -p 50
    # tmux select-pane -t "$session_name:1.2"
    tmux split-window -t "$session_name:1.2" -h -p 50

    # tmux split-window -t "$session_name:1.1" -h -p 50
    

    # window 3 panes (router)
    # -----------------------------
    # |             |             |
    # |   router    | broker-logs |
    # |             |             |
    # -----------------------------
    # tmux split-window -t "$session_name:3.0" -h -p 50

    # window 2 panes (mqtt):
    # ----------------------------
    # |             |            |
    # |  publisher  | subscriber |
    # |             |            |
    # ----------------------------
    tmux split-window -t "$session_name:2.0" -v -p 50
    tmux split-window -t "$session_name:2.0" -h -p 50

    # window 4 panes (domain_B):
    # ------------------------------
    # |             |              |
    # | shapes-demo | <none>       |
    # |             |              |
    # ------------------------------
    # tmux split-window -t "$session_name:4.0" -h -p 50

    # window 0 panes (monitor)
    # ---------------
    # |    top      | 
    # |-------------|
    # |   <none>    |
    # ---------------
    # tmux split-window -t "$session_name:0.0" -v -p 50


    ## pane commands (if possible, all panes should be created already, so
    ## commands in panes can startup in parallel).
    
    #######################################################################

    # tmux send-keys -t "$session_name:2.0" \
    #     "sleep 5 && make -C ${DEMO_DIR} monitor" C-m

    tmux send-keys -t "$session_name:2.0" \
        "make -C ${DEMO_DIR} shapes" C-m

    tmux send-keys -t "$session_name:2.1" \
        "make -C ${DEMO_DIR} broker-stop broker-start broker-log" C-m

    tmux send-keys -t "$session_name:2.2" \
        "sleep 6 && make -C ${DEMO_DIR} monitor" C-m
    #######################################################################
    
    tmux send-keys -t "$session_name:1.0" \
        "make -C ${DEMO_DIR} agent-dds" C-m
    tmux send-keys -t "$session_name:1.1" \
        "sleep 4 && make -C ${DEMO_DIR} router" C-m
    tmux send-keys -t "$session_name:1.2" \
        "sleep 2 && make -C ${DEMO_DIR} mqtt-publisher" C-m
    tmux send-keys -t "$session_name:1.3" \
        "sleep 2 && make -C ${DEMO_DIR} mqtt-subscriber" C-m
    
    #######################################################################

    
    
    tmux select-window -t "$session_name:1.0"
}

#== execution

tmux has-session -t "$session_name" &> /dev/null
if [[ $? -eq 0 ]]; then
    echo "error: session '$session_name' already exists"
    exit 64
fi

# session creation (also creates window 0)
# note: we need -d on new-session so we don't immediately attach to the session
# (and so we can keep creating windows in the new session)
tmux new-session -s  "$session_name"   -n "$window0_name" -d

# send commands in the background so we can attach and see things as they 
# happen
send_tmux_commands &

# attach like a boss
tmux attach
