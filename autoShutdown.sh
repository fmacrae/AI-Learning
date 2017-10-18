#!/bin/sh
# Install instructions: stick this on your VM and if you run crontab and add it to your schedule like this:
#  crontab -e
#  * * * * * sh /home/finlay_macrae/autoShutdown.sh
# Description:
#   looks for established SSH connections then after two calls in a row where it sees no connections 
#   it shuts down the server.  If you have something long running like training then you need to create 
#   a file called keepRunning.txt in the same directory.  Add a line to error handling and end of execution 
#   for your training script to delete the flag file once it crashes or completes.  

if [ -f keepRunning.txt ]; then
  echo 'flag to keep running is still there so no need to shutdown check'
  exit
fi
if netstat | grep ssh | grep -q ESTABLISHED; then
  echo 'People still connected so removing shutdown flag file if needed'
  netstat | grep ssh >> peopleConnected.txt
  if [ -f maybeshutdown.txt ]; then
    rm maybeshutdown.txt
  fi
else
  echo 'No connections current'
  if [ -f maybeshutdown.txt ]; then
    echo 'Two counts and we are out'
    echo 'After another round of inactivity we are pulling the plug' >> maybeshutdown.txt
    mv maybeshutdown.txt shutdown$(date "+%Y.%m.%d-%H.%M.%S").txt
    sudo shutdown -h now
  else
    echo 'Thinking about shutting down'
    echo 'Considering autoshutdown due to no connections' > maybeshutdown.txt
  fi
fi
