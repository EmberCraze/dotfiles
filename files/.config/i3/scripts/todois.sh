#!/bin/bash

todoist s
todoist --csv list -f "#Work" | awk -F, '{print $NF}' | rofi -dmenu
