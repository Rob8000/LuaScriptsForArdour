# LuaScriptsForArdour
Scripts that allow looping within Ardour.
looper.lua is setup to work with a Novation Launchpad Mk2. It requires quite a bit of configuration, in particular the midi output to individual tracks and the tracks only taking input from a particular midi channel. The script should read in all regions and map any region whose name is of the format "loop*-n-m" where n is the position on the Launchpad and m is the midi channel. This script isn't very polished.
tryToRecord.lua will record and playback midi. The recording and playback is triggered by parameters. These parameters can be automated to switch on and off to allow looping. E.g. you automate recording for a bar and then automate playback for a few bars after that.
