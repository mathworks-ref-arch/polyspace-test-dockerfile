#!/bin/bash

pstestroot=/opt/matlab/polyspace/pstest/pstunit
cat << "EOF"
 ____       _                                  _____         _     ____  
|  _ \ ___ | |_   _ ___ _ __   __ _  ___ ___  |_   _|__  ___| |_  |  _ \  ___  _ __ ___   ___  
| |_) / _ \| | | | / __| '_ \ / _` |/ __/ _ \   | |/ _ \/ __| __| | | | |/ _ \| '_ \`_ \ / _ \ 
|  __/ (_) | | |_| \__ \ |_) | (_| | (_|  __/   | |  __/\__ \ |_  | |_| |  __/| | | | | | (_) |
|_|   \___/|_|\__, |___/ .__/ \__,_|\___\___|   |_|\___||___/\__| |____/ \___||_| |_| |_|\___/ 
              |___/    |_|      
EOF

echo REGISTER TEST
echo -e "\tGenerating test registration function and main() function..."
# Use -generate command to generate registration function and main() 
polyspace-test -generate -registration -main \
               -results-dir /work \
               -filename registration.c \
               -test-sources /work/test.c
echo -e "\tGenerated file registration.c in current directory."

echo BUILD TEST
echo -e "\tBuilding tests and generating test runner..."
# Compile and link test code with Polyspace Test source and include
# to build test runnable
cd /work
gcc file.c test.c registration.c $pstestroot/src/pstunit.c \
    -I $pstestroot/include \
    -o testrunner
echo -e "\tGenerated test runnable 'testrunner' in current directory."
# Run test runnable and show output in tabluar format
echo RUN TEST
echo -e "\tRunning tests..."
./testrunner -format t -color



