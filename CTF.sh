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

    echo ''

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
            
            clear && echo ''
            _beg_txt="Empty folder"

        elif [[ ${_beg_txt} = -1 ]]; then
            _beg_txt="Invalid value"
        fi
        
        if [[ ${_end_txt} = 0 ]]; then
            _end_txt="exit"
        elif [[ ${_end_txt} = 1 ]]; then
            _end_txt="continue"
        elif [[ ${_end_txt} = -1 ]]; then
    
            clear && echo ''
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

# Script

clear

main_folder=${*}

# Empty folder
[[ -z ${main_folder} ]] && \
    read -p "    In which folder do you want to run the program? " main_folder

# Invalid folder
while [[ ! -d ${main_folder} ]]; do

    clear

    echo -en "    Invalid folder (${txt_yellow}${main_folder}${txt_none}), in which folder do you want to run the program? "
    read main_folder

done;

clear



exit 0;