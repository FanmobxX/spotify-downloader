#!/bin/sh

# python3 spotdl.py --playlist https://open.spotify.com/user/br0wnpunk/playlist/0vxbG1QMVfGWOLzbPz5OV4\?si\=OEE30SE7RhipKKRgrERBVg
# python3 spotdl.py --list=fanmob-demo.txt

cd 'Music/';

BUCKET='fanmob-media';
mkdir "${BUCKET}/";

echo [ > playlist.json

for i in *.mp3;
  do name=`echo $i | md5`;
  image="$BUCKET/${name}.jpg";
  video="$BUCKET/${name}.mp4";
  ffmpeg -i "$i" -an -vcodec copy "${image}";
  ffmpeg -loop 1 -i "${image}" -i "$i" -c:v libx264 -tune stillimage -c:a aac -b:a 192k -pix_fmt yuv420p -shortest "${video}";

  title=`id3info "${i}" | sed -n 's/^=== TIT2 \(.*\): //p'`;
  artist=`id3info "${i}" | sed -n 's/^=== TPE1 \(.*\): //p'`;
  cat >>playlist.json <<EOL
  {
    id: '${name}',
    title: '${title}',
    artist: '${artist}',
    thumbnail: 'https://s3.amazonaws.com/${image}',
    source: 'https://s3.amazonaws.com/${video}',
  },
EOL
done

echo ], >> playlist.json

aws s3 sync "$BUCKET" s3://fanmob-media --acl public-read
