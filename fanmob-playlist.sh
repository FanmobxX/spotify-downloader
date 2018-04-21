#!/bin/sh

python3 spotdl.py --playlist https://open.spotify.com/user/br0wnpunk/playlist/0vxbG1QMVfGWOLzbPz5OV4\?si\=OEE30SE7RhipKKRgrERBVg

python3 spotdl.py --list=fanmob-demo.txt

cd "Music/";

for i in *.mp3;
  do name=`echo "${i%.*}"`;
  echo $name;
  ffmpeg -i "$i" -an -vcodec copy "${name}.jpg";
  ffmpeg -loop 1 -i "${name}.jpg" -i "$i" -c:v libx264 -tune stillimage -c:a aac -b:a 192k -pix_fmt yuv420p -shortest "${name}.mp4";
done

rm *.mp3;

aws s3 sync . s3://fanmob-media --acl public-read
