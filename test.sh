#!/bin/bash
# ./test.sh "https://www.youtube.com/watch?v=aeaJnsxCzM0&list=OLAK5uy_npTt7HM576BH0MkZ0nf4kTUT73QWcC4Xg&index=4"

startTime=$(date +%s)
destDir=$HOME/ripYouTubeMusic/rippedMusic
mkdir $destDir

# Create a random string.
sessionuuid=$(head -c 16 /dev/urandom | base32) 

tempDir="/tmp/$sessionuuid"
mkdir  $tempDir
cd $tempDir

# This converts the opus file to mp3.
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
#for item in $urls; do
    # Download audio
#    youtube-dl -x "https://www.youtube.com/watch?v=$item"
    # Find the file that was just downloaded. Youtube-dl includes the video in the filename. It is unlikely that a video will have another video's id in it's name but this could be an issue. We do this to avoid having to request the name from youtube to minimize the number of api requests.
#    filename=$(ls | grep "$item")
    # Run conversion only if less than the max are currently running.
#    if [ $(jobs | wc -l) -lt 4 ]; then
        # Create lock file to make sure that the file is not converted twice
#        touch "$filename".lock
#        convertToAudio "$filename" &
#    fi
#done


youtube-dl -x -o '%(playlist_title)s/%(title)s.%(ext)s' $1

album=$(cd $tempDir | ls -td -- */ | head -n 1 | cut -d'/' -f1)
convertedAlbum="$tempDir"/"$album"
cd "$convertedAlbum"
# Create an array of all files that end with .opus
Files=(*.opus)

for ((i = 0; i < ${#Files[@]}; i++)); do
        # Wait for the number of currently running conversions to fall below the max
        while [ $(jobs | wc -l) -gt 5 ]; do  
            echo -e "\n waiting free slot"
            sleep 1
        done       
        convertToAudio "${Files[$i]}" &
done


# Wait for all conversions to finish.
while [ $(jobs | wc -l) -gt 1 ]
do
    sleep 1
done

rm "$convertedAlbum"/*.opus
mv $tempDir/* $destDir


endTime=$(date +%s)
totalSeconds=$(($endTime-$startTime))
Minutes=$(( totalSeconds / 60 ))
Seconds=$(( totalSeconds % 60 ))
echo "Converted in $Minutes: Minutes $Seconds: Seconds"
