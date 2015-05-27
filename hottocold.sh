#!/usr/bin/bash

#set varialbes
BITCOINCLI="bitcoin-cli"
MINIMUM_TO_KEEP=0.1
RECEIVERS_ADDRESS=mxkdysskdhfiwrslfrandomtestaddress

timestamp=$( date +%D-%T )
#echo $timestamp: bitcoin-cli executable is: $BITCOINCLI

#create temporary files that are used to store output of executed command
tempOutput=$(mktemp)
tempOutputErr=$(mktemp)

#getbalance
"$BITCOINCLI" getbalance > "$tempOutput" 2> "$tempOutputErr"

outputsize=$(wc -c "$tempOutput" | cut -f 1 -d ' ')
if [ $outputsize -ge 1 ]; then
balance=$(cat ${tempOutput})
else
balance=XYZ
echo $timestamp: "Error: Could not connect to server. Or some other error while tring to find balance. " 
rm "$tempOutput" "$tempOutputErr"
exit
fi

echo $timestamp: Balance is "$balance"

sendamount=$(echo " $balance  $MINIMUM_TO_KEEP  - p" | tr '\n\r' ' ' | dc  | tr '-'  '_' )


comparison_result=$(echo " 1 sa 0 sb lb  $sendamount 0  <a p " | tr '\n\r' ' ' | dc) 
#echo $timestamp: sendamount = $sendamount
#echo $timestamp: comparison result = $comparison_result x 

#rm "$tempOutput" "$tempOutputErr"
#exit 

#echo comp = "$comp"  x
if [ "$comparison_result" -gt 0 ]; then
    echo $timestamp: "Balance is greater than the amount to be kept, which is $MINIMUM_TO_KEEP"
    echo $timestamp: Sending "$sendamount" BTC to the address "$RECEIVERS_ADDRESS"
    "$BITCOINCLI" sendtoaddress $RECEIVERS_ADDRESS $sendamount > "$tempOutput" 2> "$tempOutputErr"
    outputsize=$(wc -c "$tempOutputErr" | cut -f 1 -d ' ')
    if [ $outputsize -ge 1 ]; then
        echo $timestamp: Error while executing sendtoaddress. Could not send the amount. The error is:
        cat "$tempOutputErr"
    else
        echo $timestamp: "sent $sendamount bitcoins successfully."
    fi
else
    echo $timestamp: "Not sending any bitcoins because balance is less than $MINIMUM_TO_KEEP"
fi

rm "$tempOutput" "$tempOutputErr"

