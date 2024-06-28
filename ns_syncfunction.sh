#!/bin/bash
# run this script on a linux system that is always on, with a synced connection to a cloud repository. This bash scripts was developed for Ubuntu running in Windows 11 WSL, which is monitoring the OneDrive repository on the host machine (which is mounted in the C drive). This was all done with standard user priveledges. How this works:
# - install Notion Scholar like normal
# - manually export Endnote library to bibtex formatted .txt file (ctrl+A, then File->Export, then save as type ".txt" with "BibTeX export" output style)
# - copy "My EndNote Library.txt" to "My EndNote Library.bib" in the same directory to "prime the pump" (sorta)
# - run this script (making sure you put in the necessary file location, and editing the PATH to run notion scholar)

# Cool things about this:
# - Can monitor a file on a cloud share on the host (like OneDrive), and can be run in WSL without admin priveledges. This means that you can have this running on your office computer and push changes from any other machine running EndNote Desktop and OneDrive
# - Automates most of the EndNote-to-Notion pipeline

# Not so cool things (things to improve):
# - Requires manually exporting your EndNote library every time you want to sync
# - ID's (FileName) from the BibTeX exports from different EndNote Desktop installs are sometimes different, leading to some sources being exported multiple times. 

# Path to the file you want to monitor, this can be a cloudshare
# file_path="/mnt/c/Users/username/OneDrive/testfile.txt"

file_path="/{insert_location_here}/My EndNote Library.txt" # **EDIT**
log_file="$(dirname "$file_path")/file_monitor.log"

# add notion scholar path
export PATH="/home/{USER}/.local/bin:${PATH}" # **EDIT**

# Initial checksum of the file
old_checksum=""

# this while loop continuously monitors the location where Endnote exports library
while true; do
    # Get the current checksum of the file
    new_checksum=$(ls -la "$file_path" | md5sum)
    current_timestamp=$(date +"%Y-%m-%d %H:%M:%S")

    # Compare with the previous checksum
    if [ "$new_checksum" != "$old_checksum" ]; then
        # add the command here
        echo "$current_timestamp: The file has been updated" >> "$log_file"
        # wait for the file to be release from EndNote
        sleep 1
        # convert bibtex formatted .txt to .bib
        cp "$file_path" "${file_path::-3}bib" >> "$log_file"
        # run notion scholar sync command and output to the log
        ns run >> "$log_file"
        # There is no error capturing, just error logging, nothing will stop this script from running indefinitely
    fi

    # Update the old checksum for the next iteration
    old_checksum="$new_checksum"

    # Sleep for a short duration before checking again
    sleep 1
done
