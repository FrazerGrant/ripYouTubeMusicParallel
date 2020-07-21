#!/bin/bash

sessionuuid=$(head -c 16 /dev/urandom | base32) 
dir1="/tmp/$sessionuuid"
#dir2="$dir1/$sessionuuid"
#dir3="$dir1"/"return to the sauce"
#echo $dir3
mkdir $dir1
#mkdir $dir2
mkdir "$dir1/return to the sauce"
ls -la $dir1
#cd $dir1
#album=$(cd $dir1 | ls -td -- */ | head -n 1 | cut -d'/' -f1)
#echo $album
#convertedAlbum="$dir1"/"$album"
#echo $convertedAlbum
#cd $convertedAlbum
#touch $convertedAlbum/test.opus
#touch $convertedAlbum/test2.opus
#touch $convertedAlbum/test3.opus
#Files=(*.opus)
#echo ${#Files[@]}
#ls -la