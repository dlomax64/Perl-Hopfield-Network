# Install Requirements

## apt-get
`apt-get install perl`<br>
`apt-get install libgd-graph-perl`<br>
`apt-get install libtext-csv-perl`<br>
`apt-get install libstatistics-basic-perl`<br>

# Instructions

## hopfield.pl
This is the main program that will do a single run when called directly

### How to use
hopfield.pl takes several arguments in this order:
- N - ***default is 100 if not supplied***
- P - ***default is 50 if not supplied***
- filename for output data - ***default is run_data is not supplied***

### To call hopfield with the default parameters:<br>
`perl hopfield.pl`<br>

### To call hopfield with arguments:
> `perl hopfield.pl -a <N> <P> <filename>` ***must be specified in that order***<br>
Example: `perl hopfield.pl -a 100 50 output`

---

## run_mult.pl
This script runs hopfield X times ***where X <= 10***


### How to use
**run_mult.pl takes several arguments in this order:**
- Number of runs - ***for runtime reasons I limited this to <= 10. Default is 5 if not supplied***
- N - ***default is 100 if not supplied***
- P - ***default is 50 if not supplied***
- filename for output data of each run - ***default is run{run#}***
- filename for the congregation of the data - ***will not be called if not supplied***

**To call run_mult with the default parameters:**<br>
> `perl run_mult.pl`<br>

**To call run_mult with arguments:**<br>
> `perl run_mult.pl -a <Number of runs> <N> <P> <filename> <congregation filename>`<br>
Example: `perl run_mult.pl -a 5 100 50 run all`

---

## congregate.pl
This script is called by run_mult and should not be called directly

### Info on congregate:
Congregate will take all the output files made by hopfield and congregate that data into one file and produced a congregated graph of all runs for stable imprints and unstable fractions ***congregate deletes the indvidual files and graphs produced by hopfield***