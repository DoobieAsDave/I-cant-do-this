BPM tempo;

Pan2 left, right;
Gain master;

SqrOsc pad[4];
pad[0] => left => master;
pad[1] => right => master;
pad[2] => right => master;
pad[3] => left => master;

master => ADSR adsr => BRF filter => dac;

-.7 => left.pan;
.48 => right.pan;

.2 => pad[0].width => pad[1].width => pad[2].width => pad[3].width;

.25 => pad[0].gain => pad[1].gain => pad[2].gain => pad[3].gain;
(1.0 / 8.0) => master.gain;

((tempo.note * 4) * .4, 2250 :: ms, 1.0, (tempo.note * 4) * .5) => adsr.set;

20 => Std.mtof => filter.freq;
2 => filter.Q;
.8 => filter.gain;

///

tempo.note * 4 => dur bar;
[38, 36] @=> int keys[];
[tempo.note * 4, tempo.note * 4] @=> dur duration[];

///

float oscWidth;
float filterFreq;
float filterQ;

function void modOscWidth(SqrOsc pad[], dur modTime, float min, float max, float amount) {
    amount => float step;
    max - min => float range;
    (range / amount) * 2 => float steps;

    pad[0].width() => oscWidth;

    while(true) {
        if (oscWidth >= max) {
            amount * -1 => step;
        }
        else if (oscWidth <= min) {
            amount => step;
        }

        oscWidth => pad[0].width => pad[1].width => pad[2].width => pad[3].width;
        step +=> oscWidth;

        modTime / steps => now;
    }
}

function void modFilterFreq(BRF filter, dur modTime, float min, float max, float amount) {
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
function void modFilterQ(BRF filter, dur modTime, float min, float max, float amount) {
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

function void sequence(int keys[], dur duration[], dur bar) {
    while(true) {
        for (0 => int step; step < keys.cap(); step++) {
            keys[step] => Std.mtof => pad[0].freq;
            keys[step] + 4 => Std.mtof => pad[1].freq;
            keys[step] + 7 => Std.mtof => pad[2].freq;
            keys[step] + 11 => Std.mtof => pad[3].freq;

            1 => adsr.keyOn;
            duration[step] - adsr.releaseTime() => now;
            1 => adsr.keyOff;
            adsr.releaseTime() => now;

            bar - duration[step] => now;
        }
    }
}

///

spork ~ modOscWidth(pad, tempo.note * 3, .2, .8, .01);
spork ~ modFilterFreq(filter, tempo.note * 8, Std.mtof(20), Std.mtof(60), .01);
spork ~ modFilterQ(filter, tempo.halfNote * 7, 50.0, 100.0, .01);

spork ~ sequence(keys, duration, bar);

tempo.note * 96 => now;