#!/bin/bash

# If quickshell is active, kill it to release 100% of its RAM
if pgrep -x "quickshell" > /dev/null; then
    pkill -x "quickshell"
else
    # Launch quickshell on demand
    quickshell &
fi
