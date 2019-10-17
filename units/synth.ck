BPM tempo;

Gain master;
SinOsc lfo => blackhole;
SawOsc voice1[3] => master;
SawOsc voice2[3] => master;
SawOsc voice3[3] => master;
SawOsc voice4[3] => master;
master => ADSR adsr => dac;

voice1 => voice2 => voice3 => connectLFO;

///

0 => lfo.freq => lfo.gain;

(1.0 / 5.0) / 4.0 => master.gain;

///

function void connectLFO(SawOsc voice[]) {
    lfo => voice[0] => voice[1] => voice[2];
    2 => voice[0].sync => voice[1].sync => voice[2].sync;
}

///

float lfoFreq;
float lfoGain;

function void modLFOFreq(SinOsc lfo, dur modTime, float min, float max, float stepAmount) {
    stepAmount => float step;
    max - min => float range;
    (range / stepAmount) * 2 => float numbersOfSteps;

    lfo.freq() => lfoFreq;
    
    while(true) {
        if (lfoFreq >= max) {
            stepAmount * -1 => step;
        }
        else if (lfoFreq <= min) {
            stepAmount => step;
        }

        step +=> lfoFreq => lfo.freq;
        modTime / numbersOfSteps => now;        
    }
}
function void modLFOGain(SinOsc lfo, dur modTime, float min, float max, float stepAmount) {
    stepAmount => float step;
    max - min => float range;
    (range / stepAmount) * 2 => float numbersOfSteps;

    lfo.gain() => lfoGain;
    
    while(true) {
        if (lfoGain >= max) {
            stepAmount * -1 => step;
        }
        else if (lfoGain <= min) {
            stepAmount => step;
        }

        step +=> lfoGain => lfo.gain;
        modTime / numbersOfSteps => now;
    }
}

///

function void sequence(int sequence[], int harmony[], dur duration[], dur bar) {
    while(true) {
        for (0 => int step; step < sequence.cap(); step++) {
            setNotes(voice1, sequence[step]);            
            setNotes(voice3, sequence[step] + 7);
            if (harmony[step]) {
                setNotes(voice2, sequence[step] + 4);
                setNotes(voice4, sequence[step] + 11);
            }
            else {
                setNotes(voice2, sequence[step] + 3);
                setNotes(voice4, sequence[step] + 10);
            }
            
            setEnvelope(duration[step], bar - duration[step]);

            1 => adsr.keyOn;
            duration[step] => now;
            1 => adsr.keyOff;
            adsr.releaseTime() => now;

            bar - (duration[step] + adsr.releaseTime()) => now;
        }
    }
}
function void setNotes(SawOsc voice[], int key) {
    key => Std.mtof => voice[0].freq;
    voice[0].freq() + Math.random2f(.5, 50.0) => voice[1].freq;
    voice[0].freq() + Math.random2f(.5, 50.0) => voice[2].freq;
}
function void setEnvelope(dur noteDuration, dur downTime) {
    noteDuration * Math.random2f(.1, .4) => dur preSustain;

    preSustain * Math.random2f(.25, .9) => dur attack;
    preSustain - attack => dur decay;
    Math.random2f(.6, 1.0) => float sustain;
    downTime * Math.random2f(.8, 1.0) => dur release;    

    (attack, decay, sustain, release) => adsr.set;
}

///

tempo.note * 2 => dur bar;

[50, 48, 45, 46] @=> int notes[];
[1, 1, 1, 1] @=> int harmony[];
[bar / 3, bar / 3, bar / 3, bar * .8] @=> dur duration[];

///

//tempo.note * 16 => now;

spork ~ modLFOFreq(lfo, tempo.halfNote / 3, 0.0, 120.0, 10.0);
spork ~ modLFOGain(lfo, tempo.quarterNote / 3, 0.0, 5.0, .1);

spork ~ sequence(notes, harmony, duration, bar);

tempo.note * 61 => now;