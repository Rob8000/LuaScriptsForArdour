ardour {
	["type"]    = "dsp",
	name        = "Midi Pad Looper",
	category    = "Midi", 
	license     = "GPLv2",
	author      = "R8000",
	description = [[A script that will play midi sequences on a loop triggered by a midi device]]
}

function dsp_ioconfig ()
	return { {midi_in = 1, midi_out = 3, audio_in = -1, audio_out = -1}, }
end

function dsp_configure(ins, outs)
	n_out = outs
	n_out:set_midi(0)
end
local loopString = "loop"
local firstBar = 0
local tme = 0 -- sample-counter
local seq = 1 -- sequence-step
local spb = 0 -- samples per beat
local rateO = 0
local currentSample = 0
local currentOffset = 0
local beatsInABar = 4
local samplesPerBar = 0
--assuming 4 beats per bar
local mappingBack = {}
mappingBack[	20	] = 	64
mappingBack[	21	] = 	65
mappingBack[	22	] = 	66
mappingBack[	23	] = 	67
mappingBack[	24	] = 	68
mappingBack[	64	] = 	18
mappingBack[	63	] = 	17
mappingBack[	9	] = 	71
mappingBack[	10	] = 	72
mappingBack[	11	] = 	73
mappingBack[	12	] = 	74
mappingBack[	13	] = 	75
mappingBack[	14	] = 	76
mappingBack[	15	] = 	77
mappingBack[	16	] = 	78
mappingBack[	61	] = 	15
mappingBack[	62	] = 	16
mappingBack[	1	] = 	81
mappingBack[	2	] = 	82
mappingBack[	3	] = 	83
mappingBack[	4	] = 	84
mappingBack[	5	] = 	85
mappingBack[	6	] = 	86
mappingBack[	7	] = 	87
mappingBack[	8	] = 	88
mappingBack[	53	] = 	25
mappingBack[	54	] = 	26
mappingBack[	55	] = 	27
mappingBack[	56	] = 	28
mappingBack[	60	] = 	14
mappingBack[	59	] = 	13
mappingBack[	41	] = 	31
mappingBack[	42	] = 	32
mappingBack[	43	] = 	33
mappingBack[	44	] = 	34
mappingBack[	45	] = 	35
mappingBack[	46	] = 	36
mappingBack[	47	] = 	37
mappingBack[	48	] = 	38
mappingBack[	58	] = 	12
mappingBack[	57	] = 	11
mappingBack[	33	] = 	41
mappingBack[	34	] = 	42
mappingBack[	35	] = 	43
mappingBack[	36	] = 	44
mappingBack[	37	] = 	45
mappingBack[	38	] = 	46
mappingBack[	39	] = 	47
mappingBack[	40	] = 	48
mappingBack[	52	] = 	24
mappingBack[	51	] = 	23
mappingBack[	25	] = 	51
mappingBack[	26	] = 	52
mappingBack[	27	] = 	53
mappingBack[	28	] = 	54
mappingBack[	29	] = 	55
mappingBack[	30	] = 	56
mappingBack[	31	] = 	57
mappingBack[	32	] = 	58
mappingBack[	50	] = 	22
mappingBack[	49	] = 	21
mappingBack[	17	] = 	61
mappingBack[	18	] = 	62
mappingBack[	19	] = 	63

