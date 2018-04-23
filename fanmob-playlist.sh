#!/bin/sh

python3 spotdl.py --playlist https://open.spotify.com/user/br0wnpunk/playlist/0vxbG1QMVfGWOLzbPz5OV4\?si\=OEE30SE7RhipKKRgrERBVg
python3 spotdl.py --list=fanmob-demo.txt

cd "Music/";

for i in *.mp3;
  do name=`echo $(uuidgen)`;
  image="${name}.jpg";
  video="${name}.mp4";
  ffmpeg -i "$i" -an -vcodec copy "${image}";
  ffmpeg -loop 1 -i "${image}" -i "$i" -c:v libx264 -tune stillimage -c:a aac -b:a 192k -pix_fmt yuv420p -shortest "${video}";

  title=$(id3info "${i}" | sed -n 's/^=== TIT2 \(.*\): //p');
  artist=$(id3info "${i}" | sed -n 's/^=== TPE1 \(.*\): //p');
  cat >>playlist.json <<EOL
  {
    id: '${name}',
    title: '${title}',
    artist: '${artist}',
    thumbnail: '${image}',
    source: '${video}',
  },
EOL
done

rm *.mp3;

aws s3 sync . s3://fanmob-media --acl public-read
