#!/bin/bash

# Helper function to run kdotool commands with getmouselocation first,
# and strip the repeated mouse location output from the result.
run_kdotool() {
  # Run "getmouselocation" plus the target command, capture all output
  output=$(kdotool getmouselocation "$1")

  # The first line is always the mouse location info, remove it
  # Print the rest (which is the actual desired output)
  echo "$output" | tail -n +2
}

# Get mouse location info once (we want to display it)
mouse_info=$(kdotool getmouselocation)

# Extract window UUID from mouse_info
window_id=$(echo "$mouse_info" | grep -oP 'window:\{\K[^\}]+')

# Extract mouse X and Y
mouse_x=$(echo "$mouse_info" | grep -oP 'x:\K[0-9]+')
mouse_y=$(echo "$mouse_info" | grep -oP 'y:\K[0-9]+')

# Now get other info by calling run_kdotool helper
pid=$(run_kdotool getwindowpid)
class=$(run_kdotool getwindowclassname)
name=$(run_kdotool getwindowname)
geom_raw=$(run_kdotool getwindowgeometry)

# Parse geometry info from geom_raw
position=$(echo "$geom_raw" | grep 'Position:' | sed 's/ *Position: //')
geometry=$(echo "$geom_raw" | grep 'Geometry:' | sed 's/ *Geometry: //')

# Output formatted info
echo "Mouse Location:  X:$mouse_x Y:$mouse_y"
echo "Window ID:       {$window_id}"
echo "Window PID:      $pid"
echo "Window Class:    $class"
echo "Window Title:    $name"
echo "Window Position: $position"
echo "Window Size:     $geometry"
