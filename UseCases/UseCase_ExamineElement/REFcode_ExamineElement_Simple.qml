//=============================================================================
//  MuseScore Plugin
//
//  This plugin will list to the console window the key -> value pairs for 
//  individual items (elements) selected on a score. E.g., open a score,
//  select an individual note, then run this plugin from the Plugin Creator
//  window to see that note's properties list in the console output.
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
//  1.0: 04/24/2021 | First created
//------------------------------------------------------------------------------

// Am assuming QtQuick version 5.9 for Musescore 3.x plugins.
import QtQuick 2.0
import QtQuick.Dialogs 1.1
import MuseScore 3.0

MuseScore {
	version:  "1.0"
	description: "Examine an Element"
	menuPath: "Plugins.DEV.Examine an Element"

	function showObject(mscoreElement) {
		//	PURPOSE: Lists all key -> value pairs of the passed in
		//element to the console.
		//	NOTE: To reduce clutter I am filtering out any 
		//'undefined' properties. (The MuseScore 'element' object
		//is very flat - it will show many, many properties for any
		//given element type; but for any given element many, if not 
		//most, of these properties will return 'undefined' as they 
		//are not all valid for all element types. If you want to see 
		//this comment out the filter.)
		
		if (Object.keys(mscoreElement).length >0) {
			Object.keys(mscoreElement)
				.filter(function(key) {
					return mscoreElement[key] != null;
				})
				.forEach(function eachKey(key) {
					console.log("---- ---- ", key, " : <", mscoreElement[key], ">");
				});
		}
	}

//==== PLUGIN RUN-TIME ENTRY POINT =============================================

	onRun: {
		console.log("********** RUNNING **********\n");

		var oCursor = curScore.newCursor()
		
		//Make sure something is selected.
		if (curScore.selection.elements.length==0) {
			console.log("**** NOTHING SELECTED");
			console.log("**** Select an element on the score and try again");
			console.log("****");
		}
		//We have a selection, now explode it...
		else { 
			var oElementsList = curScore.selection.elements;
			console.log("");
			console.log("---- | Number of Selected Elements to Examine: [", oElementsList.length, "]");
			console.log("");
			for (var i=0; i<oElementsList.length; i++) {
				console.log("------------------------------------------------------------------------");
				console.log("---- Element# [", i, "] is a || ", oElementsList[i].name, " ||");
				console.log("");
				showObject(oElementsList[i]);
				console.log("\n");
				console.log("---- END Element# [", i, "]");
				console.log("------------------------------------------------------------------------");
				console.log("");
			}
		}

		console.log("********** QUITTING **********\n");
		Qt.quit();

	} //END OnRun


} // END Musescore