local launchPadMappings = {}
 launchPadMappings[ 81 ] =  1
 launchPadMappings[ 82 ] =  2
 launchPadMappings[ 83 ] =  3
 launchPadMappings[ 84 ] =  4
 launchPadMappings[ 85 ] =  5
 launchPadMappings[ 86 ] =  6
 launchPadMappings[ 87 ] =  7
 launchPadMappings[ 88 ] =  8
 launchPadMappings[ 71 ] =  9
 launchPadMappings[ 72 ] =  10
 launchPadMappings[ 73 ] =  11
 launchPadMappings[ 74 ] =  12
 launchPadMappings[ 75 ] =  13
 launchPadMappings[ 76 ] =  14
 launchPadMappings[ 77 ] =  15
 launchPadMappings[ 78 ] =  16
 launchPadMappings[ 61 ] =  17
 launchPadMappings[ 62 ] =  18
 launchPadMappings[ 63 ] =  19
 launchPadMappings[ 64 ] =  20
 launchPadMappings[ 65 ] =  21
 launchPadMappings[ 66 ] =  22
 launchPadMappings[ 67 ] =  23
 launchPadMappings[ 68 ] =  24
 launchPadMappings[ 51 ] =  25
 launchPadMappings[ 52 ] =  26
 launchPadMappings[ 53 ] =  27
 launchPadMappings[ 54 ] =  28
 launchPadMappings[ 55 ] =  29
 launchPadMappings[ 56 ] =  30
 launchPadMappings[ 57 ] =  31
 launchPadMappings[ 58 ] =  32
 launchPadMappings[ 41 ] =  33
 launchPadMappings[ 42 ] =  34
 launchPadMappings[ 43 ] =  35
 launchPadMappings[ 44 ] =  36
 launchPadMappings[ 45 ] =  37
 launchPadMappings[ 46 ] =  38
 launchPadMappings[ 47 ] =  39
 launchPadMappings[ 48 ] =  40
 launchPadMappings[ 31 ] =  41
 launchPadMappings[ 32 ] =  42
 launchPadMappings[ 33 ] =  43
 launchPadMappings[ 34 ] =  44
 launchPadMappings[ 35 ] =  45
 launchPadMappings[ 36 ] =  46
 launchPadMappings[ 37 ] =  47
 launchPadMappings[ 38 ] =  48
 launchPadMappings[ 21 ] =  49
 launchPadMappings[ 22 ] =  50
 launchPadMappings[ 23 ] =  51
 launchPadMappings[ 24 ] =  52
 launchPadMappings[ 25 ] =  53
 launchPadMappings[ 26 ] =  54
 launchPadMappings[ 27 ] =  55
 launchPadMappings[ 28 ] =  56
 launchPadMappings[ 11 ] =  57
 launchPadMappings[ 12 ] =  58
 launchPadMappings[ 13 ] =  59
 launchPadMappings[ 14 ] =  60
 launchPadMappings[ 15 ] =  61
 launchPadMappings[ 16 ] =  62
 launchPadMappings[ 17 ] =  63
 launchPadMappings[ 18 ] =  64


