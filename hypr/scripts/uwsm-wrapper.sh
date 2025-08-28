#!/bin/bash
# UWSM Wrapper Script
# Attempts to run applications with UWSM, falls back to direct execution

# Check if UWSM is available and session is active
if command -v uwsm >/dev/null 2>&1 && uwsm check may-start >/dev/null 2>&1; then
    # Use UWSM to launch the application
    exec uwsm app -- "$@"
else
    # Fallback to direct execution
    exec "$@"
fi
