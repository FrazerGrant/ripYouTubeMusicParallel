#!/bin/bash
# ./test.sh "https://www.youtube.com/watch?v=aeaJnsxCzM0&list=OLAK5uy_npTt7HM576BH0MkZ0nf4kTUT73QWcC4Xg&index=4"

startTime=$(date +%s)
destDir=$HOME/ripYouTubeMusic/rippedMusic
mkdir $destDir

sessionuuid=$(head -c 16 /dev/urandom | base32) # Create a random string to use to avoid collisions.
tempDir="/tmp/$sessionuuid"
mkdir  $tempDir
cd $tempDir

#urls=$(youtube-dl --get-id -i $1) # Get the id's of all the youtube videos in the playlist. Also ignore errors caused by videos that are not available (-i).

#echo $urls

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


# Create an array of all files that end with .opus

youtube-dl -x -o '%(playlist_title)s/%(title)s-%(id)s.%(ext)s' $1

album=$(cd $tempDir | ls -td -- */ | head -n 1 | cut -d'/' -f1)
echo $album
convertedAlbum="$tempDir"/"$album"
echo $convertedAlbum
cd "$convertedAlbum"
Files=(*.opus)



for ((i = 0; i < ${#Files[@]}; i++)); do
    # If the file does not have a lock file associated with it
    if [ ! -f "${Files[$i]}.lock" ]; then
        # Wait for the number of currently running conversions to fall below the max
        while [ $(jobs | wc -l) -gt 4 ]; do  
            echo -e "\n waiting free slot"
            sleep 1
        done       
        #touch "${Files[$i]}".lock
        convertToAudio "${Files[$i]}" &
    fi
done


# Wait for all conversions to finish.
while [ $(jobs | wc -l) -gt 0 ]
do
    jobs
    sleep 1
done

rm "$convertedAlbum"/*.opus
#destConvertedAlbum="$destDir/$album"
#echo destConvertedAlbum
#mkdir "$destConvertedAlbum"
cp -vr "$convertedAlbum" $destDir


endTime=$(date +%s)
totalSeconds=$(($endTime-$startTime))
Minutes=$(( totalSeconds / 60 ))
Seconds=$(( totalSeconds % 60 ))
echo "Converted in $Minutes: Minutes $Seconds: Seconds"


echo "process loop done"