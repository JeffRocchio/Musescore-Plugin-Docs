//=============================================================================
//  MuseScore Plugin
//
//  This plugin demonstrates how to add "fingering" text to a specific
//  note.
//
//  Unlike Staff Text, a fingering element is a child of one specific note, 
//  so adding one is just a little bit different than adding staff text.
//
//=============================================================================


//------------------------------------------------------------------------------
//  1.0: 04/29/2021 | First created
//------------------------------------------------------------------------------

// Am assuming QtQuick version 5.9 for Musescore 3.x plugins.
import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Dialogs 1.1
import MuseScore 3.0

MuseScore {
	id: oMuse
	version:  "1.0"
	description: "Add Fingering Text"
	menuPath: "Plugins.DEV.Add Fingering Text"

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
		"No note selected - please select a single note and try again,",
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
	
	function assessValidity(oCursor) {
		//   PURPOSE: Prior to attempting any transformation, see 
		//if it appears that everything is valid.
		//   RETURNS:
		//		1.	true if all is well, false if not. And if true:
		//		2.	If false, the oUserMessage object will contain
		//an error number which can be used to inform the user.
		
		var bDEBUG = true;
		bDEBUG = false;

		if(bDEBUG) oDebug.fnEntry(assessValidity.name);
		
		var bValid = true;
		
					//	Do we have a selection?
		if(bDEBUG) {
			console.log("---- Inspecting the Selection ---|");
			console.log("---- ---- # of Elements Selected <", curScore.selection.elements.length, ">");
			console.log("---- ---- Range or no Range? <", curScore.selection.isRange, ">");
		}
					//	All I want to do is make sure at least one
					//single note on the score has been selected.
		if (curScore.selection.elements.length==0) {
			oUserMessage.setError(1);
			bValid = false;
		} 
		if (bValid) {
			if(curScore.selection.elements[0].type != Element.NOTE) {
				oUserMessage.setError(2);
				bValid = false;
			}
			
		}
		
		if(bDEBUG) oDebug.fnExit(assessValidity.name);
		return true;
		
	} // end assessValidity()
	
	function showObject(oObject) {
		//	PURPOSE: Lists all key -> value pairs to the console.
		//	NOTE: To reduce clutter I am filtering out any 
		//'undefined' properties. (The MuseScore 'element' object
		//is very flat - it will show many, many properties for any
		//given element type; but for any given element many, if not 
		//most of these properties will return 'undefined' as they 
		//are not all valid for all element types. If you want to see 
		//this comment out the filter.)
		//	I have this here only because I often find it useful to
		//explode out objects as I am working out some puzzle. So
		//this is just a standard function I have in many of my
		//experimental plugins. It may, or may not, get used in any
		//given situation. Generally you can ignore this.
		
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
		
		if (!assessValidity (oCursor)) {
			oUserMessage.popupError();
		}
					//	OK, we have a selected note, so now let's add 
					//fingering text.
		else { 
			if(curScore.selection.elements[0].type === Element.NOTE) {
				console.log("");
				console.log("---- Adding Fingering Text...");
				var half = newElement(Element.FINGERING);
				half.text = "FG";
				half.color = "#aa0000";
				curScore.selection.elements[0].add(half);
				//Here's an odd thing - you have to set the x,y offset 
				//properties **after** you have added the fingering object 
				//to the note. If you set them prior to adding, like I did
				//for the color above, they don't seem to have any effect.
				//I personally cannot explain this difference in behavior.
				half.offsetX = 2.00;
				half.offsetY = -0.44;
			}
					//	Now let's examine all the properties of the fingering 
					//text we just added.
				console.log("");
				console.log("---- Key->Value pairs of object We just added  || ", half.name, "||");
				showObject(half);
			if (oUserMessage.getError()) oUserMessage.popupError(); // inform user if lingering errors.
		}

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

