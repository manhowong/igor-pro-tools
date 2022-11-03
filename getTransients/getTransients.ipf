#pragma rtGlobals=1		// Use modern global access method.

// This procedure extracts the capacitance transients of every recording file listed
// in a file index provided by user.
// Man Ho Wong (2022). University of Pittsburgh.
//
// Files needed:	- recording files in .pxp format
//					- file index: a .txt file containing the following 4 columns
//					  with the same column names and contents:
//					- name (recording name/ID, without file extension name!)
//					- pxpPath (FULL path of recording file in pxp format)
//                    For Windows: escape backslash in the path (i.e. replace \ with \\)
//					- firstSweep (integer number)
//					- lastSweep (integer number)
//					(firstSweep and lastSweep specify the range of sweeps from
//					 where the transients will be extracted)
//					See help_fileIndex.txt for for more info.
//
// Output:
//	For each recording file, the procedure generates a text file containing a
//	matrix where each column represents a transient from a sweep. Files are 
//	saved in an user-specified folder.
//
// Usage:
//  1. Generate the required file index text file as mentioned above.
//	2. Complete the user settings section below.
//	3. Run the folloing line in the command window:
//	   getTransients()
//	4. When prompted, select a folder to save the output files.
//
// Compatibility:
//  This procedure was tested with Igor Pro 6.2.2.2 in Windows.
//	Text files created on Mac or Linux may not be compatible because of
//	different line terminators. Users can change the line terminator if needed.

//------------------------------------------------------------------------------
function getTransients()

	// User Settings
	
	// Location of the file index text file (see above)
	//   For Windows: escape backslash in the path (i.e. replace \ with \\)
	String idxPath = "C:\\path\\to\\fileIndex.txt"

	// Recording file information
	String dfName = "Chan_1" // name of Igor "data folder" containing the sweeps (usually the channel name)
	String prefix = "sweep"  // sweep prefix (e.g. for "sweep1", "sweep2", etc, the prefix is "sweep")
	Variable sFreq = 20000   // sampling frequency, Hz
	Variable transientStartT = 0  // transient start time, ms
	Variable transientEndT = 200  // transient end time, ms

	// End of User Settings
	//---------------------------------------------------------------------------
	// Load file index
	
	SetDataFolder "root:"

	// Set import options:
	//   C=number of columns to configure, F=data type, T=numeric type
	String columnOptions = "C=1,F=-2; C=1,F=-2; C=1,F=0,T=72; C=1,F=0,T=72;"

	// Load sweep info
	//   /J : from delimited text file; /W/A : use first line as column names
	LoadWave /J /O /W/A /B=columnOptions idxPath
	
	// Igor requires referencing the waves before using them!
	Wave/T name  // text wave
	Wave/T pxpPath  // text wave
	Wave firstSweep
	Wave lastSweep

	// Compute start and end points of transient
	Variable startPnt = sFreq*transientStartT/1000
	Variable endPnt = sFreq*transientEndT/1000 - 1 //-1 for 0-indexing
		
	//---------------------------------------------------------------------------
	// Process every recording file listed in pxpPath
	
	// Create directory to save transient files
	NewPath /O/C transientDir
	
	Variable nFiles = NumPnts(pxpPath)
	Variable f
	for (f=0; f<nFiles; f+=1) 
	
		// Construct a string containing a list of sweep names
		String sweepNames = ""  // empty string is needed for appending strings
		Variable ss
		for (ss = firstSweep[f]; ss <= lastSweep[f]; ss+=1)
			sweepNames = sweepNames + prefix + num2str(ss) + ";"
		endfor
	
		// Load sweeps from a recording file into a temporary data folder
		//   /T=destination data folder ("temp"), /O=overwrite existing obj,
		//   /J=a string containing a list of sweep names
		String filePath = pxpPath[f]
		LoadData /T=temp /O=1 /S=dfName /J=sweepNames filePath
	
		// Create new empty waves to store transients and overwrite
		//   existing ones to clear data from the last processed file
		Make/O/N=0 currTransient, allTransients

		// Extract capacitance transients from each sweep
		for (ss = firstSweep[f]; ss <= lastSweep[f]; ss+=1)
			// Construct current sweep name
			String currSweep = prefix + num2str(ss)
			// Extract transient in current sweep
			//   FYI, you have to call "duplicate" to copy wave,
			//   e.g. this won't work in Igor: Wave newWave = sourceWave[0,10]
			duplicate/O/R=[startPnt,endPnt] root:temp:$currSweep, currTransient
			// Add currTransient to allTransients as a new column
			Concatenate/NP=1 {currTransient}, allTransients
		endfor

		// Save the extracted transients as a text file
		String recordingID = name[f]
		String fileName = recordingID + ".txt"
		Save/O/J/P=transientDir allTransients as fileName

		// Clear temporary data folder before processing next recording file!
		KillDataFolder root:temp
	
	endfor
	
	KillWaves name,pxpPath,firstSweep,lastSweep,currSweep,currTransient,allTransients
	Print "Done!"

end function