ardour {
	["type"]    = "dsp",
	name        = "Midi Looper",
	category    = "Midi", 
	license     = "Who knows",
	author      = "R8000",
	description = [[A script that will play midi sequences on a loop triggered by a midi device]]
}

function dsp_ioconfig ()
	return { {midi_in = 1, midi_out = 7, audio_in = -1, audio_out = -1}, }
end
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
local midi_sequence1  =  { 
{time =  1.0 ,midi = { 0x90,  60 , 64 }},
{time =  1.25 ,midi = { 0x80,  60 , 0 }},
{time =  3.0 ,midi = { 0x90,  60 , 64 }},
{time =  3.25 ,midi = { 0x80,  60 , 0 }},
}
local midi_sequence2  =  { 
{time =  0.0 ,midi = { 0x90,  33 , 127 }},
{time =  0.88020833333333 ,midi = { 0x80,  33 , 0 }},
{time =  0.99583333333333 ,midi = { 0x90,  33 , 95 }},
{time =  1.6302083333333 ,midi = { 0x80,  33 , 0 }},
{time =  2.0 ,midi = { 0x90,  33 , 127 }},
{time =  2.25 ,midi = { 0x80,  33 , 0 }},
{time =  2.25 ,midi = { 0x90,  33 , 110 }},
{time =  2.5 ,midi = { 0x80,  33 , 0 }},
{time =  2.5 ,midi = { 0x90,  31 , 95 }},
{time =  2.75 ,midi = { 0x80,  31 , 0 }},
{time =  2.75 ,midi = { 0x90,  33 , 95 }},
{time =  3.0 ,midi = { 0x80,  33 , 0 }},
{time =  3.25 ,midi = { 0x90,  33 , 95 }},
{time =  3.5 ,midi = { 0x80,  33 , 0 }},
}
local midi_sequence3  =  { 
{time =  0.0 ,midi = { 0x90,  38 , 127 }},
{time =  0.88020833333333 ,midi = { 0x80,  38 , 0 }},
{time =  0.99583333333333 ,midi = { 0x90,  38 , 95 }},
{time =  1.6302083333333 ,midi = { 0x80,  38 , 0 }},
{time =  2.0 ,midi = { 0x90,  38 , 127 }},
{time =  2.25 ,midi = { 0x80,  38 , 0 }},
{time =  2.25 ,midi = { 0x90,  38 , 110 }},
{time =  2.5 ,midi = { 0x80,  38 , 0 }},
{time =  2.5 ,midi = { 0x90,  36 , 95 }},
{time =  2.75 ,midi = { 0x80,  36 , 0 }},
{time =  2.75 ,midi = { 0x90,  38 , 95 }},
{time =  3.0 ,midi = { 0x80,  38 , 0 }},
{time =  3.25 ,midi = { 0x90,  38 , 95 }},
{time =  3.5 ,midi = { 0x80,  38 , 0 }},
}
local midi_sequence4  =  { 
{time =  0.0 ,midi = { 0x90,  36 , 127 }},
{time =  0.88020833333333 ,midi = { 0x80,  36 , 0 }},
{time =  0.99583333333333 ,midi = { 0x90,  36 , 95 }},
{time =  1.6302083333333 ,midi = { 0x80,  36 , 0 }},
{time =  2.0 ,midi = { 0x90,  36 , 127 }},
{time =  2.25 ,midi = { 0x80,  36 , 0 }},
{time =  2.25 ,midi = { 0x90,  36 , 110 }},
{time =  2.5 ,midi = { 0x80,  36 , 0 }},
{time =  2.5 ,midi = { 0x90,  35 , 95 }},
{time =  2.75 ,midi = { 0x80,  35 , 0 }},
{time =  2.75 ,midi = { 0x90,  36 , 95 }},
{time =  3.0 ,midi = { 0x80,  36 , 0 }},
{time =  3.25 ,midi = { 0x90,  36 , 95 }},
{time =  3.5 ,midi = { 0x80,  36 , 0 }},
}
local midi_sequence5  =  { 
{time =  0.0 ,midi = { 0x90,  64 , 100 }},
{time =  0.25 ,midi = { 0x80,  64 , 0 }},
{time =  2.0 ,midi = { 0x90,  64 , 100 }},
{time =  2.25 ,midi = { 0x80,  64 , 0 }},
}
local midi_sequence6  =  { 
{time =  0.0 ,midi = { 0x90,  56 , 64 }},
{time =  0.5 ,midi = { 0x80,  56 , 0 }},
{time =  0.5 ,midi = { 0x90,  56 , 64 }},
{time =  1.0 ,midi = { 0x80,  56 , 0 }},
{time =  1.0 ,midi = { 0x90,  56 , 64 }},
{time =  1.5 ,midi = { 0x80,  56 , 0 }},
{time =  1.5 ,midi = { 0x90,  56 , 64 }},
{time =  2.0 ,midi = { 0x80,  56 , 0 }},
{time =  2.0 ,midi = { 0x90,  56 , 64 }},
{time =  2.5 ,midi = { 0x80,  56 , 0 }},
{time =  2.5 ,midi = { 0x90,  56 , 64 }},
{time =  3.0 ,midi = { 0x80,  56 , 0 }},
{time =  3.0 ,midi = { 0x90,  56 , 64 }},
{time =  3.5 ,midi = { 0x80,  56 , 0 }},
{time =  3.5 ,midi = { 0x90,  56 , 64 }},
{time =  4.0 ,midi = { 0x80,  56 , 0 }},
}
local allMidi = { midi_sequence1,midi_sequence2,midi_sequence3, midi_sequence4, midi_sequence5, midi_sequence6}
local midi_notes_state = {}
local midi_notes_state_at_next_bar = {}
local input_notes_to_output_channel_map = {}
local total_notes = 127
local total_midi_out = 7
local channelIsActive = {}
function dsp_init (rate)
	
	self:shmem():allocate(total_notes)
	self:shmem():clear()
	local bpm = 120

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
	end
	for i = 1, total_notes do
		input_notes_to_output_channel_map[i] =  (i % (total_midi_out - 1)) + 2
	end
	print "managed to reload!"
	load_midi_from_ranges()
