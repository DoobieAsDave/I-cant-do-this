BPM tempo;

Gain master;

SqrOsc pad[4];
pad[0] => master;
pad[1] => master;
pad[2] => master;
pad[3] => master;

master => ADSR adsr => dac;

.2 => pad[0].width => pad[1].width => pad[2].width => pad[3].width;

.25 => pad[0].gain => pad[1].gain => pad[2].gain => pad[3].gain;
(1.0 / 8.0) => master.gain;
((tempo.note * 4) * .4, 2250 :: ms, 1.0, (tempo.note * 4) * .5) => adsr.set;

tempo.note * 4 => dur bar;
[38, 36] @=> int keys[];
[tempo.note * 4, tempo.note * 4] @=> dur duration[];

///

float oscWidth;

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

spork ~ sequence(keys, duration, bar);

tempo.note * 96 => now;