BPM tempo;

BlitSquare blit => ADSR adsr => Pan2 stereo => Echo delay => dac;
delay => Gain feedback => delay;

tempo.note / 3 => delay.max => delay.delay;
.0 => delay.mix;

.0 => blit.gain;
.5 => feedback.gain;

50 => int key;
[0, 2, 4, 5, 7, 9, 11, 12] @=> int scale[];

float volume;
float stereoPan;
float delayMix;

function void modVolume(BlitSquare blit, dur modTime, float min, float max, float amount) {
    amount => float step;
    max - min => float range;
    (range / amount) * 2 => float steps;

    blit.gain() => volume;

    while(true) {
        if (volume >= max) {
            amount * -1 => step;
        }
        else if (volume <= min) {
            amount => step;
        }

        volume => blit.gain;
        step +=> volume;

        modTime / steps => now;
    }
}
function void modStereo(Pan2 stereo, dur modTime, float min, float max, float amount) {
    amount => float step;
    max - min => float range;
    (range / amount) * 2 => float steps;

    stereo.pan() => stereoPan;

    while(true) {
        if (stereoPan >= max) {
            amount * -1 => step;
        }
        else if (stereoPan <= min) {
            amount => step;
        }

        stereoPan => stereo.pan;
        step +=> stereoPan;

        modTime / steps => now;
    }
}
function void modDelayMix(Echo delay, dur modTime, float min, float max, float amount) {
    amount => float step;
    max - min => float range;
    (range / amount) * 2 => float steps;

    delay.mix() => delayMix;

    while(true) {
        if (delayMix >= max) {
            amount * -1 => step;
        }
        else if (delayMix <= min) {
            amount => step;
        }

        delayMix => delay.mix;
        step +=> delayMix;

        modTime / steps => now;
    }
}

function void runBlit() {
    while(true) {
        for(0 => int step; step < 8; step++) {
            (Math.random2(0, 40) :: ms, Math.random2(10, 60) :: ms, .8, Math.random2(20, 100) :: ms) => adsr.set;

            key + scale[Math.random2(0, scale.cap() - 1)] => Std.mtof => blit.freq;
            Math.random2(1, 3) => blit.harmonics;
            
            if (step >= 4 && step % 2 == 1) {
                Math.random2(1, 4) => int rep;

                repeat(rep) {
                    Math.random2(1, 5) => blit.harmonics;

                    1 => adsr.keyOn;
                    (tempo.quarterNote / rep) - adsr.releaseTime() => now;
                    1 => adsr.keyOff;
                    adsr.releaseTime() => now;
                }
            }
            else {
                1 => adsr.keyOn;
                tempo.quarterNote - adsr.releaseTime() => now;
                1 => adsr.keyOff;
                adsr.releaseTime() => now;
            }        
        }
    }
}

//tempo.note * 16 => now;
tempo.note * 8 => now;

spork ~ modVolume(blit, tempo.note * 4, .075, .125, .01);
spork ~ modStereo(stereo, tempo.note * 3, -1.0, 1.0, .1);
spork ~ modDelayMix(delay, tempo.note * 12, .05, .35, .01);

spork ~ runBlit();

tempo.note * 77 => now;