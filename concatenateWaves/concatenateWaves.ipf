#pragma rtGlobals=1		// Use modern global access method.
// This Igor plug-in allows user to select a range of waves and concatenate
// them into one wave. The concatenated wave will be exported as an ibw file
// in the current folder.
// Man Ho Wong (2022). University of Pittsburgh.
//
// Installation:
//  Requirement: Igor Pro 6.1.2 or above.
//  The procedure file can be opened and run directly. If you would like to
//  load the procedure automatically at startup, put the file in the
//  "Igor Procedures" folder. You can also put it in the "User Procedures"
//  folder, and create a procedure file in the "Igor Procedures" folder
//  containing the following line:
//  #include "concatenateWaves"

// Input:
//  The following input variables correspond to the fields "Channel", "Prefix",
//  "From", "To", "Keep Test pulse", "Sampling frequency" and
//  "Test pulse length" in the control panel.
//
// 	dfName* : [string] data folder name (i.e. channel name); e.g. "Chan_1"
// 	prefix* : [string] prefix of wave name; e.g. "sweep"
//	firstW : [integer] index of the first wave to include
//  lastW: [integer] index of the last wave to include
// 	keepTP : [1 or 0] 1 to keep test pulse, 0 to remove test pulse
//	sFreq : [numeric] sampling frequency in Hz
//	tpLen : [numeric] length of test pulse in ms
//  *Case-sensitive!
//
// Output:
//	The concatenated wave will be exported as an ibw file in the current
//  folder with the following file name format:
//  [recording file name]_[channel name]_s[first wave]to[last wave].ibw
//  The concatenated wave will also be displayed on the screen.
//
// Usage:
//  1. Open the recording file.
//  2. Open the procedure file "concatenateWaves.ipf", if it is not loaded
//     automatically (See Installation for more info).
//  3. To concatenate sweep2 to sweep9 of Chan_1 recorded at 20kHz (with the
//     first 200 ms section (test pulses) removed), run the following line in 
//     the command window:
//     		concAndSave("Chan_1","sweep",2,9,1,20000,200)
//     (Alternatively, enter the input parameters in the control panel and 
//      click "Do it".)
//   To set the default values in the control panel, look for the line:
//   "default values" in the procedure file and change the values there.
//
//-----------------------------------------------------------------------------
//
// add procedure to the menu "Data"
Menu "Data"
	"Concatenate waves.../1", MakeConcAndSavePanel()
	// The suffix "/1" assigns Ctrl + 1 as the shortcut key
end

// create panel
Function MakeConcAndSavePanel() : Panel
	SetDataFolder "root:"
	// default values	
	String/G prefix="sweep"
	Variable/G firstW
	Variable/G lastW
	string/G dfName="chan_1"
	Variable/G sFreq=20000
	Variable/G tpLen=200
	Variable/G keepTP

	NewPanel /K=1 /W=(500,150,950,330) /N=ConcAndSavePanel as "Concatenate waves"
	SetActiveSubwindow ConcAndSavePanel
	
	DrawText 15,29,"Please indicate the range of waves to be concatenated."
	SetVariable dfNameInput title=" Channel (or Igor \"Data Folder\") "
	SetVariable dfNameInput size={420,24},pos={15,34},value=dfName,fSize=16
	SetVariable dfNameInput fColor=(65535,65535,65535),labelBack=(0,0,0)

	SetVariable prefixInput title=" Wave Prefix ",size={203,24},bodyWidth=108
	SetVariable prefixInput value=prefix,fSize=16,fColor=(65535,65535,65535)
	SetVariable prefixInput pos={15,70},labelBack=(0,0,0)

	SetVariable firstWInput title=" From ",size={100,24},value=firstW
	SetVariable firstWInput limits={0,inf,1},fSize=16,fColor=(65535,65535,65535)
	SetVariable firstWInput pos={240,70},labelBack=(0,0,0)

	SetVariable lastWInput title=" To ",size={83,24},bodyWidth=53,value=lastW
	SetVariable lastWInput limits={0,inf,1},fSize=16,fColor=(65535,65535,65535)
	SetVariable lastWInput pos={353,70},labelBack=(0,0,0)

	SetVariable sFreqInput title=" Sampling frequency (Hz) ",size={275,24}
	SetVariable sFreqInput value=sFreq,limits={0,inf,0},fSize=16
	SetVariable sFreqInput pos={15,105},fColor=(65535,65535,65535),labelBack=(0,0,0)
	
	SetVariable tpLenInput title=" Test pulse length (ms) ",size={275,24}
	SetVariable tpLenInput value=tpLen,limits={0,inf,0},fSize=16
	SetVariable tpLenInput pos={15,138},fColor=(65535,65535,65535),labelBack=(0,0,0)

	CheckBox keepTP title="Keep test pulse",size={128,20},pos={307,105},variable=keepTP,fSize=16

	Button doit title="Do it",size={128,35},pos={308,128},proc=Button_doit,fSize=16

End

// Button action
Function Button_doit(ctrlName) : ButtonControl
	String ctrlName
	// If the function "concAndSave" was called before, the data folder may be
	// set to the specified channel. To ensure "Button_doit" works, we need to
	// set the data folder to root, so that the global variables stored in the
	// root can be accessed. 
	SetDataFolder "root:"
	SVAR dfName, prefix
	NVAR firstW, lastW, keepTP, sFreq, tpLen
	concAndSave(dfName,prefix,firstW,lastW,keepTP,sFreq,tpLen)

End

// concatenate waves and export 
Function concAndSave(dfName,prefix,firstW,lastW,keepTP,sFreq,tpLen)
	String dfName, prefix
	Variable firstW, lastW, keepTP, sFreq, tpLen
	Variable tpEndPt = sFreq*tpLen/1000
	
	// set current data folder to the specified channel
	String currFolder="root:"+dfName
	SetDataFolder currFolder
	
	// Create new empty waves to store the concatenated wave and overwrite
	// existing ones to clear data from the last processed file
	Make/O/N=0 concWave
	
	// set the scales of 'concWave'
	//Variable sIntvl = 1/sFreq
	SetScale /P x, 0, (1/sFreq), "s", concWave
	SetScale /P d, 0, 0, "pA", concWave
	
	Variable idx
	for (idx=firstW; idx<=lastW; idx+=1)
		// Construct current wave name and copy wave data to a temporary wave
		String currWave = prefix + num2str(idx)
		Wave temp = $currWave	
		// remove test pulse in wave if needed
		if(keepTP==0)
			DeletePoints 0,tpEndPt, temp
		endif
		// Concatenate
		Concatenate/NP=0 {temp}, concWave
	endfor
	
	Display concWave
	
	// save ibw file the in current folder	
	string fileName=IgorInfo(1)+"_"+dfName+"_s"+num2str(firstW)+"to"+num2str(lastW)
	Save/C/P=home concWave as fileName+".ibw"
	return concWave
End