me.arg(0) => string filename;

if (filename.length() == 0) {
    "i cant do this - lead - 121bpm.wav" => filename;
}

dac => WvOut2 w => blackhole;

filename => w.wavFilename;
<<< "writing to: ", "'" + w.filename() + "'">>>;

null @=> w;

while(true)
    1 :: second => now;