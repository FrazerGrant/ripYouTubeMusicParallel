#title=$(curl "https://www.youtube.com/watch?v=aeaJnsxCzM0&list=OLAK5uy_npTt7HM576BH0MkZ0nf4kTUT73QWcC4Xg&index=4" -so - | grep -iPo '(?<=<title>)(.*)(?=</title>)')
#title=${title%"- YouTube"}

title=$(curl "https://www.youtube.com/watch?v=aeaJnsxCzM0&list=OLAK5uy_npTt7HM576BH0MkZ0nf4kTUT73QWcC4Xg&index=4" -so - | grep -iPo '(?<=<title>)(.*)(?=</title>)')
title=${title%"- YouTube"}
echo $title

#s="Infected Mushroom - Groove Attack - YouTube"
#echo ${s/ - YouTube/}
