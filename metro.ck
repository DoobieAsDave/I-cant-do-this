BPM tempo;

Shakers shaker => dac;

0 => shaker.preset;
.2 => shaker.gain;

while(true) {
    1 => shaker.noteOn;
    tempo.quarterNote => now;
}