#!/bin/bash
destDir=$PWD/output
sessionuuid=$(head -c 16 /dev/urandom | base32)
mkdir /tmp/$sessionuuid
cd /tmp/$sessionuuid

urls=$(youtube-dl --get-id -i $1)

echo $urls

convertToAudio(){
    echo  -e "\nConverting $1\n"
    ffmpeg -i "$1"  -c:a mp3 "${1%.opus}".mp3 -loglevel quiet -y
    echo -e "\nFinished $1\n"
}

for item in $urls; do
    youtube-dl -x "https://www.youtube.com/watch?v=$item" 
    filename=$(ls | grep "$item")
    if [ $(jobs | wc -l) -lt 4 ]; then
        touch "$filename".lock
        convertToAudio "$filename" &
    fi
done

Files=(*.opus)

for ((i = 0; i < ${#Files[@]}; i++)); do  
    if [ ! -f "${Files[$i]}.lock" ]; then
        while [ $(jobs | wc -l) -gt 3 ]; do  
            echo -e "\n waiting free slot"
            sleep 1
        done

        echo "Locking file "${Files[$i]}" at index $i"
        touch "${Files[$i]}".lock
        convertToAudio "${Files[$i]}" &
    fi
done



while [ $(jobs | wc -l) -gt 0 ]
do
    jobs
    sleep 1
done

echo "process loop done"

