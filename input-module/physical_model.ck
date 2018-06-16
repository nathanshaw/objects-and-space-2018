// Physical model instrument for O&S
Mandolin mand => NRev reverb => Gain gain => dac;
0.1 => gain.gain;

0.4 => float reverbMix => reverb.mix;

[48.0, 52.0, 55.0, 59.0, 60.0, 64.0, 67.0, 71.0, 72.0] @=> float notes[];

Math.random2f(0, 1.0) => float pluckPos;
Math.random2f(0, 1.0) => float stringDamp;
Math.random2f(0, 1.0) => float detune;
48.0 => float note;
Std.mtof(note) => float freq;

fun void randomizeParameters() {
    Math.random2f(0, 1.0) => pluckPos;
    Math.random2f(0, 1.0) => stringDamp;
    Math.random2f(0, 1.0) => detune;
    mand.pluckPos(pluckPos);
    mand.stringDamping(stringDamp);
    mand.stringDetune(detune);  
}

fun float newRandomNote() {
    // choose note randomly
    notes[Math.random2(0, notes.size() - 1)] => note;
    Std.mtof(note) => freq;
    freq => mand.freq;
    return note;
}

// OSC
OscRecv orec;
//port 6449
6449 => orec.port;
orec.listen();


fun void oscPluck() {
    orec.event("/play,if") @=> OscEvent event;   
    while ( true )
    { 
        event => now; // wait for events to arrive.
        while( event.nextMsg() != 0 )
        { 
            event.getInt() => int note_index;
            if (note_index >= 0 && note_index <= notes.size()-1){
                Std.mtof(notes[note_index]) => mand.freq;
            }
            event.getFloat() => float vel;
            <<<"note on , ", note_index, " at velocity: ", vel>>>;
            mand.pluck( vel );
        }
    }         
}

fun void oscDamping() {
    orec.event("/damping,f") @=> OscEvent event;   
    while ( true )
    { 
        event => now; // wait for events to arrive.
        // grab the next message from the queue. 
        while( event.nextMsg() != 0 )
        { 
            // getFloat fetches the expected float
            // as indicated in the type string ",f"
            mand.stringDamping( event.getFloat() );
        }
    }         
}

fun void oscPluckPos() {
    orec.event("/pluck_pos,f") @=> OscEvent event;   
    while ( true )
    { 
        event => now; // wait for events to arrive.
        while( event.nextMsg() != 0 )
        { 
            mand.pluckPos( event.getFloat() );
        }
    }         
}


fun void oscDetune() {
    orec.event("/detune,f") @=> OscEvent event;   
    while ( true )
    { 
        event => now; // wait for events to arrive.
        while( event.nextMsg() != 0 )
        { 
            mand.stringDetune( event.getFloat() );
        }
    }         
}

fun void oscChangeParameters() {
    orec.event("/parameters,fff") @=> OscEvent event;  // pluck pos, damping, detune 
    while ( true )
    { 
        event => now; // wait for events to arrive.
        while( event.nextMsg() != 0 )
        { 
            event.getFloat() => pluckPos;
            event.getFloat() => stringDamp;
            event.getFloat() => detune;
            event.getFloat() => reverbMix;
            <<<"pos: ", pluckPos, " damp:", stringDamp, " detune:", detune, " verbMix:", reverbMix>>>;
            mand.pluckPos( pluckPos);
            mand.stringDamping( stringDamp );
            mand.stringDetune( detune );
            reverb.mix(reverbMix);
        }
    }         
}

spork ~ oscPluck();
spork ~ oscPluckPos();
spork ~ oscDamping();
spork ~ oscDetune();
spork ~ oscChangeParameters();

while (1) {
    /*
    randomizeParameters();
    newRandomNote();
    mand.pluck(Math.random2f(0.9, 1.0));
    <<<"pluckpos: ", pluckPos, " Damping: ", stringDamp, 
    " Detune: ", detune, "note : ", note, " freq: ", freq>>>;    
    */
    1::second => now;
}
