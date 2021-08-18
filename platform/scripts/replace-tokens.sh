#!/usr/bin/env bash

subFolder=$1
fileName=$2
find=($3 $5 $7)
replace=($4 $6 $8)

mkdir -p $subFolder/config
        
cp $subFolder/$fileName $subFolder/config/$fileName

for i in ${!find[@]}; do
    perl -pi -w -e "s|${find[$i]}|${replace[$i]}|g;" $subFolder/config/$fileName
done
    


