#!/usr/bin/env bash

# Must be run as root

# This script will cycle through the colors of the rainbow on your keyboard

# This is the path to the keyboard LED files
LED_PATH="/sys/class/leds/system76_acpi::kbd_backlight"
COLOR_PATH="$LED_PATH/color"
BRIGHTNESS_PATH="$LED_PATH/brightness"

# Get the initial color and brightness
INITIAL_COLOR=$(cat $COLOR_PATH)
INITIAL_BRIGHTNESS=$(cat $BRIGHTNESS_PATH)

# Function to reset the keyboard color and brightness
reset_color() {
    echo $INITIAL_COLOR > $COLOR_PATH
    echo $INITIAL_BRIGHTNESS > $BRIGHTNESS_PATH
    exit
}

# Trap Ctrl+C and reset the keyboard color and brightness
trap reset_color SIGINT

# Set the current color to red
COLOR_RED=255
COLOR_GREEN=255
COLOR_BLUE=0

# Set the color increment to whatever you want
COLOR_INCREMENT=1

# Set the sleep time to whatever you want
SLEEP_TIME=0.01

# If the brightness is 0, set it to 255
if [ $INITIAL_BRIGHTNESS -eq 0 ]; then
    echo 255 > $BRIGHTNESS_PATH
fi

# On the gaze18 keyboard, the max color value appears to be the value of the brightness
MAX_COLOR=255

# To be called every time the color is changed to set the max color value
set_max_color() {
    MAX_COLOR=$(cat $BRIGHTNESS_PATH)
}

# Function to get the hex value of the current color
get_hex_color() {
    RED=$COLOR_RED
    GREEN=$COLOR_GREEN
    BLUE=$COLOR_BLUE

    # Make the color values go between 0 and the brightness value
    RED=$(($RED * $MAX_COLOR / 255))
    GREEN=$(($GREEN * $MAX_COLOR / 255))
    BLUE=$(($BLUE * $MAX_COLOR / 255))

    printf '%02x%02x%02x\n' $RED $GREEN $BLUE
}

# Function to set the keyboard color
set_color() {
    echo $1 > $COLOR_PATH
}

# Function to increment the color
increment_color() {
    if [ $1 -eq 255 ] && [ $2 -eq 0 ] && [ $3 -lt 255 ]; then
	    # Red seems to be very dark compared to the others
	    # I do this for blue & green so the transition is less sudden
        if [ $3 -lt 24 ]; then
	        let "COLOR_BLUE += 1"
	        sleep $SLEEP_TIME
     	    if [ $3 -lt 10 ]; then
		        sleep $SLEEP_TIME
	        fi
        else
        	let "COLOR_BLUE += $COLOR_INCREMENT"
       	fi
    elif [ $1 -gt 0 ] && [ $2 -eq 0 ] && [ $3 -eq 255 ]; then
        let "COLOR_RED -= COLOR_INCREMENT"
    elif [ $1 -eq 0 ] && [ $2 -lt 255 ] && [ $3 -eq 255 ]; then
        let "COLOR_GREEN += COLOR_INCREMENT"
    elif [ $1 -eq 0 ] && [ $2 -eq 255 ] && [ $3 -gt 0 ]; then
        let "COLOR_BLUE -= COLOR_INCREMENT"
    elif [ $1 -lt 255 ] && [ $2 -eq 255 ] && [ $3 -eq 0 ]; then
        let "COLOR_RED += COLOR_INCREMENT"
    elif [ $1 -eq 255 ] && [ $2 -gt 0 ] && [ $3 -eq 0 ]; then
    	if [ $2 -lt 24 ]; then
	        let "COLOR_GREEN -= 1"
	        if [ $2 -lt 10 ]; then
		        sleep $SLEEP_TIME
	        fi
        else
        	let "COLOR_GREEN -= $COLOR_INCREMENT"
       	fi
    fi

    # Make sure the color values are between 0 and 255
    if [ $COLOR_RED -lt 0 ]; then
        COLOR_RED=0
    elif [ $COLOR_RED -gt 255 ]; then
        COLOR_RED=255
    fi

    if [ $COLOR_GREEN -lt 0 ]; then
        COLOR_GREEN=0
    elif [ $COLOR_GREEN -gt 255 ]; then
        COLOR_GREEN=255
    fi

    if [ $COLOR_BLUE -lt 0 ]; then
        COLOR_BLUE=0
    elif [ $COLOR_BLUE -gt 255 ]; then
        COLOR_BLUE=255
    fi
}

# Loop through the colors of the rainbow
while true; do
    set_max_color # Uncertain if best approach, but idk it's ez
    set_color $(get_hex_color)
    # echo $(get_hex_color)
    increment_color $COLOR_RED $COLOR_GREEN $COLOR_BLUE
    sleep $SLEEP_TIME
done
