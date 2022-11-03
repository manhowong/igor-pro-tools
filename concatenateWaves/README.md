# Concatenate waves

This Igor plug-in allows user to select a range of waves and concatenate them into one wave. The concatenated wave will be exported as an ibw file in the current folder.

Man Ho Wong (2022). University of Pittsburgh.

![concAndSavePanel.PNG](concAndSavePanel.PNG)

## Installation

 Requirement: Igor Pro 6.1.2 or above.

 The procedure file can be opened and run directly. If you would like to load the procedure automatically at startup, put the file in the "Igor Procedures" folder. You can also put it in the "User Procedures" folder, and create a procedure file in the "Igor Procedures" folder containing the following line:

    #include "concatenateWaves"

## Input

 The following input variables correspond to the fields "Channel", "Prefix", "From", "To", "Keep Test pulse", "Sampling frequency" and "Test pulse length" in the control panel.

- dfName* : [string] data folder name (i.e. channel name); e.g. "Chan_1"
- prefix* : [string] prefix of wave name; e.g. "sweep"
- firstW : [integer] index of the first wave to include
- lastW: [integer] index of the last wave to include
- keepTP : [1 or 0] 1 to keep test pulse, 0 to remove test pulse
- sFreq : [numeric] sampling frequency in Hz
- tpLen : [numeric] length of test pulse in ms

 *Case-sensitive!

## Output

The concatenated wave will be exported as an ibw file in the current folder with the following file name format:

```
[recording file name]_[channel name]_s[first wave]to[last wave].ibw
```

The concatenated wave will also be displayed on the screen.

## Usage

1. Open the recording file.
2. Open the procedure file "concatenateWaves.ipf", if it is not loaded automatically (See Installation for more info).
3. To concatenate sweep2 to sweep9 of Chan_1 recorded at 20kHz (with the first 200 ms section (test pulses) removed), run the following line in the command window:

```
concAndSave("Chan_1","sweep",2,9,1,20000,200)
```

(Alternatively, enter the input parameters in the control panel and click "Do it".)

To set the default values in the control panel, look for the lines after this line in the procedure file:

```
// default values
```

Change the values to your desired values.


