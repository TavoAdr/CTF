## About the Project

Concatenating text files and converting them to PDF files or just ctf is a simple tool made in Shell Script (aimed at linux) that can help you to concatenate multiple files into a single PDF file.

## How to Use

To run CTF.sh, you must allow the file to run, which can be done through your file manager's permission settings or by the command `chmod a+x CTF.sh` so that all users can run it or `chmod u+x CTF.sh` so that only you can run it and install **enscript** and **ps2pdf** if you don't have it on your computer..

After that, you can run the program in two ways, the first one by calling its path and program name from the terminal (`path/CTF.sh`) or clicking on run, on the file manager and the second called one folder next to your path (only in the terminal), with the difference of these two cases the possibility of using variables and others like `~`, `./` and `../` to call the directory in the second case, while in the first case, you must pass the full path or at most `./` and `../`, but the use of ~ and global variables will not be possible.

**Never call directories with spaces in their name, this can cause errors during the execution of the program.**

The program can be executed simply by calling it without informing anything, or with the aid of arguments like -d to define the directory where the files are, -fn to define the name of the final file among others that can be seen using the argument -help.