local midi_sequence1  =  { 
{time =  1.0 ,midi = { 0x90,  60 , 64 }},
{time =  1.25 ,midi = { 0x80,  60 , 0 }},
{time =  3.0 ,midi = { 0x90,  60 , 64 }},
{time =  3.25 ,midi = { 0x80,  60 , 0 }},
}
local midi_sequence2  =  { 
{time =  0.0 ,midi = { 0x91,  33 , 127 }},
{time =  0.88020833333333 ,midi = { 0x81,  33 , 0 }},
{time =  0.99583333333333 ,midi = { 0x91,  33 , 95 }},
{time =  1.6302083333333 ,midi = { 0x81,  33 , 0 }},
{time =  2.0 ,midi = { 0x91,  33 , 127 }},
{time =  2.25 ,midi = { 0x81,  33 , 0 }},
{time =  2.25 ,midi = { 0x91,  33 , 110 }},
{time =  2.5 ,midi = { 0x81,  33 , 0 }},
{time =  2.5 ,midi = { 0x91,  31 , 95 }},
{time =  2.75 ,midi = { 0x81,  31 , 0 }},
{time =  2.75 ,midi = { 0x91,  33 , 95 }},
{time =  3.0 ,midi = { 0x81,  33 , 0 }},
{time =  3.25 ,midi = { 0x91,  33 , 95 }},
{time =  3.5 ,midi = { 0x81,  33 , 0 }},
}
local midi_sequence3  =  { 
{time =  0.0 ,midi = { 0x92,  38 , 127 }},
{time =  0.88020833333333 ,midi = { 0x82,  38 , 0 }},
{time =  0.99583333333333 ,midi = { 0x92,  38 , 95 }},
{time =  1.6302083333333 ,midi = { 0x82,  38 , 0 }},
{time =  2.0 ,midi = { 0x92,  38 , 127 }},
{time =  2.25 ,midi = { 0x82,  38 , 0 }},
{time =  2.25 ,midi = { 0x92,  38 , 110 }},
{time =  2.5 ,midi = { 0x82,  38 , 0 }},
{time =  2.5 ,midi = { 0x92,  36 , 95 }},
{time =  2.75 ,midi = { 0x82,  36 , 0 }},
{time =  2.75 ,midi = { 0x92,  38 , 95 }},
{time =  3.0 ,midi = { 0x82,  38 , 0 }},
{time =  3.25 ,midi = { 0x92,  38 , 95 }},
{time =  3.5 ,midi = { 0x82,  38 , 0 }},
}
local midi_sequence4  =  { 
{time =  0.0 ,midi = { 0x93,  36 , 127 }},
{time =  0.88020833333333 ,midi = { 0x83,  36 , 0 }},
{time =  0.99583333333333 ,midi = { 0x93,  36 , 95 }},
{time =  1.6302083333333 ,midi = { 0x83,  36 , 0 }},
{time =  2.0 ,midi = { 0x93,  36 , 127 }},
{time =  2.25 ,midi = { 0x83,  36 , 0 }},
{time =  2.25 ,midi = { 0x93,  36 , 110 }},
{time =  2.5 ,midi = { 0x83,  36 , 0 }},
{time =  2.5 ,midi = { 0x93,  35 , 95 }},
{time =  2.75 ,midi = { 0x83,  35 , 0 }},
{time =  2.75 ,midi = { 0x93,  36 , 95 }},
{time =  3.0 ,midi = { 0x83,  36 , 0 }},
{time =  3.25 ,midi = { 0x93,  36 , 95 }},
{time =  3.5 ,midi = { 0x83,  36 , 0 }},
}
local midi_sequence5  =  { 
{time =  0.0 ,midi = { 0x94,  64 , 100 }},
{time =  0.25 ,midi = { 0x84,  64 , 0 }},
{time =  2.0 ,midi = { 0x94,  64 , 100 }},
{time =  2.25 ,midi = { 0x84,  64 , 0 }},
}
local midi_sequence6  =  { 
{time =  0.0 ,midi = { 0x95,  56 , 64 }},
{time =  0.5 ,midi = { 0x85,  56 , 0 }},
{time =  0.5 ,midi = { 0x95,  56 , 64 }},
{time =  1.0 ,midi = { 0x85,  56 , 0 }},
{time =  1.0 ,midi = { 0x95,  56 , 64 }},
{time =  1.5 ,midi = { 0x85,  56 , 0 }},
{time =  1.5 ,midi = { 0x95,  56 , 64 }},
{time =  2.0 ,midi = { 0x85,  56 , 0 }},
{time =  2.0 ,midi = { 0x95,  56 , 64 }},
{time =  2.5 ,midi = { 0x85,  56 , 0 }},
{time =  2.5 ,midi = { 0x95,  56 , 64 }},
{time =  3.0 ,midi = { 0x85,  56 , 0 }},
{time =  3.0 ,midi = { 0x95,  56 , 64 }},
{time =  3.5 ,midi = { 0x85,  56 , 0 }},
{time =  3.5 ,midi = { 0x95,  56 , 64 }},
{time =  4.0 ,midi = { 0x85,  56 , 0 }},
}
local allMidi = { midi_sequence1,midi_sequence2,midi_sequence3, midi_sequence4, midi_sequence5, midi_sequence6}
local midi_notes_state = {}
local midi_notes_state_at_next_bar = {}
local total_notes = 64 
local total_midi_out = 7
local channelIsActive = {}
local channelColours = {}
channelColours[1] = 6 
channelColours[2] = 9
channelColours[3] = 12 
channelColours[4] = 16 
channelColours[5] = 32
channelColours[6] = 48 
channelColours[7] = 56 
channelColours[8] = 66 
channelColours[9] = 80 
channelColours[10] = 83 
channelColours[11] = 89 
channelColours[12] = 90 
channelColours[13] = 91 
channelColours[14] = 112 
channelColours[15] = 113 
channelColours[16] = 114
local colourNeedsChange = {}
function dsp_params ()


        local all_regions = ARDOUR.RegionFactory.regions()
        local countLoops= 1
	local tableScalePointsForLoops = {}
	local noteToChannel = {}
	local noteToMidi = {}
	  for _, r in all_regions:iter() do
		  local mr = r:to_midiregion ()
			if (mr:isnil() and  not mr:hidden())  then goto next end
			local regionName = r:name()
			
			if string.starts(regionName, loopString) then
			  print(r:name(), "is midi pattern ", countLoops)
			  tableScalePointsForLoops[r:name()] = countLoops
			  local splitName = string.gmatch(regionName, '([^-]+)')
			  local splitIndex = 1
			  local noteHere = -1
			  for split in splitName do
			  	if(splitIndex == 2) then
					local castNote = tonumber(split)
					if(castNote ~= nil) then
						noteToMidi[castNote] =  countLoops
						noteHere = castNote 
					end
			  	end
				if(splitIndex == 3) then
					local castChannel = tonumber(split)
					if(castChannel ~= nil) then
						noteToChannel[noteHere] = castChannel 
					end
				end
			  	splitIndex = splitIndex + 1
			  end
			    countLoops = countLoops + 1 
			end
			::next::
						
		end	

	local tableToReturn = {};
