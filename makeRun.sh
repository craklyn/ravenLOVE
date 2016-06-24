touch ../ravenLOVE.love
rm ../ravenLOVE.love
zip -r ../ravenLOVE.love *

if uname -a | grep 'Darwin';
then
  open -a /Applications/love0.8.0.app   ../ravenLOVE.love
else
  ../Love/love.exe ../ravenLOVE.love
fi
