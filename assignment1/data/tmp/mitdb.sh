#!/bin/bash
#Uncomment one of the following server lines to select the server
#See the list of available mirors at:  http://physionet.mit.edu/mirrors/
SERVER=http://www.physionet.org/physiobank/database/mitdb/
#SERVER=http://lbcsi.fri.uni-lj.si/ltstdb/mitdb/
#SERVER=http://physionet.cps.unizar.es/physiobank/database/mitdb/

# The MIT-BIH Arrhythmia Database contains 48 half-hour excerpts of two-channel ambulatory ECG recordings
RECORDS="
100 101 102 103 104 105 106 107 108 109
111 112 113 114 115 116 117 118 119 121
122 123 124 200 201 202 203 205 207 208
209 210 212 213 214 215 217 219 220 221
222 223 228 230 231 232 233 234"

for r in $RECORDS
do
#	Use these lines for download with progress indication
	echo "Downloading .hea file for for record $r ..."
	wget -c --progress=dot $SERVER$r".hea" 2>&1 | grep --line-buffered "%" | sed -u -e "s,\.,,g" | awk '{printf("\b\b\b\b%4s", $2)}'
    echo "Downloading .atr file for for record $r ..."
    wget -c --progress=dot $SERVER$r".atr" 2>&1 | grep --line-buffered "%" | sed -u -e "s,\.,,g" | awk '{printf("\b\b\b\b%4s", $2)}'
#	echo "Downloading .dat file for for record $r ..."
#	wget -c --progress=dot $SERVER$r".dat" 2>&1 | grep --line-buffered "%" | sed -u -e "s,\.,,g" | awk '{printf("\b\b\b\b%4s", $2)}'
#	Use these lines for quiet dowload
#	wget -q --progress=bar:force -c $SERVER$r".hea"
#	wget -q --progress=bar:force -c $SERVER$r".atr"
#	wget -q --progress=bar:force -c $SERVER$r".dat"

	# echo "Converting recording to Matlab format ..."
	# wfdb2mat -r $r 1>&- 2>&-
	# echo "--------------------------------------------------"
done
