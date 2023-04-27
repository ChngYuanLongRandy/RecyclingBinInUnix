#! /bin/bash

####################################
###             restore         ####
####################################
<<Introduction

This is the restore script that complements the recycle script.
Restores the filepath as prompted by user. Filename provided
must match the .restore.ino. Restore also removes the entry of the
filename once restored

Options
- r -> recursive. Enables restoration of directory
- h -> help menu. Brings up help menu (Currently wip)

Usage
bash restore [FILE]
bash restore -r [FILE or DIR]

This script does not support multiple files

Introduction

####################################
###             variables       ####
####################################

recyclingBinPath=$HOME/recyclebin
restoreInfoPath=$HOME/.restore.info
restoreFilesNames="$(cut -d ':' -f1 .restore.info )"
restoreFilesOriginalPath="$(cut -d ':' -f2 .restore.info)"
me=$(basename ${0})
recursive_setting=false

####################################
###             checks          ####
####################################

# Display all erros
function displayError() {
        echo "${me}:${1}" 1>&2
        exit 1
}

# Checks whether the filename given in the arugment exists

function checkValidFileName() {
        # if file is not found
        if grep -q $1: $restoreInfoPath
        then
                return 0
        else
                displayError 'invalid file name'
        fi
}


# checks for argument and displays err msg if incorrect number
function checkArgument() {

        if [ ! ${#@} -eq 1 ]
        then

                displayError 'Please enter only 1 filename'

        fi

}

####################################
###             Functions       ####
####################################

function returnFileOriginalPath() {
        restoreFileOriginalPath="$( grep $1 .restore.info | cut -d ':' -f2 )"
        echo $restoreFileOriginalPath
}


# Restores file
function restoreFile() {

        mv $1 $2
}


# checks if restoreFileOriginalPath exists (file can be overwritten)
# returns 0 if no overwrite or overwrite is authorised
# returns 1 if overwrite is not authorised
function checkFileOriginalPath() {
        # path exists
        if [ -e $(returnFileOriginalPath "$1" ) ]
        then
                read -p "Do you want to overwrite? y/n " overWriteVar

                case $overWriteVar in

                        [Yy]*)
                                return 0
                                ;;
                        * )
                                return 1
                                ;;
                esac
        else

                return 0

        fi

}

# Process the options from user
# accepted option is only r for recursive
function processOptions() {

        while getopts :r opt
        do
                case ${opt} in
                'r')    recursive_setting=true
                        ;;

                *)      echo "invalid option -- ${OPTARG}" >&2
                        exit 1
                        ;;
                esac
        done
}

# Delete Entry in .restore.info file
function deleteEntry(){

        grep -v $1: $restoreInfoPath >> .temp
        rm $restoreInfoPath
        mv .temp $restoreInfoPath

}


####################################
###             MAIN            ####
####################################

processOptions $*
shift $(( $OPTIND - 1 ))

checkArgument $@
checkValidFileName $1

# if original path contains a directory check if recurisve_setting is true, otherwise throw error
# if so, mkdir -p then run restore script

if [[ "$(checkFileOriginalPath $1)" -eq 0 ]]
then
        if [ $recursive_setting = 'true' ]
        then

                dirfolder=$(returnFileOriginalPath "$1")

                dir=$(dirname $dirfolder)

                mkdir -p $dir

                restoreFile $recyclingBinPath/$1 $(returnFileOriginalPath "$1" )
                deleteEntry $1

        else

                restoreFile $recyclingBinPath/$1 $(returnFileOriginalPath "$1" )
                deleteEntry $1
        fi
else
        echo "No overwrite"
        exit 1


fi
                                   
