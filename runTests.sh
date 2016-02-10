#!/bin/bash
clear

#Variables
EXE=PA2
RESULTCODE=0
EXPECTEDCODE=0
LOGRESULT=0


# Variables formatting the script text red/green for visibility
PATH=/bin:/usr/bin:

NONE='\e[0m'
RED='\e[0;31m';
GREEN='\e[0;32m';

#Building the source
cd src
make buildDist
cd ..

#Testing the files
echo ''
echo Testing files:
echo ''

for FILENAME in $(ls test/input/ | grep -E "*.txt")
do
	#touch test/expected/$FILENAME -Don't touch this, otherwise it will expect there to be nothing in the output.
	touch test/expected_code/$FILENAME
	touch test/result/$FILENAME
	touch test/result_code/$FILENAME
	mkdir test/log -p
	touch test/log/$FILENAME

	EXPECTEDCODE=$(cat test/expected_code/$FILENAME )

	#make a temp file for error logging
	touch test/tempDelete.log.txt
	>test/tempDelete.log.txt

	dist/$EXE test/input/$FILENAME test/result/$FILENAME 2>test/tempDelete.log.txt

	# result code handling...
	RESULTCODE=$?														#put result code into a variable.
	>test/result_code/$FILENAME 										#clear result
	echo $RESULTCODE >> test/result_code/$FILENAME 						#echo result code into file.

	LOGRESULT=$(cat test/tempDelete.log.txt)

	if [ "$EXPECTEDCODE" != "$RESULTCODE" ];
	then
		echo ''
		echo -e "${RED}Error: The return code of $FILENAME is not the what is expected.${NONE}" 1>&2
		echo -e "${RED}executed - $FILENAME - with return code [$RESULTCODE]${NONE}"

		if [ "$LOGRESULT" != "" ]; then
			echo -e "${RED}$LOGRESULT${NONE}"
    	fi
    	#exit 255
    else
		if [ -f test/expected/$FILENAME ]; then
			if [ "$(diff test/expected/$FILENAME test/result/$FILENAME)" != "" ]; then
				echo -e "${RED}Error: The results of $FILENAME are different from what is expected${NONE}" 1>&2
				#exit 255
			fi
		fi

		echo -e "${GREEN}executed - $FILENAME - with return code [$RESULTCODE]${NONE}"
	fi



	#Delete empty logs
    if [ "$(cat test/log/$FILENAME)" = "" ]; then
		rm test/log/$FILENAME
	fi

	rm -f test/tempDelete.log.txt
done

echo ""
echo "Finished testing."
exit 0
