#!/bin/bash
# Double-click to start the trainer and open it in the browser.
# Close this Terminal window to stop it.
cd "$(dirname "$0")"
(sleep 2 && open "http://127.0.0.1:8124") &
./run.sh
