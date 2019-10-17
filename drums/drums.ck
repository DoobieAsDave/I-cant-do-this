BPM tempo;

Gain master;
LPF kickFilter;
Echo accentEcho;

SndBuf kick => kickFilter => master;
SndBuf snare => Pan2 snarePan => master;
SndBuf tom => master;
SndBuf rim => master;
SndBuf hihat => master;
SndBuf openhat => master;
SndBuf accenthat => accentEcho => master;

accentEcho => Gain feedback => accentEcho;

master => dac;

///

me.dir(-1) + "audio/kick_c.wav" => kick.read;
me.dir(-1) + "audio/snare.wav" => snare.read;
me.dir(-1) + "audio/tom.wav" => tom.read;
me.dir(-1) + "audio/rim.wav" => rim.read;
me.dir(-1) + "audio/hihat.wav" => hihat.read;
me.dir(-1) + "audio/open.wav" => openhat.read;
me.dir(-1) + "audio/accent.wav" => accenthat.read;
kick.samples() => kick.pos;
snare.samples() => snare.pos;
tom.samples() => tom.pos;
rim.samples() => rim.pos;
hihat.samples() => hihat.pos;
openhat.samples() => openhat.pos;
accenthat.samples() => accenthat.pos;

120 => Std.mtof => kickFilter.freq;
2.0 => kickFilter.Q;
2.5 => kickFilter.gain;

tempo.quarterNote / 6 => accentEcho.max => accentEcho.delay;
.5 => accentEcho.mix;

.75 => tom.rate;
.5 => openhat.rate;

.8 => kick.gain => snare.gain => openhat.gain => hihat.gain => tom.gain => rim.gain;
.6 => feedback.gain;
(1.0 / 2.0) => master.gain;

function void runSample(SndBuf sample, int sequence[], dur duration) {
    while(true) {
        for (0 => int step; step <sequence.cap(); step++) {
            if (sequence[step]) {
                0 => sample.pos;            
            }

            duration => now;
        }
    }
}
function void runSnare(SndBuf sample, int sequence[], dur duration) {
    while(true) {
        for (0 => int beat; beat < 4; beat++) {
            for (0 => int step; step <sequence.cap(); step++) {
                if (sequence[step]) {
                    0.0 => snarePan.pan;
                    1.0 => sample.rate;
                    .8 => sample.gain;
                    0 => sample.pos;            
                }
                else {                    
                    Math.random2f(.3, .8) => sample.gain;
                    Math.random2f(-.75, .75) => snarePan.pan;
                    
                    if (beat < 3) {
                        if (beat != 0 && Math.random2(0, 10) > 8) {                            
                            Math.random2(0, Std.ftoi(sample.samples() * .1)) => sample.pos;
                        }    
                    }
                    else {
                        if (step >= Std.ftoi(sequence.cap() / 2) && Math.random2(0, 10) > 6) {                            
                            Math.random2(2, 3) => int rep;

                            repeat(rep) {                                
                                Math.random2f(1.0, 1.5) => sample.rate;
                                Math.random2(0, Std.ftoi(sample.samples() * .1)) => sample.pos;

                                duration / rep => now;
                            }

                            continue;
                        }
                    }
                }

                duration => now;
            }
        }
    }
}
function void runHat(SndBuf sample, int sequence[], dur duration) {
    while(true) {
        for (0 => int step; step <sequence.cap(); step++) {
            if (sequence[step]) {
                Math.random2f(.3, sample.gain()) => sample.gain;
                0 => sample.pos;            
            }

            duration => now;
        }
    }
}
function void runTom(SndBuf sample, int sequence[], dur duration) {
    while(true) {
        for (0 => int step; step <sequence.cap(); step++) {
            if (sequence[step]) {
                Math.random2f(.3, sample.gain()) => sample.gain;
                Math.random2f(.75, 1.25) => sample.rate;
                0 => sample.pos;            
            }            

            duration => now;
        }
    }
}

///
tempo.quarterNote => dur duration;

[1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0] @=> int kickPattern[];
[0, 0, 1, 0, 0, 0, 1, 0] @=> int snarePattern[];
[1, 1, 1, 1, 1, 1, 1, 1] @=> int hihatPattern[];
[0, 0, 0, 0, 0, 0, 0, 1] @=> int accentPattern[];
[0, 0, 1, 1, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0] @=> int tomPattern[];
[0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 1, 1] @=> int rimPattern[];

Shred kickShred, snareShred, hihatShred, accentShred, tomShred, rimShred;

tempo.note * 8 => now;
spork ~ runSample(kick, kickPattern, duration / 2) @=> kickShred;
tempo.note * 8 => now;
spork ~ runSnare(snare, snarePattern, duration) @=> snareShred;
tempo.note * 2 => now;
spork ~ runHat(hihat, hihatPattern, duration / 2) @=> hihatShred;
tempo.note * 6 => now;
spork ~ runHat(accenthat, accentPattern, duration / 3) @=> accentShred;
tempo.note * 16 => now;
spork ~ runTom(tom, tomPattern, duration / 2) @=> tomShred;
tempo.note * 8 => now;
spork ~ runSample(rim, rimPattern, duration / 2) @=> rimShred;
tempo.note * 16 => now; // 64

Machine.remove(tomShred.id());
tempo.note * 4 => now;
Machine.remove(rimShred.id());
tempo.note * 8 => now;
Machine.remove(accentShred.id());
tempo.note * 4 => now;
Machine.remove(hihatShred.id());
tempo.note * 4 => now;
Machine.remove(snareShred.id());
tempo.note => now;
Machine.remove(kickShred.id()); // 85