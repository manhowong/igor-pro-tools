# Get transients

This procedure extracts the capacitance transients of every recording file listed in a file index provided by user.

Man Ho Wong (2022). University of Pittsburgh.

## Compatibility

This procedure was tested with Igor Pro 6.2.2.2 in Windows. Text files created on Mac or Linux may not be compatible because of different line terminators. Users can change the line terminator if needed.

## Files needed

- recording files in .pxp format
- file index: a .txt file containing the following 4 columns with the same column names and contents:
- name (recording name/ID, without file extension name!)
- pxpPath (FULL path of recording file in pxp format)

    For Windows: escape backslash in the path (i.e. replace every " \ " with two " \ ")

- firstSweep (integer number)
- lastSweep (integer number)

    (firstSweep and lastSweep specify the range of sweeps from where the transients will be extracted)

    See [help_fileIndex.md](help_fileIndex.md) for for more info.

## Output

For each recording file, the procedure generates a text file containing a matrix where each column represents a transient from a sweep. Files are saved in an user-specified folder.

## Usage

1. Generate the required file index text file as mentioned above.
2. Complete the user settings section below.
3. Run the folloing line in the command window: 

    ```
    getTransients()
    ```

4. When prompted, select a folder to save the output files.