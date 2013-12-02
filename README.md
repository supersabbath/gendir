gendir
======

Script to generate a dictionary from a text file or stdinput. it could be  use to joint two different list of words.
each word will be unique on the ouput list:

Usage:
  gendir.sh [-h | -v] outputfile inputfile ...

example:
./gendir output_file.txt inputfile.txt anotherinput.html anytextfile 


You can also use it to joint words from the stdinput:
i.e. 
  gendir.sh  outputfile 
>type one text it
>more text to at
 result in out.txt:

at
it
more
one
text
to
type
 
 
