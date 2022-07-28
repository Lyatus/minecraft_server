#!/bin/bash

echo This program will destroy world regions that do not lie within a specified range

read -p "X block range: " minx maxx
read -p "Z block range: " minz maxz

echo "Block range: ($minx:$maxx;$minz:$maxz)"

block_to_region () {
	if [ $1 -lt 0 ] ; then
		expr $1 / 512 - 1
	else
		expr $1 / 512
	fi
}

minrx=$(block_to_region $minx)
maxrx=$(block_to_region $maxx)
minrz=$(block_to_region $minz)
maxrz=$(block_to_region $maxz)

echo "Region range: ($minrx:$maxrx;$minrz:$maxrz)"

read -p "Region name: " region

cd world/$region

files_to_delete=()

for file in *.mca ; do
	coords=($(echo $file | sed -E 's|r\.(.+)\.(.+)\.mca|\1 \2|'))
	if [ ${coords[0]} -lt $minrx ] || [ ${coords[0]} -gt $maxrx ] || [ ${coords[1]} -lt $minrz ] || [ ${coords[1]} -gt $maxrz ] ; then
		files_to_delete+=($file)
		echo Would delete $file
	else
		echo Would keep $file
	fi
done

echo About to delete ${#files_to_delete[@]} files

read -p "Confirm (y/n): " confirmation

if [[ $confirmation =~ ^[Yy]$ ]] ; then
	for file in ${files_to_delete[*]} ; do
		echo Deleting $file...
		rm $file
	done
	echo All done!
fi
