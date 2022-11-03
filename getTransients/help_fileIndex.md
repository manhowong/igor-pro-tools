# Help on creating a file index for getTransients.ipf

## File index format

The text file for the file index should look like this for Windows:

```
name,pxpPath,firstSweep,lastSweep
file1,full\\path\\to\\file1.pxp,0,11
file2,full\\path\\to\\file2.pxp,2,15
file3,full\\path\\to\\file3.pxp,4,7
```

or like this for Mac:

```
name,pxpPath,firstSweep,lastSweep
file1,full/path/to/file1.pxp,0,11
file2,full/path/to/file2.pxp,2,15
file3,full/path/to/file3.pxp,4,7
```

The first line contains the column names (`name`, `pxpPath`, `firstSweep` and `lastSweep`).
Each of the following lines should contain the file name, file path, first sweep ID and last sweep ID, separated by comma. For windows, see [`example_file_index_windows.txt`](example_file_index_windows.txt).

## Generate a list of file paths

To get a list of file paths for all pxp files inside a folder (and its subfolders) automatically, you can use the command shell of your operation system.

For example, in Windows:

1. Open Command Prompt program. (Search Command Prompt in Start Menu or run cmd.exe)

2. Navigate to the target folder in Command Prompt with the following line:

```
cd [full path of the target folder]
```

3. Get file paths of all files ending in .pxp in the target folder and all of its subfolder. Save the output as paths.txt in the same folder:

```
dir/s/b *.pxp > paths.txt
```