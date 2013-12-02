#!/bin/sh

#  gendir.sh
#
#
#  Created by Fernando Canon on 11/11/13.
#
#	Gendic generates a dictionary from a file or list of files, specified as command line arguments.
#	Gendic also is capable of generating a dictionary from written text on the stdinput .
#	The dictionary is sorted in alphabetical order, the words ocurrence is defined as only one
# 	by each repetition of a word. A word is consider to be a secuence of character whithin the range
#	[a-z]. Case is ignored, meaning that result will be outputed in lowercase.
#	The output file, must be specified as the first argument of the script.
#


#CONSTANTS and errors based in http protocol 1xx 2xx 3xx 4XX but in the rage of [0 -255]
ERROR_NO_INPUTFILE=44
ERROR_NO_OUTPUTFILE=40
ERROR_NO_READABLE_FILE=43
OK=200
ERROR_FILE_NOT_WRITABLE=50
ERROR_FILE_NOT_READABLE=53
INTERNALSTATE=102

#VARIBLES
_DEBUG="off"
TMPPATH="$( mktemp -d /tmp/gendir.XXXXXXX )"
TMPORALFILE=$TMPPATH"/tmp.txt"
TMPFILE=$TMPPATH"/tmp2.txt"
RETURNVALUE=0
OUTPUTFILE=''

#helper functions

#DEBUG this fuction helps the script in case of debuggin. To turn on you must set _DEBUG="on". I will not delete it 
# becouse it´s very usefull. For evaluation purpuse , i belive it might help to understand how i develop gendic
DEBUG () {

	if [ "$_DEBUG" = "on" ]; then
		$@
	fi
}


echoToSterr () {
	
	echo "$@" 1>&2
}


isFileAvailable () {

	if [ -f "$@" ] ; then

		if [ -r "$@" ]; 
			then
			DEBUG echoToSterr "Read permission is granted on $@"
			return $OK
		else
			DEBUG echoToSterr "Read permission is NOT granted on $@"
			echoToSterr "read permision not avaible"
			return $ERROR_NO_READABLE_FILE
		fi
	else
		DEBUG echoToSterr "out file does not exists"
		return $ERROR_NO_INPUTFILE
	fi
}


usage () {
	
	echo "This script generates a directories listed in a file"
	echo "  Usage: gendir.sh [-h | -v] outputfile inputfile ..."
}

variant () {
	
	echo "8"
}

# this is the heart of the script, where the words are sorted out to create a dictionary.
proccesText () {

	TMPFILE=$(cat "$@") 

	if [ -f "$OUTPUTFILE" ]; then
		TMPVAROUT=$(cat "$OUTPUTFILE") 
		TMPFILE="$TMPVAROUT --- --- ---- $TMPFILE"
	fi
	echo "$TMPFILE" | tr [:upper:] [:lower:] | sed  's/[^a-z]/ /g' |  tr "\"' " '\n' | tr -d -c 'a-z\n' | sort | sed '/^$/d'  |  uniq > "$OUTPUTFILE" 
}



processArgument () {

	isFileAvailable "$@"
	if [ $? -eq 200 ];then
		proccesText "$@"
		return $OK;
	else
		echoToSterr "File not found: $@"
		return $ERROR_NO_INPUTFILE;
	fi
}



testWritingToOutputFile () {

if [ -f "$OUTPUTFILE" ]; then

	if [ -w "$OUTPUTFILE" ]
		then
		DEBUG echoToSterr "Write permission is granted on $OUTPUTFILE"
	
		echo "" > "$OUTPUTFILE"
	else
		DEBUG echoToSterr "Write permission is NOT granted on $OUTPUTFILE"
		cleanTheGarbage;
		echoToSterr "Write permision not avaible"
		exit 1
	fi

else

	DEBUG echoToSterr "out file does not exists"

	 dirbase="$(dirname "$OUTPUTFILE")"
	 if [ -w "$dirbase" ]; then
	 	DEBUG echoToSterr "you  have p. in $dirbase" 		
	 else
	 	echoToSterr "you dont have permsions to write in $dirbase" 
	 	cleanTheGarbage;
	 	exit 1
	 	
	fi
fi
}



processNextArguments () {

	VAL=0
	if  [ "$OUTPUTFILE" = '' ];
		then
		DEBUG  echoToSterr " In 1 "
		OUTPUTFILE="$@" 
		testWritingToOutputFile	 
	else
		DEBUG  echoToSterr " In 2 "
		processArgument "$@"
		VAL=$?
	fi

	return $VAL;
}



programErrorControl ()
{
	DEBUG  echoToSterr "programErrorControl received $1"
	case $1 in
		$ERROR_NO_OUTPUTFILE )
		INTERNALSTATE=$ERROR_NO_OUTPUTFILE
		;;
		$ERROR_NO_INPUTFILE )
		if [ $INTERNALSTATE -eq 102  ]; then
			DEBUG  echoToSterr "File not found"
			INTERNALSTATE=$ERROR_NO_READABLE_FILE	
		else
			INTERNALSTATE=$ERROR_NO_INPUTFILE
		fi
		;;
		$OK )
			if [ $INTERNALSTATE -eq $ERROR_NO_READABLE_FILE ]; then
			INTERNALSTATE=$ERROR_NO_INPUTFILE
			fi	
		;;
		
	esac
	DEBUG  echoToSterr "code $INTERNALSTATE"	
}



finalReturnValue ()
{
	RETURNVAL=0
	case $INTERNALSTATE in
		$ERROR_NO_OUTPUTFILE | $ERROR_NO_READABLE_FILE ) RETURNVAL=3
		;;
		$ERROR_NO_INPUTFILE ) RETURNVAL=2
		;;
	esac

return $RETURNVAL;
}



processStdinput () {

	while read input; do
		clearin=$( echo $input | tr -d '\n' )
		echo "$clearin" 1> "$TMPORALFILE"
		proccesText "$TMPORALFILE"
	done


}

cleanTheGarbage () {

	#[ -e "$TMPPATH""/""$OUTPUTFILE" ] && cat "$TMPPATH""/""$OUTPUTFILE" 1>&2 ;
	DEBUG echo "removing $TMPPATH"
	rm -Rf $TMPPATH
}


############################## Entry point For Execution 
if [ $# -eq 0 ];then
	programErrorControl $ERROR_NO_OUTPUTFILE
	echoToSterr "No Output file especified. Try -h for help"
fi

if [ $# -eq 1 ];then
	STDIN="YES"
fi
	

while [ "$1" != "" ]; do

	case "$1" in
		-v )    variant
				cleanTheGarbage 
				exit 0
		;;
		-h | --help )       
			usage
			cleanTheGarbage
			exit $RETURNVALUE
		;;
		-* ) usage
		cleanTheGarbage
		exit 0
		;;
		* )
			if [ "$STDIN" = "YES" ];then
				DEBUG echo "STDIN = YES"
				OUTPUTFILE="$@"
				testWritingToOutputFile	
				processStdinput
			else
				processNextArguments "$1"
				programErrorControl $?
			fi
		;;
	esac
	shift
done

cleanTheGarbage

finalReturnValue
RETURNVALUE=$?

DEBUG  echoToSterr "code $RETURNVALUE"
exit $RETURNVALUE
