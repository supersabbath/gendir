gendir
======
A Script to generate a dictionary of words from a text file or stdin. It also could be used to joint two different lists of words in different files. The results will be written to the output file (mandatory first argument), alphabetically ordered and each word will be unique:

Usage:
  gendir.sh [-h | -v] outputfile inputfile ...

example:
```
./gendir output_file.txt inputfile.txt anotherinput.html anytextfile 
```

You can also use it to joint words from the stdinput:
i.e.: 
```
bash gendir.sh  outputfile 
 
 type some text it
 more text to at
```
 result in out.txt:
```
at
it
more
some
text
to
type
``` 
 