--	for i = 1, 64 do
--		tableToReturn[i] = 
--		{ ["type"] = "input", name = "Mode for" .. i, min = 0, max = 4, default = 0, enum = true, scalepoints =
--			{
--				["Loop@Beat"] = 0,
--				["Loop@Note"] = 1,
--				["Play"] = 2,
--			}
--		}
--	end
	for i = 1, 64 do
		local default = 1
		if(noteToMidi[i] ~= nil) then
			default = noteToMidi[i]
		end
		tableToReturn[i] = 
		{ ["type"] = "input", name = "Pattern for " .. (i), min = 1, max = 2000, default = default, enum = true, scalepoints = 
			
			tableScalePointsForLoops
		}
	end
	tableOfChannels = {}
	for i = 0, 16 do
		local id = "Channel "  .. i
		if i == 0 then
			id = "Off"
		end
		tableOfChannels[id] = i
	end 
	for i = 65, 128 do
		local default = 0
		if(noteToChannel[i - 64] ~= nil) then
			default = noteToChannel[i - 64]
		end
		tableToReturn[i] = 
		{ ["type"] = "input", name = "Channel for " .. (i - 64), min = 0, max = 16, default = default, enum = true, scalepoints = 
			tableOfChannels	
		}
	end



	return tableToReturn
end
function dsp_init (rate)
	
	self:shmem():allocate(total_notes + 1)
	self:shmem():clear()

	local tm = Session:tempo_map ()
	local ts = tm:tempo_section_at_sample (0)

	local bpm = ts:to_tempo():note_types_per_minute ()

	rateO = rate
	spb = rate * 60 / bpm
	samplesPerBar = spb * beatsInABar
	print(spb)
	print(rate)
	print(samplesPerBar)
	if spb < 2 then spb = 2 end
	for i = 1, total_midi_out do
		channelIsActive[i] = 0
	end
	for i = 1, total_notes do
		midi_notes_state[i] = 0 
		midi_notes_state_at_next_bar[i] = 0
		colourNeedsChange[i] = 1
	end
	print "managed to reload!"
	load_midi_from_ranges()
	for i = 1,#allMidi do
		midi_notes_state[i] = 0
		midi_notes_state_at_next_bar[i] = 0
	end
end