end

function string.starts(String,Start)
   return string.sub(String,1,string.len(Start))==Start
end
function load_midi_from_ranges ()

	  local all_regions = ARDOUR.RegionFactory.regions()
	  local count = 1
	  for _, r in all_regions:iter() do
		  local mr = r:to_midiregion ()
			if mr:isnil () then goto next end
			if string.starts(r:name(), "loop") then
				local nl = ARDOUR.LuaAPI.note_list (mr:model ()) 
				local midiName = "midi_sequence" .. count
				local newMidi = {};
				local noteCount = 1
				  for n in nl:iter () do
					  newMidi[noteCount] = {time = n:time():to_double(), midi = { 0x90, n:note(), n:velocity()}}
					  noteCount = noteCount + 1
					  newMidi[noteCount] = {time = n:time():to_double() + n:length():to_double(), midi = {0x80, n:note(),0}}
					  noteCount = noteCount + 1
					  print ("{time = ", n:time ():to_double(), ",midi = { 0x90, ", (n:note ()),
					 ",", n:velocity () , "}},")

					   print ("{time = ", n:time ():to_double() + n:length():to_double(),    ",midi = { 0x80, ", (n:note ()),
					 ",", 0, "}},")


				  end
				  allMidi[count] = newMidi
				  print("Added pattern ", count)
				  count = count + 1 
			
			end
			::next::
		end	

end
function dsp_dsp_midi_input ()
	return true
end

function doSingleChannelNoLoop (bufs, in_map, out_map, n_samples, offset,channel, time, midi)

	assert (spb > 1)
	local ob = out_map:get (ARDOUR.DataType ("midi"), channel)
	if ob ~= ARDOUR.ChanMapping.Invalid then
		local mb = bufs:get_midi (ob)
		local ba = C.ByteVector()
		ba:add (midi) -- add some data to the vector
		mb:push_back (offset + time, ba:size (), ba:to_array());
		ba:clear ()
    	end		
	-- passthrough audio, apply pin/channel mapping
	ARDOUR.DSP.process_map (bufs, in_map, out_map, n_samples, offset, ARDOUR.DataType ("audio"))
end

function update_loop_on_or_off (bufs, in_map, out_map, n_samples, offset)

	 local ob2 = in_map:get (ARDOUR.DataType ("midi"), 0)
	 local mb2 = bufs:get_midi(ob2)
	 local events = mb2:table ()
	 for _, e in pairs (events) do
		if(e:size () == 3) then
			local table = e:buffer():get_table(e:size())
			local noteVal = table[2]
			if(table[1] == 144) then --on
			 midi_notes_state_at_next_bar[noteVal] = (midi_notes_state_at_next_bar[noteVal] + 1) % 2	
			 if(midi_notes_state_at_next_bar[noteVal] == 1 and midi_notes_state[noteVal] == 0) then
			   local shmem = self:shmem()
			   local state = shmem:to_int(0):array()
			   midi_notes_state[noteVal] = 2
			   state[noteVal] = midi_notes_state[noteVal]
			   self:queue_draw ()
			 end
			 if(midi_notes_state_at_next_bar[noteVal] == 0  and midi_notes_state[noteVal] == 1) then
			   local shmem = self:shmem()
			   local state = shmem:to_int(0):array()
			   midi_notes_state[noteVal] = 3
			   state[noteVal] = midi_notes_state[noteVal]
			   self:queue_draw ()
			 end
			 end
