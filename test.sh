#!/bin/bash
destDir=$PWD/output

sessionuuid=$(head -c 16 /dev/urandom | base32) # Create a random string to use to avoid collisions.
mkdir /tmp/$sessionuuid
cd /tmp/$sessionuuid

urls=$(youtube-dl --get-id -i $1) # Get the id's of all the youtube videos in the playlist. Also ignore errors caused by videos that are not available (-i).

echo $urls

# This converts the opus file specified in the first parameter to mp3. This is intended to be run in the background
convertToAudio(){
    echo  -e "\nConverting $1\n"

    # FFMPEG
    # -i - Specify input file
    # -c:a mp3 - Set the audio (:a) codec (-c) to mp3
    # "${1%.opus}".mp3 - Output file. Remove .opus from the end of string in the variable named "1". Quotes to allow a file name with spaces. The final .mp3, which is added to the end of the filename which has had .opus removed, can be inside or outside of the quotes.
    # -loglevel quiet - No output
    # -y - Answer all questions with yes. For example: "Do you want to rewrite this file", this won't happen normally so this may not be needed.
    ffmpeg -i "$1"  -c:a mp3 "${1%.opus}".mp3 -loglevel quiet -y

    echo -e "\nFinished $1\n"
}

# Download the audio of each video and start the conversion process if there are not too many running.
for item in $urls; do
    # Download audio
    youtube-dl -x "https://www.youtube.com/watch?v=$item"
    # Find the file that was just downloaded. Youtube-dl includes the video in the filename. It is unlikely that a video will have another video's id in it's name but this could be an issue. We do this to avoid having to request the name from youtube to minimize the number of api requests.
    filename=$(ls | grep "$item")
    # Run conversion only if less than the max are currently running.
    if [ $(jobs | wc -l) -lt 4 ]; then
        # Create lock file to make sure that the file is not converted twice
        touch "$filename".lock
        convertToAudio "$filename" &
    fi
done


# Create an array of all files that end with .opus
Files=(*.opus)

# NOTE: We cannot use "for ... in ..." because the array items contain strings and therefore it would split each item into multiple items across the spaces.
# ${#Files[@]} = Number of items in the array Files
for ((i = 0; i < ${#Files[@]}; i++)); do
    # If the file does not have a lock file associated with it
    if [ ! -f "${Files[$i]}.lock" ]; then
        # Wait for the number of currently running conversions to fall below the max
        while [ $(jobs | wc -l) -gt 3 ]; do  
            echo -e "\n waiting free slot"
            sleep 1
        done
        # Lock the file and run the conversion. NOTE: Lock not needed here because the ones that aren't done are saved in the array. We lock the file anyway just in case a future feature in the future requires it.
        touch "${Files[$i]}".lock
        convertToAudio "${Files[$i]}" &
    fi
done


# Wait for all conversions to finish.
while [ $(jobs | wc -l) -gt 0 ]
do
    jobs
    sleep 1
done


echo "process loop done"