function string.starts(String,Start)
   return string.sub(String,1,string.len(Start))==Start
end
function load_midi_from_ranges ()

        local all_regions = ARDOUR.RegionFactory.regions()
        local countLoops= 1
	local hexValueOn = 0x90
	local hexValueOff = 0x80
	  for _, r in all_regions:iter() do
		  local mr = r:to_midiregion ()
			if (mr:isnil() and  not mr:hidden())  then goto next end
			if string.starts(r:name(), loopString) then
				print(r:name(), "is midi pattern ", countLoops)
				local nl = ARDOUR.LuaAPI.note_list (mr:model ()) 
				local midiName = "midi_sequence" .. countLoops 
				local newMidi = {};
				local noteCount = 1
				local firstNote = true
				local offSet = 0.0
				  for n in nl:iter () do
					  local timeToUse = n:time():to_double()
					  if(firstNote and timeToUse >= 4.0) then
					  offSet = 4.0
					  --hack for now!
					  end
					 timeToUse = timeToUse - offSet
					 firstNote = false
					 newMidi[noteCount] = {time = timeToUse, midi = { hexValueOn, n:note(), n:velocity()}}
					 noteCount = noteCount + 1
					 newMidi[noteCount] = {time = timeToUse + n:length():to_double(), midi = {hexValueOff, n:note(),0}}
					 noteCount = noteCount + 1
					 print ("{time = ", timeToUse, ",midi = { ", hexValueOn, ",", (n:note ()),
					 ",", n:velocity () , "}},")

					  print ("{time = ", timeToUse + n:length():to_double(),    ",midi = { ", hexValueOff,",", (n:note ()),
					 ",", 0, "}},")
				  end
				  allMidi[countLoops] = newMidi
				  print("Added pattern ", countLoops)
				  countLoops = countLoops + 1 
			
			end
			::next::
						
		end	

end
function dsp_dsp_midi_input ()
	return true
end

function updateColours(bufs, in_map, out_map, n_samples, offset )
	local ctrl = CtrlPorts:array()
	ob = out_map:get (ARDOUR.DataType("midi"), 2)
	if ob ~= ARDOUR.ChanMapping.Invalid then
		local mb = bufs:get_midi (ob)
		local ba = C.ByteVector()
				countOfColourCycles = 0
				for i = 1, total_notes do
					if(colourNeedsChange[i] == 1) then
						colourNeedsChange[i] = 0
						local midiIndex = ctrl[i]
						local channelIndex = ctrl[i + 64]
						if(channelIndex == nil or channelIndex == 0) then
									ba:add({144, mappingBack[i],0})
									mb:push_back (offset + countOfColourCycles , ba:size (), ba:to_array());
									ba:clear ()
						else
							local colour = channelColours[channelIndex]
							if(midi_notes_state[i] == 0) then 
								ba:add({144, mappingBack[i],colour})
								mb:push_back (offset + countOfColourCycles , ba:size (), ba:to_array());
								ba:clear ()
							else
								if(midi_notes_state[i] == 1) then 
									ba:add({144, mappingBack[i],0})
									mb:push_back (offset + countOfColourCycles , ba:size (), ba:to_array());
									ba:clear ()
									ba:add({145, mappingBack[i],colour})
									mb:push_back (offset + countOfColourCycles , ba:size (), ba:to_array());
									ba:clear ()
								else
									if(midi_notes_state[i] == 2) then
										ba:add({144, mappingBack[i],colour + 1})
										mb:push_back (offset + countOfColourCycles , ba:size (), ba:to_array());
										ba:clear ()
										ba:add({145, mappingBack[i],colour})
										mb:push_back (offset + countOfColourCycles , ba:size (), ba:to_array());
										ba:clear ()
									else
										if(midi_notes_state[i] == 3) then 
											ba:add({144, mappingBack[i],118})
											mb:push_back (offset + countOfColourCycles , ba:size (), ba:to_array());
											ba:clear ()
										end
									end
								end
							end
						end
						countOfColourCycles = countOfColourCycles + 1
					end
				end
	end
	-- passthrough audio, apply pin/channel mapping
