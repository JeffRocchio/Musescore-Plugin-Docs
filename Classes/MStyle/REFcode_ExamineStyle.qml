//=============================================================================
//  MuseScore Plugin
//
//  This plugin will list to the console window the key -> value pairs for 
//  individual items (elements) selected on a score.
//
//  IF you intend to examine more than a few elements at once you might want
//  to modify this to have it write the results out to a text file rather
//  than the console window.
//
//  I use this to examine what properties are available to my plugin for a
//  given element (e.g., what can I learn about a 'note,' or a 
//  'time signature')?
//  
//=============================================================================


//------------------------------------------------------------------------------
//  1.0: 04/28/2021 | First created
//------------------------------------------------------------------------------

// Am assuming QtQuick version 5.9 for Musescore 3.x plugins.
import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Dialogs 1.1
import MuseScore 3.0

MuseScore {
	id: oMuse
	version:  "1.0"
	description: "Examine an Element"
	menuPath: "Plugins.DEV.Examine an Element"

	QtObject { // oUserMessage
		id: oUserMessage
		
		//	PURPOSE: Is an error recording and reporting object, used
		//to provide error and warning messages to the user.
		
		property bool bError: false
		property int iMessageNumber: 0 // <-- Last trapped error
		readonly property var sUserMessage: [
					//	0: <-- All OK, No Error
		"OK",
					//	1:
		"Nothing Selected - please select 1 or more elements in the score and try again.",
					//	2:
		" ",
					//	3:
		" ",
					//	4:
		"Unrecognized element. Don't know how to handle it.",
					//	5:
		"Selection appears to be invalid. Please clear your selection and try again.",
		]
		
		function getError() { return bError; }
		
		function clearError() { 
			bError = false; 
			return;
		}
		
		function setError(iMessageNum) {
			oUserMessage.bError = true;
			oUserMessage.iMessageNumber = iMessageNum;
		} // end function setError()
	
		function showError(bReset) {
			console.log("", oUserMessage.sUserMessage[oUserMessage.iMessageNumber]);
			if (bReset) { 
				oUserMessage.iMessageNumber = 0;
				oUserMessage.bError = false;
			}
		} // end function getError()
		
		function popupError() {
			
			errorDialog.openErrorDialog(qsTranslate("QMessageBox", sUserMessage[iMessageNumber]));
			
		} // end function popupError()

	} // end oUserMessage QtObject

	QtObject { // oDebug
		id: oDebug

		//PURPOSE:
		//	Provide services that help in debugging. This is primarily 
		//services to create console.log print statements.
		
		function fnEntry(fnName) {
				console.log("");
				console.log("======== | In function ", fnName, "() | =================================\n");
		}
		
		function fnExit(fnName) {
			console.log("");
			console.log("======== | ", fnName, "() RETURNing to caller ||\n");
		}
		
	} // end QtObject oDebug
	
	function showObject(oObject) {
		//	PURPOSE: Lists all key -> value pairs to the console.
		//	NOTE: To reduce clutter I am filtering out any 
		//'undefined' properties. (The MuseScore 'element' object
		//is very flat - it will show many, many properties for any
		//given element type; but for any given element many, if not 
		//most of these properties will return 'undefined' as they 
		//are not all valid for all element types. If you want to see 
		//this comment out the filter.)
		
		if (Object.keys(oObject).length >0) {
			Object.keys(oObject)
				.filter(function(key) {
					return oObject[key] != null;
				})
				.sort()
				.forEach(function eachKey(key) {
					console.log("---- ---- ", key, " : <", oObject[key], ">");
				});
		}
	}
	

//==== PLUGIN RUN-TIME ENTRY POINT =============================================

	onRun: {
		console.log("********** RUNNING **********");

		var oCursor = curScore.newCursor()
		
		showObject(curScore.style);
		if (oUserMessage.getError()) oUserMessage.popupError(); // inform user if lingering errors.
		
		console.log("");
		console.log("genClef <", curScore.style.value("genClef"), ">");
		console.log("showMeasureNumber <", curScore.style.value("showMeasureNumber"), ">");
		console.log("fingeringOffset <", curScore.style.value("fingeringOffset"), ">");
		console.log("Clefs <", curScore.style.value("Clefs"), ">");
		
		console.log("");
		console.log("********** QUITTING **********");
		Qt.quit();

	} //END OnRun


	//==== PLUGIN USER INTERFACE OBJECTS ===========================================

	MessageDialog {
		id: errorDialog
		width: 800
		visible: false
		title: qsTr("Error")
		text: "Error"
		onAccepted: {
			Qt.quit()
		}
		function openErrorDialog(message) {
			text = message
			open()
		}
	}
	

} // END Musescore

