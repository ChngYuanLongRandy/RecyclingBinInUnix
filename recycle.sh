#! /bin/bash

####################################
###             recycle         ####
####################################

<<Introduction

This is the recycle script that is meant to replicate rm's functionality.
But instead of deleting them to oblivion, we chuck them into a recycle
folder with the results stored into a hidden file called .restore.info



Options
- i -> interactive. Prompts user for confirmation
- r -> recursive. Enables deletion of directory
- v -> verbose. Provides confirmation once deletion is done


Usage
bash recycle [OPTIONS] [FILES]
bash recycle -r [FILES or DIRS]

Introduction

####################################
###             Variables       ####
####################################

recyclingBinPath=$HOME/recyclebin
restoreInfoPath=$HOME/.restore.info
restoreFilePath=$HOME/project/restore
me=$(basename ${0})
interactive_setting=false
verbose_setting=false
recursive_setting=false

####################################
###             Functions       ####
####################################

# checks if recyclingBin exists and creates it if it doesn't
# no args
function createRecyclingBin() {

        if [ ! -e $recyclingBinPath ]
        then
                mkdir $recyclingBinPath
        fi

}
<<checks
echo $recyclingBinPath
echo $scriptPath
echo $@
echo ${#@}
echo $0
checks

# recycles a file
# arg1: filename to be recycled
function recycleFile() {

        inode=$(ls -li $1 | cut -d ' ' -f1)
        newRecycleFileName=$1_$inode
        newRecycleFileName=$(basename "$newRecycleFileName" )
        mv $1 $recyclingBinPath/$newRecycleFileName
}

                                                                                                                
# recycles a dir
# arg1: dirname to be recycled
function recycleDir() {

        fnames=$( find $1 -type f )
        dirnames=$( find $1 -type d )

        for fname in $fnames
        do
                if [ $interactive_setting = 'true' ]
                then
                        interactiveRecycleFile $fname
                        if [ $verbose_setting = 'true' ]
                        then
                                echo 'File Deleted '
                        fi
                else
                        recycleFile $fname
                        appendRestore $newRecycleFileName $HOME/$fname
                fi

        done

        for dirname in $dirnames
        do

                rmdir $dirname

        done
}

# insert details to restore file
# arg1: Name of file
# arg2: Recycled Path of file
function appendRestore() {

        echo $1:$2 >> $restoreInfoPath

}

# Process the options from user
# accepted options are h i r and v
function processOptions() {

        while getopts :hirv opt
        do
                case ${opt} in
                'i')    interactive_setting=true
                        ;;

                'v')    verbose_setting=true
                        ;;

                'r')    recursive_setting=true
                        ;;

                *)      echo "invalid option -- ${OPTARG}" >&2
                        exit 1
                        ;;
                esac
        done
}

# recyclefiles interactively
# arg1: name of recycle file
function recycleDir() {

        fnames=$( find $1 -type f )
        dirnames=$( find $1 -type d )

        for fname in $fnames
        do
                if [ $interactive_setting = 'true' ]
                then
                        interactiveRecycleFile $fname
                        if [ $verbose_setting = 'true' ]
                        then
                                echo 'File Deleted '
                        fi
                else
                        recycleFile $fname
                        appendRestore $newRecycleFileName $HOME/$fname
                fi

        done

        for dirname in $dirnames
        do

                rmdir $dirname

        done
}

# insert details to restore file
# arg1: Name of file
# arg2: Recycled Path of file
function appendRestore() {

        echo $1:$2 >> $restoreInfoPath

}

# Process the options from user
# accepted options are h i r and v
function processOptions() {

        while getopts :hirv opt
        do
                case ${opt} in
                'i')    interactive_setting=true
                        ;;

                'v')    verbose_setting=true
                        ;;

                'r')    recursive_setting=true
                        ;;

                *)      echo "invalid option -- ${OPTARG}" >&2
                        exit 1
                        ;;
                esac
        done
}

# recyclefiles interactively
# arg1: name of recycle file
function interactiveRecycleFile() {

        read -p "Recycle file $1 ?" recycleAns

        # If user entry starts with a 'Y' then "yes",
        # otherwise "no"
        case $recycleAns in
                [Yy]* )
                        recycleFile $1
                        appendRestore $newRecycleFileName $HOME/$1
                        ;;

                *)
                        return 1
                        ;;
        esac


}

####################################
###             CHECKS          ####
####################################

# Display all error
# arg1: error message
function displayError() {
        echo "${me}:${1}" 1>&2
        exit 1
}

# Does not allow recycling of the restore script
# arg1: recycle file name
function checkRecycleRestore() {

        if [ $restoreFilePath = $1 ]
        then
                displayError "Do not recycle restore script. Please enter a valid Recycle File Path"

        fi
}



# checks if files exists
# arg1: recycle file name
function checkFileExist() {

        if [ ! -e $1 ]
        then
                displayError "File not found. Please enter a valid Recycle File Path"

        fi
}

# checks if selected file is valid
# arg1: recycle file name
function validateFile() {

        if [ $1 = $0 ]
        then
                displayError 'Please do not select this script. Kindly enter a valid Recycle File Path'

        fi
}

# checks if the file path is a directory
# arg1: recycle file name
function checkIfDir() {

        if [ -d $1 ]
        then
                displayError 'Please enter option -r to remove directories'
        fi

}

# checks if any argument entered
function checkArgs() {

        if [ "$#" -eq 0 ]
        then
                displayError 'Please enter filename'
        fi

}

####################################
###             MAIN            ####
####################################

processOptions $*
shift $(( $OPTIND - 1 ))

checkArgs $*
createRecyclingBin

for fname in $@
        do
                if [ $recursive_setting = 'false' ]
                then

                        checkFileExist $fname
                        validateFile $fname
                        checkIfDir $fname

                        if [ $interactive_setting = 'true' ]
                        then
                                interactiveRecycleFile $fname
                                if [ $verbose_setting = 'true' ]
                                then
                                        echo 'File Deleted '
                                fi
                        else
                                recycleFile $fname
                                appendRestore $newRecycleFileName $HOME/$fname
                        fi

                # For recursive, no need to check if dir
                else

                        checkFileExist $fname
                        validateFile $fname

                        # if file is a directory, use recycle on all files inside
                        if [ -d $fname ]
                        then

                        recycleDir $fname



                        # file is not a directory
                        else

                                if [ $interactive_setting = 'true' ]
                                then
                                        interactiveRecycleFile $fname
                                        if [ $verbose_setting = 'true' ]
                                        then
                                                echo 'File Deleted '
                                        fi
                                else
                                        recycleFile $fname
                                        appendRestore $newRecycleFileName $HOME/$fname
                                fi
                        fi

                fi

        done
