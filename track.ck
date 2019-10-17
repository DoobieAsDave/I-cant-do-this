BPM tempo;

dac.gain(.75);
tempo.setBPM(121.0);

//Machine.add(me.dir() + "metro.ck");
Machine.add(me.dir() + "record.ck");
Machine.add(me.dir() + "drums/drums.ck");
Machine.add(me.dir() + "units/synth.ck");
//Machine.add(me.dir() + "units/bass.ck");
//Machine.add(me.dir() + "units/pad.ck");
Machine.add(me.dir() + "units/blit.ck");