--		print (e:channel (), e:time (), e:size (), e:buffer():array (), e:buffer ():get_table (e:size ())[1], e:buffer():get_table (e:size ())[2], e:buffer():get_table (e:size())[3])
		 
		end
	 end
	local transportSample = Session:transport_sample() 
	if(currentOffset >= samplesPerBar) then
		--if(transportSample > 0) then
		--currentOffset = transportSample %  samplesPerBar
		--else
		currentOffset = currentSample %  samplesPerBar
		--end
		local shmem = self:shmem()
		local state = shmem:to_int(0):array()
		for i = 1, 127 do
	--		 if(midi_notes_state[i] == 0 and midi_notes_state_at_next_bar[i] == 1) then
	--		 channelIsActive[input_notes_to_output_channel_map[i]] = channelIsActive[input_notes_to_output_channel_map[i]] + 1
	--	 	 end
	--		 if(midi_notes_state[i] == 1 and midi_notes_state_at_next_bar[i] == 0) then
	--		 channelIsActive[input_notes_to_output_channel_map[i]] = channelIsActive[input_notes_to_output_channel_map[i]] - 1
	--	         end
			 midi_notes_state[i] = midi_notes_state_at_next_bar[i] 
			 state[i] = midi_notes_state[i]
			 self:queue_draw ()
			 
		end
	end

end
function dsp_runmap (bufs, in_map, out_map, n_samples, offset)

	update_loop_on_or_off(bufs, in_map, out_map, n_samples, offset)

	for i = 2,total_midi_out  do 
	--if(channelIsActive[i] >= 1) then
	local midiLocal = allMidi[i-1]
	for _, midiData in pairs (midiLocal) do
		local timeAsAnOffset = math.floor(midiData.time * samplesPerBar /4.0)
		local modOffset = ((currentOffset + n_samples) % samplesPerBar) - n_samples
		if((timeAsAnOffset >= modOffset  and timeAsAnOffset < modOffset + n_samples)) then
		for note = 1, total_notes do
			if(modOffset < 0) then
		--		local shmem = self:shmem()
		--		local state = shmem:to_int(0):array()
				midi_notes_state[note] = midi_notes_state_at_next_bar[note]
		--		state[note] = midi_notes_state[note]
		--		self:queue_draw ()
			end
			if(input_notes_to_output_channel_map[note] == i and  midi_notes_state[note]) == 1 then
				doSingleChannelNoLoop(bufs, in_map, out_map, n_samples, timeAsAnOffset - modOffset  , i-1 , 0,midiData.midi)
			end
		end
	end
 --	end
	end
	end
	currentOffset = currentOffset + n_samples
	currentSample = currentSample + n_samples
      	

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
	for i = 0,7 do
	for j = 0,7 do
		--print(i*8 + j)
	--print(state[i*8 + j + 1])
	--temporary punt up the location
	if state[i*8 +  j + 1 + 20] == 1 then
		ctx:rectangle (i * widthOfBox, j*heightOfBox,  widthOfBox, heightOfBox)
		ctx:set_source_rgba ((j % 3) * 1 / 2, ((j + 1) % 3) * 1 / 2, ((j + 2)  % 3) * 1 / 2,  1.0)
		--rint(widthOfBox)
		ctx:fill ()
	end
	if state[i*8 + j + 1 + 20] == 2 then
		ctx:rectangle (i * widthOfBox, j*heightOfBox,  widthOfBox, heightOfBox)
		ctx:set_source_rgba ((j % 3) * 1 / 4, ((j + 1) % 3) * 1 / 4, ((j + 2)  % 3) * 1 / 4,  0.5)
		--rint(widthOfBox)
		ctx:fill ()
	end
	if state[i*8 + j + 1 + 20] == 3 then
		ctx:rectangle (i * widthOfBox, j*heightOfBox,  widthOfBox, heightOfBox)
		ctx:set_source_rgba (0.3, 0.3, 0.3,  0.5)
		--rint(widthOfBox)
		ctx:fill ()
	end
	end 
	end


	return {w, h}

end
