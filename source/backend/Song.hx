package backend;

import haxe.Json;
import openfl.utils.Assets;

import backend.Section;

typedef SwagSong =
{
	var song:String;
	var notes:Array<SwagSection>;
	var events:Array<Dynamic>;
	var bpm:Float;
	var needsVoices:Bool;
	var speed:Float;

	var player1:String;
	var player2:String;
	var gfVersion:String;
	var stage:String;

	@:optional var gameOverChar:String;
	@:optional var gameOverSound:String;
	@:optional var gameOverLoop:String;
	@:optional var gameOverEnd:String;
	
	@:optional var disableNoteRGB:Bool;

	@:optional var arrowSkin:String;
	@:optional var splashSkin:String;
}

class Song
{
	public var song:String = null;
	public var notes:Array<SwagSection>;
	public var events:Array<Dynamic>;
	public var bpm:Float;
	public var needsVoices:Bool = true;
	public var arrowSkin:String;

	public var splashSkin:String;
	public var gameOverChar:String;
	public var gameOverSound:String;
	public var gameOverLoop:String;
	public var gameOverEnd:String;
	public var disableNoteRGB:Bool = false;
	public var speed:Float = 1;
	public var stage:String;
	public var player1:String = 'bf';
	public var player2:String = 'dad';
	public var gfVersion:String = 'gf';

	public var mapper:String = 'N/A';
	public var musican:String = 'N/A';
	
	static public var isNewVersion:Bool = false;

	private static function onLoadJson(songJson:Dynamic) // Convert old charts to newest format
	{
		if(songJson.gfVersion == null)
		{
			songJson.gfVersion = songJson.player3;
			songJson.player3 = null;
		}

		if(songJson.events == null)
		{
			songJson.events = [];
			for (secNum in 0...songJson.notes.length)
			{
				var sec:SwagSection = songJson.notes[secNum];

				var i:Int = 0;
				var notes:Array<Dynamic> = sec.sectionNotes;
				var len:Int = notes.length;
				while(i < len)
				{
					var note:Array<Dynamic> = notes[i];
					if(note[1] < 0)
					{
						songJson.events.push([note[0], [[note[2], note[3], note[4]]]]);
						notes.remove(note);
						len = notes.length;
					}
					else i++;
				}
			}
		}
	}

	public function new(song, notes, bpm)
	{
		this.song = song;
		this.notes = notes;
		this.bpm = bpm;
	}

	public static function loadFromJson(jsonInput:String, ?folder:String):SwagSong
	{
		var rawJson = null;
		
		var formattedFolder:String = Paths.formatToSongPath(folder);
		var formattedSong:String = Paths.formatToSongPath(jsonInput);
		#if MODS_ALLOWED
		var moddyFile:String = Paths.modsJson('$formattedFolder/$formattedSong');
		if(FileSystem.exists(moddyFile)) {
			rawJson = File.getContent(moddyFile).trim();
		}
		#end

		if(rawJson == null) {
			var path:String = Paths.json('$formattedFolder/$formattedSong');

			#if sys
			if(FileSystem.exists(path))
				rawJson = File.getContent(path);
			else
			#end
				rawJson = Assets.getText(path);
		}

		var songJson:Dynamic = parseJSONshit(rawJson);
		if(jsonInput != 'events') StageData.loadDirectory(songJson);
		onLoadJson(songJson);
		return songJson;
	}
	
    public static function parseJSONshit(rawData:String):SwagSong {             
        var songJson:SwagSong = cast Json.parse(rawData);
        isNewVersion = true;
		if(Reflect.hasField(songJson, 'song'))
		{
			var subSong:SwagSong = Reflect.field(songJson, 'song');
			if(subSong != null && Type.typeof(subSong) == TObject)
			{
				songJson = subSong;
			    isNewVersion = false;
			}
		}
		
		return cast songJson;
    }

    public static function parseVersion(rawData:String):String {             
        var songJson:SwagSong = cast Json.parse(rawData);
	if(Reflect.hasField(songJson, 'song'))
	{
		var subSong:SwagSong = Reflect.field(songJson, 'song');
		if(subSong != null && Type.typeof(subSong) == TObject)
		{
			return '0.7.x';
		}else{
			return null;
		}
	}else{
		return '1.0.x';
	}
    }

    public static function castVersion(songJson:SwagSong):SwagSong {
	    for (i in 0...songJson.notes.length){
		for (ii in 0...songJson.notes[i].sectionNotes.length){
			var gottaHitNote:Bool = songJson.notes[i].mustHitSection;
			if(!gottaHitNote){
				if(songJson.notes[i].sectionNotes[ii][1] >= 4){
					songJson.notes[i].sectionNotes[ii][1] -= 4;
				}else if(songJson.notes[i].sectionNotes[ii][1] <= 3){
					songJson.notes[i].sectionNotes[ii][1] += 4;
				}
			}
		}
	    }
	    isNewVersion = false;
	    return songJson;
    }
}
