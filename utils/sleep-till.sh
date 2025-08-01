#!/bin/bash

# Exit on errors and undefined vars
set -euo pipefail

function usage() {
    echo "Usage: $0 <target-date> <command> [args...]"
    echo "Example: $0 '2025-08-01 00:00:00 UTC' echo 'Hello World'"
    exit 1
}

function getts() {
    TZ=UTC date +%s --date="$1"
}

# Validate input
if [[ $# -lt 2 ]]; then
    usage
fi

# Extract and convert target date
target_date="$1"
shift
ts_target=$(getts "$target_date") || { echo "Invalid date: $target_date"; exit 1; }

# Get current time
ts_now=$(getts "now")
echo "Target timestamp: $ts_target"
echo "Current timestamp: $ts_now"

# Minimum required wait
if (( ts_now > ts_target - 20 )); then
    echo "Too close to target time (delta: $((ts_target - ts_now))s)"
    exit 1
fi

# Sleep loop
while (( ts_now < ts_target )); do
    seconds_left=$((ts_target - ts_now))

    # Sleep in large steps for long waits
    if (( seconds_left > 60 )); then
        sleep_time=30
    else
        sleep_time=1
    fi

    echo "Sleeping... ${seconds_left}s remaining"
    sleep "$sleep_time"

    ts_now=$(getts "now")
done


# Final check before exec (also protects against clock skew)
ts_now=$(getts "now")
if (( ts_now < ts_target )); then
    echo "Aborting: woke up too early due to clock skew or signal"
    exit 1
fi


# Run the command
echo "Time reached. Executing: $*"
exec "$@"
