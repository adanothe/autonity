#!/bin/bash

# Execute aut protocol get-committee and format the output using awk
aut protocol committee | awk -F '[:,]' '
    BEGIN { 
        print "---------------------------------------------------------------------------"
        printf "| %-5s | %-40s | %-15s |\n", "No.", "Validator address", "Voting Power (NTN)" 
        print "---------------------------------------------------------------------------" 
    }
    /addr/ { 
        sub(/^ *" */, "", $2); 
        gsub(/"/, "", $2); 
        printf "| %-5d | %-40s | ", ++count, $2 
    }
    /voting_power/ { 
        printf "%-15.6f |\n", $2 / 1e18 
    }
    END {
        print "---------------------------------------------------------------------------"
    }
'
