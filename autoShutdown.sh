finlay_macrae@instance-1:~$ cat autoShutdown.sh 
#!/bin/sh
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
