#if FEATURE_STEPMANIA
package kec.backend.util.smTools;

import sys.io.File;
import haxe.Exception;
import lime.app.Application;
import haxe.Json;
import openfl.Lib;
import kec.backend.chart.Song;
import kec.backend.chart.TimingStruct;
import kec.backend.chart.format.*;

class SMFile
{
	public static function loadFile(path):SMFile
	{
		var stepFile = new SMFile(File.getContent(path).split('\n'));

		return stepFile;
	}

	private var _fileData:Array<String>;

	public var isDouble:Bool = false;

	public var isValid:Bool = true;

	public var _readTime:Float = 0;

	public var header:SMHeader;
	public var measures:Array<SMMeasure>;

	public var jsonPath:String = '';

	public function new(data:Array<String>)
	{
		try
		{
			_fileData = data;

			// Gather header data
			var headerData = "";
			var inc = 0;
			while (!StringTools.contains(data[inc + 1], "//"))
			{
				headerData += data[inc];
				inc++;
			}

			header = new SMHeader(headerData.split(';'));

			if (_fileData.toString().split("#NOTES").length > 2)
			{
				SUtil.showPopUp("The chart must only have 1 difficulty, this one has "
					+ (_fileData.toString().split("#NOTES").length - 1),
					"SM File loading ("
					+ header.TITLE
					+ ")");
				isValid = false;
				return;
			}

			if (!StringTools.contains(header.MUSIC.toLowerCase(), "ogg"))
			{
				SUtil.showPopUp("The music MUST be an OGG File, make sure the sm file has the right music property.",
					"SM File loading (" + header.TITLE + ")");
				isValid = false;
				return;
			}

			// check if this is a valid file, it should be a dance double file.
			inc += 3; // skip three lines down
			if (!StringTools.contains(data[inc], "dance-double:") && !StringTools.contains(data[inc], "dance-single"))
			{
				SUtil.showPopUp("The file you are loading is neither a Dance Double chart or a Dance Single chart",
					"SM File loading (" + header.TITLE + ")");
				isValid = false;
				return;
			}
			if (StringTools.contains(data[inc], "dance-double:"))
				isDouble = true;
			inc += 5; // skip 5 down to where da notes @

			measures = [];

			var measure = "";

			for (ii in inc...data.length)
			{
				var i = data[ii];
				if (StringTools.contains(i, ",") || StringTools.contains(i, ";"))
				{
					measures.push(new SMMeasure(measure.split('\n')));
					measure = "";
					continue;
				}
				measure += i + "\n";
			}
		}
		catch (e:Exception)
		{
			SUtil.showPopUp("Failure to load file.\n" + e, "SM File loading");
		}
	}

	public function convertToFNF(saveTo:String):String
	{
		// array's for helds
		var heldNotes:Array<Array<Dynamic>>;

		if (isDouble) // held storage lanes
			heldNotes = [[], [], [], [], [], [], [], []];
		else
			heldNotes = [[], [], [], []];

		// variables

		var measureIndex = 0;
		var currentBeat:Float = 0;
		var output = "";

		// init a fnf song

		var song:Modern = {
			songId: header.TITLE,
			songName: header.TITLE,
			audioFile: header.MUSIC,
			notes: [],
			eventObjects: [],
			bpm: header.getBPM(0),
			needsVoices: false,
			player1: 'bf',
			player2: 'gf',
			gfVersion: 'gf',
			style: 'Default',
			stage: 'stage',
			speed: 2.8,
			validScore: false,
			splitVoiceTracks: false,
			chartVersion: Constants.chartVer,
		};

		// lets check if the sm loading was valid

		if (!isValid)
		{
			final data:String = Json.stringify(song);
			File.saveContent(saveTo, data);
			return data;
		}

		// aight time to convert da measures

		for (measure in measures)
		{
			// private access since _measure is private
			@:privateAccess
			var lengthInRows = 192 / (measure._measure.length - 1);

			var rowIndex = 0;

			// section declaration

			var section:Section = {
				sectionNotes: [],
				lengthInSteps: 16,
				startTime: 0.0,
				endTime: 0.0,
				mustHitSection: false,
				bpm: header.getBPM(0),
				index: 0,
			};

			// if it's not a double always set this to true

			if (!isDouble)
				section.mustHitSection = true;

			@:privateAccess
			for (i in 0...measure._measure.length - 1)
			{
				var noteRow = (measureIndex * 192) + (lengthInRows * rowIndex);
				var notes:Array<String> = [];

				for (note in measure._measure[i].split(''))
				{
					// output += note;
					notes.push(note);
				}

				currentBeat = noteRow / 48;

				if (currentBeat % 4 == 0)
				{
					// ok new section time
					song.notes.push(section);
					var section:Section = {
						sectionNotes: [],
						lengthInSteps: 16,
						startTime: 0.0,
						endTime: 0.0,
						mustHitSection: false,
						bpm: header.getBPM(0),
						index: rowIndex,
					};
					if (!isDouble)
						section.mustHitSection = true;
				}

				var seg = TimingStruct.getTimingAtBeat(currentBeat);
				var timeInSec:Float = (seg.startTime + ((currentBeat - seg.startBeat) / (seg.bpm / 60)));
				var rowTime = timeInSec * 1000;
				// output += " - Row " + noteRow + " - Time: " + rowTime + " (" + timeInSec + ") - Beat: " + currentBeat + " - Current BPM: " + header.getBPM(currentBeat) + "\n";

				var index = 0;

				for (i in notes)
				{
					// if its a mine lets skip (maybe add mines in the future??)
					var nType:String = "Normal";
					if (i == "M")
						nType = "Hurt";

					// get the lane and note type
					var lane = index + 4; // shitty fix
					var numba = Std.parseInt(i);

					// switch through the type and add the note

					switch (numba)
					{
						case 1: // normal
							section.sectionNotes.push({
								time: rowTime,
								data: lane,
								length: 0,
								type: nType
							});
						case 2: // held head
							heldNotes[lane] = [rowTime, lane, 0, rowTime];
						case 3: // held tail
							var data = heldNotes[lane];
							var timeDiff = rowTime - data[0];
							section.sectionNotes.push({
								time: data[0],
								data: lane,
								length: timeDiff,
								type: nType
							});
							heldNotes[index] = [];
						case 4: // roll head
							heldNotes[lane] = [rowTime, lane, 0, rowTime];
					}
					index++;
				}

				rowIndex++;
			}

			song.notes.push(section);
			measureIndex++;
		}

		for (i in 0...song.notes.length) // loops through sections
		{
			var section = song.notes[i];
			var currentBeat = 4 * i;
			var currentSeg = TimingStruct.getTimingAtBeat(currentBeat);
			var start:Float = (currentBeat - currentSeg.startBeat) / (currentSeg.bpm / 60);
			section.startTime = (currentSeg.startTime + start) * 1000;

			if (i != 0)
				song.notes[i - 1].endTime = section.startTime;
			section.endTime = Math.POSITIVE_INFINITY;
		}

		// File.saveContent("fuac" + header.TITLE,output);

		if (header.changeEvents.length != 0)
			song.eventObjects = header.changeEvents;

		song.chartVersion = Constants.chartVer;
		final data:String = Json.stringify(song);
		File.saveContent(saveTo, data);
		return data;
	}
}
#end