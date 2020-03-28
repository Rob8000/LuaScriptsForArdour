ardour {
	["type"]    = "dsp",
	name        = "Midi Record",
	category    = "Midi", 
	license     = "Who knows",
	author      = "R8000",
	description = [[hello]]
}

function dsp_ioconfig ()
	return { {midi_in = 1, midi_out = 2, audio_in = -1, audio_out = -1}, }
end

function dsp_configure(ins, outs)
	n_out = outs
	n_out:set_midi(0)
end
local distanceFromRecordStart = -1
local distanceFromLoopStart = 0
local recordOnAtPreviousCheck = 0
local loopOnAtPreviousCheck = 0
local sizeOfLoop = 10000000000
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
}
function dsp_params ()
 return
 {
	 {["type"] = "input", name = "Record", min = 0, max = 1, default = 0, enum = true, scalepoints  =
	 {
		 ["Off"] = 0,
		 ["On"] = 1
	 }
 	 },
	 {["type"] = "input", name = "Loop", min = 0, max = 1, default = 0, enum = true, scalepoints  =
	 {
		 ["Off"] = 0,
		 ["On"] = 1
	 }
 	 }
 }
end
function dsp_init (rate)

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
end

function string.starts(String,Start)
   return string.sub(String,1,string.len(Start))==Start
end
function dsp_dsp_midi_input ()
	return true
end



function dsp_run (_, _, n_samples)
	assert (type(midiin) == "table")
	assert (type(midiout) == "table")
         local ctrl = CtrlPorts:array()
	 local record = ctrl[1]
	 if(recordOnAtPreviousCheck <1 and record == 1) then
	   distanceFromRecordStart = 0	
	   recordOnAtPreviousCheck = 1
	   midi_sequence1 = {}
	 end
	 if(recordOnAtPreviousCheck == 1 and record < 1) then
		 sizeOfLoop = distanceFromRecordStart
		 print(sizeOfLoop)
	 end
	 recordOnAtPreviousCheck = record
	 local loop = ctrl[2]
	 if(loopOnAtPreviousCheck  < 1 and loop == 1) then
		 distanceFromLoopStart = 0
		 loopOnAtPreviousCheck = 1
         end
	 loopOnAtPreviousCheck = loop
	if(record == 1) then
	for _,b in pairs (midiin) do
		local t = b["time"] -- t = [ 1 .. n_samples ]
		local d = b["data"] -- get midi-event
		local event_type
		if #d == 0 then event_type = -1 else event_type = d[1] >> 4 end

		if (#d == 3 ) then -- note on
			local midiNoteAndTime = {time= t + distanceFromRecordStart, midi= d}
			table.insert(midi_sequence1, midiNoteAndTime)
		end
	end
	end
	if(loop == 1) then
		if(distanceFromLoopStart > sizeOfLoop) then
			distanceFromLoopStart = 0
		end
		local m = 1
		for _, midiAndTime in pairs(midi_sequence1) do
			local offset = midiAndTime.time - distanceFromLoopStart 
			if(offset >=0 and offset < n_samples) then
				midiout[m] = {}
				midiout[m]["time"] = offset
				midiout[m]["data"] = midiAndTime.midi
				m = m + 1
			end
		end
	end
	distanceFromLoopStart = distanceFromLoopStart + n_samples
	distanceFromRecordStart = distanceFromRecordStart + n_samples
end