end
function pushMidi (bufs, in_map, out_map, n_samples, offset, midi, sizeOfMidiTable)
	assert (spb > 1)
	local ob = out_map:get (ARDOUR.DataType ("midi"), 1)
	if ob ~= ARDOUR.ChanMapping.Invalid then
		local mb = bufs:get_midi (ob)
		local ba = C.ByteVector()
			for _,midiData in pairs(midi) do
				ba:add(midiData.data)
				mb:push_back (offset + midiData.time, ba:size (), ba:to_array());
				ba:clear ()
			end

				
    	end		

	ARDOUR.DSP.process_map (bufs,n_out, in_map, out_map, n_samples, offset)
end

function update_loop_on_or_off (bufs, in_map, out_map, n_samples, offset)

	 local ob2 = in_map:get (ARDOUR.DataType ("midi"), 0)
	 local mb2 = bufs:get_midi(ob2)
	 local events = mb2:table ()
	 for _, e in pairs (events) do
		if(e:size () == 3) then
			local table = e:buffer():get_table(e:size())
			if(table[1] == 144 and (launchPadMappings[table[2]] ~= nil )) then --on
			local noteVal = launchPadMappings[table[2]]
			 midi_notes_state_at_next_bar[noteVal] = (midi_notes_state_at_next_bar[noteVal] + 1) % 2	
			 if(midi_notes_state_at_next_bar[noteVal] == 1 and midi_notes_state[noteVal] == 0) then
			   local shmem = self:shmem()
			   local state = shmem:to_int(0):array()
			   midi_notes_state[noteVal] = 2
			   state[noteVal] = midi_notes_state[noteVal]
			   self:queue_draw ()
			   colourNeedsChange[noteVal] = 1
			 end
			 if(midi_notes_state_at_next_bar[noteVal] == 0  and midi_notes_state[noteVal] == 1) then
			   local shmem = self:shmem()
			   local state = shmem:to_int(0):array()
			   midi_notes_state[noteVal] = 3
			   state[noteVal] = midi_notes_state[noteVal]
			   self:queue_draw ()
			   colourNeedsChange[noteVal] = 1
			 end
			 end
--		print (e:channel (), e:time (), e:size (), e:buffer():array (), e:buffer ():get_table (e:size ())[1], e:buffer():get_table (e:size ())[2], e:buffer():get_table (e:size())[3])
		 
		end
	 end
	--local transportSample = Session:transport_sample() 
	if(currentOffset >= samplesPerBar) then
		--if(transportSample > 0) then
		--currentOffset = transportSample %  samplesPerBar
		--else
		currentOffset = currentSample %  samplesPerBar
		--end
		local shmem = self:shmem()
		local state = shmem:to_int(0):array()
		for i = 1, 64 do
		         if(midi_notes_state[i] ~= midi_notes_state_at_next_bar[i]) then
				 colourNeedsChange[i] = 1
			 end
			 midi_notes_state[i] = midi_notes_state_at_next_bar[i] 
			 state[i] = midi_notes_state[i]
			 self:queue_draw ()
			 
		end
	end

