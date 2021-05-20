#!/usr/bin/env bash

# Functions

function showMenu(){

    local _full_text=${*}
    local _cut_text=${_full_text/:-:0*/}
    local _show

    clear

    echo -e "\n    ${_cut_text}\n"

    for(( _show = 1; _show < ${_full_text: -2}; _show++ )); do

        _full_text=${_full_text/*:-:$(( _show - 1 ))/}
        _cut_text=${_full_text/:-:${_show}*/}
    
        echo -e "\t${txt_green}${_show})${txt_none} ${_cut_text}"
    
    done

    _full_text=${_full_text/*:-:$(( _show - 1 ))/}
    echo -en "\t${txt_red}0)${txt_none} ${_full_text/${_full_text: -2}/}\n\n"

    read -n1 -p "    : " option

    echo -e "\n"

    return 0

}

function pause(){

    local _in

    while [[ -n ${1} ]]; do

        _in=${1}

        if [[ ${1,,} == -*beg* ]]; then
            
            shift
            local _beg_txt=${1}
            shift
            
        fi

        if [[ ${1,,} == -*end* ]]; then

            shift
            local _end_txt=${1}
            shift

        fi

        if [[ ${1,,} == -*t+([0-9]) ]]; then

            local _time=${1,,//-*t/-t}
            shift

        fi

        [[ ${_in} == ${1} ]] && \
            shift

    done

    if [[ -n ${_beg_txt} && -n ${_end_txt} ]]; then
    
        if [[ ${_beg_txt} = 0 ]]; then
            
            clear
            _beg_txt="Empty folder"

        elif [[ ${_beg_txt} = -1 ]]; then
            _beg_txt="Invalid value"
        fi
        
        if [[ ${_end_txt} = 0 ]]; then
            _end_txt="exit"
        elif [[ ${_end_txt} = 1 ]]; then
            _end_txt="continue"
        elif [[ ${_end_txt} = -1 ]]; then
    
            clear
            _end_txt="try again"
    
        fi
        
        read -sn1 ${_time} -p "    ${_beg_txt}, type something to ${_end_txt}. . . " enterKey
    
    else

        read -sn1 ${_time} -p "    Type something to continue. . . " enterKey

    fi

    echo ''
    
    return 0

}

# Variables

# - - Text Style
txt_none="\033[m"           # Normal Text
txt_red="\033[1;31m"        # Cancel/Back
txt_green="\033[1;32m"      # Normal Options
txt_yellow="\033[1;33m"     # Lists
txt_blue="\033[1;36m"       # Keys
txt_bold="\033[1;37m"       # Notes to user

help_text="\n\t  CTF.sh [-d DIR] [-ft PATTERN] [-fn FILE_NAME]\n\n------------------------------------------------------------------\n\n    Description:\n\n\tBasic Command for creating a pdf file using text files.\n\n------------------------------------------------------------------\n\n    Options:\n\n\b\t-d DIRECTORY\tDefines the folders where the files are.\n\n\t-ft FILTER\tCreate filter for files that will be used\n\t\t\tby the program.\n\n\t-fn NAME_FILE\tDefines the name of the file.\n\n\t-silent\t\tDon't show the options for editing the\n\t\t\tlist.\n\n\t-enumerate\tShow enumerates lines of files.\n\n------------------------------------------------------------------\n\n    NOTE:\n\n\tOptions that depend on the passage of a text to the\n\tside, as is the case with -d, -fn, and among many\n\tothers must always be alone or at the end of a set\n\tof arguments, having at most one argument of this\n\ttype at a time.\n\n------------------------------------------------------------------\n\n\t\t\t /-----------------\ \n\t\t\t<| Type Q to quit. |>\n\t\t\t \-----------------/ \n"

# Set Main Variables

# help
[[ `echo ${*} | grep -ci 'help'` == 1 ]] && \
    echo -e "${help_text}" | less && \
    exit 0

# enumerate
[[ `echo ${*} | grep -ci 'enumerate'` == 1 ]] && \
    enumerate=-n

# silent
[[ `echo ${*} | grep -ci 'silent'` == 1 ]] && \
    silent=1

while [[ -n $1 ]]; do

    _in=${1}

    # output dir
    if [[ ${1,,} == -*od* ]]; then
        
        if [[ -z ${output_folder} ]]; then
        
            shift
            output_folder="${1}"
            shift
        
        else

            echo -e "\n   You cannot use more than one parent folder.\n"
            exit 0
        
        fi

    # input dir
    elif [[ ${1,,} == -*d* ]]; then
        
        if [[ -z ${input_folder} ]]; then
        
            shift
            input_folder="${1}"
            shift
        
        else

            echo -e "\n   You cannot use more than one parent folder.\n"
            exit 0
        
        fi

    fi

    # filter
    if [[ ${1,,} == -*ft* ]]; then

        if [[ -z ${filter} ]]; then
        
            shift
            filter="${1}"
            shift

        else

            echo -e "\n   You cannot use more than one filter.\n"
            exit 0
        
        fi

    fi

    # file_name
    if [[ ${1,,} == -*fn* ]]; then
        
        if [[ -z ${file_name} ]]; then
        
            shift
            file_name="${1}"
            shift

        else

            echo -e "\n   You cannot use more than one file name.\n"
            exit 0
        
        fi

    fi

    [[ ${_in} == ${1} ]] && \
        shift

done

unset _in

# Script

clear

# Empty Folder
[[ -z ${input_folder} ]] && \
    read -p "    In which folder do you want to run the program? " input_folder

# Invalid Folder
while [[ ! -d ${input_folder} ]]; do

    clear

    echo -en "    Invalid folder (${txt_yellow}${input_folder}${txt_none}), in which folder do you want to run the program? "
    read input_folder

done;

clear

cd ${input_folder}

# Choose whether or not to filter files
while [[ -z ${filter} && -z ${silent} ]]; do
    
    clear
    
    read -n1 -p '    Do you want to filter the files to be concatenated?(Y/N) ' option

    case "${option,,}" in
            
        y|1)
                
            clear
            
            read -p "    Type the pattern at the beginning of the file or enter? " beg
            
            clear
            
            read -p "    Type the pattern at the end of the file or enter? " end

            filter=${beg}*${end} 

        ;;

        n|0) break ;;
        
        *) pause -beg -1 -end -1 ;;
    
    esac

done

unset option

clear

files=`ls ${filter}`

# Create List of Not Empty Text Files
for f in ${files}; do

    [[ -s ${f} && `file -bi ${f//' '/'?'} | grep -c text` -eq 1 ]] && \
        text_files[${#text_files[@]}]=${f}

done

# edit list (add, remove, continue, exit)
while [[ ${option} -ne 3 && -z ${silent} ]]; do

    showMenu "You will create a pdf with the files:\n\n\t${txt_yellow}${text_files[@]}${txt_none}\n\n    What do you want to do?:-:0Add a new element to the list.:-:1Removes an element from the list.:-:2Continue.:-:3Exit.04"

    case "${option}" in

        # Exit
        0) exit 0 ;;

        # Add
        1)

            clear

            read -p "    Enter the name of the new element: " files

            clear

            [[ -s ${files} && `file -bi ${files//' '/'?'} | grep -c text` -eq 1 ]] && \
                text_files[${#text_files[@]}]=${files} || \
                pause -beg "This item is not a text file or is empty" -end 1
        
        ;;
        
        # Remove
        2)
            
            clear

            if [[ -z ${text_files[*]} ]]; then
                pause -beg "You can't remove files of the list because the text files list is empty" -end 1 -t10

            else

                until
                
                    echo -e "\n    The text files list is:\n"
                    
                    cont=0

                    for a in "${text_files[@]}"; do
                        
                        let cont++

                        echo -e "\t${txt_green}${cont})${txt_none} ${a}"

                    done
                    
                    unset cont
                    
                    echo ''

                    read -p "    Enter the number of the file to be removed from the list: " position
                    
                    [[ ${position} -le 0 || ${position} -gt ${#text_files[*]} ]] && \
                        pause -beg -1 -end -1 && \
                        clear
                
                [[ ${position} -ge 1 && ${position} -le ${#text_files[*]} ]]
                do true ; done

                unset text_files[$(( ${position} - 1 ))]
                read -ra text_files -d '' <<< `echo "${text_files[@]}"`

            fi

        ;;
        
        # Continue
        3)
    
            clear

            [[ -z ${text_files[*]} ]] && \
                pause -beg "You can't continue because there are no itens in the list" -end -1 -t10 && \
                option=5
            
        ;;
        
        # Default
        *) pause -beg -1 -end -1 ;;
    
    esac
    
done

unset option

# Choose whether or not to enumerate the lines in the file
while [[ -z ${enumerate} && -z ${silent} ]]; do
    
    clear
    
    read -n1 -p '    Do you want to display the lines of the numbered files?(Y/N) ' option

    case "${option,,}" in
                
        y|1) enumerate=-n ;;

        n|0) break ;;
        
        *) pause -beg -1 -end -1 ;;

    
    esac

done

unset option

clear

# Choose the File Name
while [[ -z ${file_name} ]]; do
    
    read -p "    What is the file name? " file_name

    if [[ -z ${file_name} ]]; then

        pause -beg -1 -end -1
        clear
    
    fi

done

# Define output folder

while [[ -z ${output_folder} && -z ${silent} ]]; do

    clear

    read -n1 -p '    Do you want to define where the pdf file should be created?(Y/N) ' option

    case "${option,,}" in
                
        y|1)
                
            clear
            
            # Empty Folder
            [[ -z ${output_folder} ]] && \
                read -p "    In which folder do you want to create the pdf file? " output_folder

            # Invalid Folder
            while [[ ! -d ${output_folder} ]]; do

                clear

                echo -en "    Invalid folder (${txt_yellow}${output_folder}${txt_none}), in which folder do you want to create the pdf file? "
                read output_folder

            done;

        ;;

        n|0) break ;;
        
        *) pause -beg -1 -end -1 ;;
    
    esac

done

# Create and edit text file
touch ${file_name}.txt

i=1
for f in ${text_files[@]}; do

    echo -e "ARQUIVO ${i}: ${f}\n" >> ${file_name}.txt 2> /dev/null
    

    cat ${enumerate} ${f} >> ${file_name}.txt 2> /dev/null
    
    echo -e "\n\n\n" >> ${file_name}.txt 2> /dev/null
    
    let i++

done
unset i

# txt2pdf
libreoffice --convert-to pdf ${file_name}.txt &> /dev/null

# Remove Temp File
rm ${file_name}.txt

[[ -n ${output_folder} ]] && \
    mv ${file_name}.pdf ${output_folder// /?} 2> /dev/null

exit 0
