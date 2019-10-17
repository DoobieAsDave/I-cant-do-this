BPM tempo;

Gain master;

SqrOsc voice1 => master;
SinOsc voice2 => master;

master => ADSR adsr => LPF filter => Echo delay => NRev reverb => dac;
delay => Gain feedback => delay;

///

.75 => voice2.gain;

(75 :: ms, 40 :: ms, 1.0, 750 :: ms) => adsr.set;

300.0 => filter.freq;
15.0 => filter.Q;

tempo.quarterNote * 3 => delay.max => delay.delay;

.05 => reverb.mix;

(1.0 / 4.0) => master.gain;
.5 => filter.gain => reverb.gain => feedback.gain;

///

tempo.note * 2 => dur bar;

[38, 36, 33, 34] @=> int notes[];
[tempo.note * 1.25, tempo.note * 1.1, tempo.note * 1.2, tempo.note * 1.35] @=> dur duration[];

///

Shred sequenceShred, freqShred, qShred, mixShred;

float filterFreq;
float filterQ;
float reverbMix;

function void modFilterFreq(LPF filter, dur modTime, float min, float max, float amount) {
    amount => float step;
    max - min => float range;
    (range / amount) * 2 => float steps;

    filter.freq() => filterFreq;

    while(true) {
        if (filterFreq >= max) {
            amount * -1 => step;
        }
        else if (filterFreq <= min) {
            amount => step;
        }

        filterFreq => filter.freq;
        step +=> filterFreq;

        modTime / steps => now;
    }
}
function void modFilterQ(LPF filter, dur modTime, float min, float max, float amount) {
    amount => float step;
    max - min => float range;
    (range / amount) * 2 => float steps;

    filter.Q() => filterQ;

    while(true) {
        if (filterQ >= max) {
            amount * -1 => step;
        }
        else if (filterQ <= min) {
            amount => step;
        }

        filterQ => filter.Q;
        step +=> filterQ;        

        modTime / steps => now;
    }
}

function void modReverbMix(NRev reverb, dur modTime, float min, float max, float amount) {
    amount => float step;
    max - min => float range;
    (range / amount) => float steps;

    reverb.mix() => reverbMix;

    while(true) {
        if (reverbMix >= max) {
            amount * -1 => step;
        }
        else if (reverbMix <= min) {
            amount => step;
        }

        reverbMix => reverb.mix;
        step +=> reverbMix;

        modTime / steps => now;
    }
}

///

function void sequence(int sequence[], dur duration[], dur bar) {
    while(true) {
        for (0 => int step; step < sequence.cap(); step++) {
            if (step == 0) {
                .05 => delay.mix;                

                Machine.remove(freqShred.id());
                Machine.remove(qShred.id());
                spork ~ modFilterFreq(filter, tempo.note * 3, 300.0, 450.0, 1.0) @=> freqShred;
                spork ~ modFilterQ(filter, tempo.halfNote / 3, 1.0, 5.0, 0.1) @=> qShred;
            }
            else if (step == sequence.cap() - 1) {
                .0 => delay.mix;
                
                Machine.remove(freqShred.id());
                Machine.remove(qShred.id());
                spork ~ modFilterFreq(filter, (tempo.note * 3) / 2, 300.0, 450.0, 1.0) @=> freqShred;
                spork ~ modFilterQ(filter, tempo.halfNote / 6, 1.0, 3.5, 0.1) @=> qShred;                
            }

            tempo.halfNote => now;

            sequence[step] => Std.mtof => voice1.freq;
            voice1.freq() / 2 => voice2.freq;
            
            1 => adsr.keyOn;
            duration[step] - adsr.releaseTime() => now;
            1 => adsr.keyOff;
            adsr.releaseTime() => now;
            
            bar - (tempo.halfNote + duration[step]) => now;
        }
    }
}

///

tempo.note * 16 => now;

spork ~ modReverbMix(reverb, tempo.note * 8, .05, .15, .01) @=> mixShred;

spork ~ sequence(notes, duration, bar) @=> sequenceShred;

tempo.note * 53 => now;