end
function dsp_runmap (bufs, in_map, out_map, n_samples, offset)
	update_loop_on_or_off(bufs, in_map, out_map, n_samples, offset)
	local midiToSend = {}
	local countGoingIn = 0
	local indexOfMidi = 0
	local timesUsed = {}
	local ctrl = CtrlPorts:array ()
	for _,midiLocal in pairs (allMidi) do
	indexOfMidi = indexOfMidi + 1
	for time, midiData in pairs (midiLocal) do
		local timeAsAnOffset = math.floor(midiData.time * samplesPerBar /4.0)
		local modOffset = ((currentOffset + n_samples) % samplesPerBar) - n_samples
		if((timeAsAnOffset >= modOffset  and timeAsAnOffset < modOffset + n_samples)) then
		for note = 1, 64 do
			if(modOffset < 0) then
				if(midi_notes_state[note] ~= midi_notes_state_at_next_bar[note]) then
					colourNeedsChange[note] = 1
				end
				midi_notes_state[note] = midi_notes_state_at_next_bar[note]
			end
			if(ctrl[note + 64] ~= 0 and  ctrl[note] == indexOfMidi and ( midi_notes_state[note] == 1 or midi_notes_state[note] == 3)) then
                                local uniqueTime = getTime (timeAsAnOffset - modOffset, n_samples, timesUsed)
				local midiDataWithAlteredChannel = {} 
				if(ctrl[note  + 64] > 1) then
					midiDataWithAlteredChannel[1] = midiData.midi[1] + ctrl[note  + 64] - 1
				else
					midiDataWithAlteredChannel[1] = midiData.midi[1]
				end
				midiDataWithAlteredChannel[2] = midiData.midi[2]
				midiDataWithAlteredChannel[3] = midiData.midi[3]
				table.insert(timesUsed, uniqueTime)
				table.insert(midiToSend, {time = uniqueTime, data = midiDataWithAlteredChannel})
				countGoingIn = countGoingIn + 1
			end
			
		end
 		end
	end
	end
	if(countGoingIn > 0) then
		local function midiOrder(a,b)
			return a.time < b.time
		end
		table.sort(midiToSend,midiOrder)
		pushMidi(bufs, in_map, out_map, n_samples,  offset ,midiToSend, countGoingIn)
	end
	updateColours(bufs, in_map, out_map, n_samples, offset)
	currentOffset = currentOffset + n_samples
	currentSample = currentSample + n_samples
      	

end

function getTime(time, n_samples, timesUsed)
	local timeToReturn = time
	local counter = 0
	if next(timesUsed) == nil then
		return time
	end
        while(alreadyUsed(timeToReturn, timesUsed)) do
		counter = counter + 1
		if(counter > n_samples) then 
			return 0 --let it crash
		end
		timeToReturn = (timeToReturn + 1) % n_samples
	end
	return timeToReturn
end

function alreadyUsed(time, timesUsed)
	for _,used in pairs(timesUsed) do
		if(time == used) then
			return true
		end
	end
	return false
end

function render_inline (ctx, w, max_h)
	if (w > max_h) then
		h = max_h
	else
		h = w
	end
	local widthOfBox = w /8 
	local heightOfBox = h /8 
	local shmem = self:shmem()
	local state = shmem:to_int(0):array()
	ctx:rectangle (0,0,w,h)
	ctx:set_source_rgba (0,0,0,1.0)
	--rint(widthOfBox)
	ctx:fill ()
	for i = 0,7 do
	for j = 0,7 do
		--print(i*8 + j)
	--print(state[i*8 + j + 1])
	--temporary punt up the location
	if state[j*8 +  i  + 1] == 1 then
		ctx:rectangle (i * widthOfBox, j*heightOfBox,  widthOfBox, heightOfBox)
		ctx:set_source_rgba ((i % 8) * 1 / 7, ((i + 3) % 8) * 1 / 7, ((i + 6)  % 8) * 1 / 7,  1.0)
		--rint(widthOfBox)
		ctx:fill ()
	end
	if state[j*8 + i + 1] == 2 then
		ctx:rectangle (i * widthOfBox, j*heightOfBox,  widthOfBox, heightOfBox)
		ctx:set_source_rgba ((i % 8) * 1 / 4, ((i + 3) % 8) * 1 / 4, ((i + 6)  % 8) * 1 / 4,  0.5)
		--rint(widthOfBox)
		ctx:fill ()
	end
	if state[j*8 + i  + 1] == 3 then
		ctx:rectangle (i * widthOfBox, j*heightOfBox,  widthOfBox, heightOfBox)
		ctx:set_source_rgba (1.0, 1.0 , 1.0,  0.5)
		--rint(widthOfBox)
		ctx:fill ()
	end
	end 
	end


	return {w, h}

end

