SndBuf snare => Gain master_gain => dac;
SndBuf kick => master_gain => dac;
SndBuf click => master_gain => dac;
SndBuf hh => master_gain => dac;

0.1 => master_gain.gain;

string kickFilenames[3];
me.dir() + "/samples/kick_01.wav" =>  kickFilenames[0];
me.dir() + "/samples/kick_02.wav" =>  kickFilenames[1];
me.dir() + "/samples/kick_03.wav" =>  kickFilenames[2];
kickFilenames[2] => kick.read;
kick.samples() => kick.pos;

string snareFilenames[3];
me.dir() + "/samples/snare_01.wav" =>  snareFilenames[0];
me.dir() + "/samples/snare_02.wav" =>  snareFilenames[1];
me.dir() + "/samples/snare_03.wav" =>  snareFilenames[2];
snareFilenames[2] => snare.read;
snare.samples() => snare.pos;

string clickFilenames[3];
me.dir() + "/samples/click_01.wav" =>  clickFilenames[0];
me.dir() + "/samples/click_02.wav" =>  clickFilenames[1];
me.dir() + "/samples/click_03.wav" =>  clickFilenames[2];
clickFilenames[2] => click.read;
click.samples() => click.pos;

string hhFilenames[4];
me.dir() + "/samples/hh_01.wav" =>  hhFilenames[0];
me.dir() + "/samples/hh_02.wav" =>  hhFilenames[1];
me.dir() + "/samples/hh_03.wav" =>  hhFilenames[2];
me.dir() + "/samples/hh_04.wav" =>  hhFilenames[3];
hhFilenames[2] => hh.read;
hh.samples() => hh.pos;

0.7 => snare.gain => kick.gain => hh.gain => click.gain;

// OSC
OscRecv orec;
//port 6449
6449 => orec.port;
orec.listen();

fun void oscLoadDrum() {
    orec.event("/load,si") @=> OscEvent event;   
    while ( true )
    { 
        event => now; // wait for events to arrive.
        <<<"load drum message">>>;
        while( event.nextMsg() != 0 )
        { 
            event.getString() => string type;
            event.getInt() => int index;
            <<<"changing drum drum: ", type, " to index ", index>>>;
            if (type == "hh" || type == "h") {
                hhFilenames[index] => hh.read;
            }
            else if (type == "click" || type == "c") {
                clickFilenames[index] => hh.read;
            }
            else if (type == "kick" || type == "k") {
                kickFilenames[index] => kick.read;
            }
            else if (type == "snare" || type == "s") {
                snareFilenames[index] => snare.read;
            }
        }
    }         

}

fun void oscPlayDrum() {
    orec.event("/play,s") @=> OscEvent event;   
    while ( true )
    { 
        event => now; // wait for events to arrive.
        while( event.nextMsg() != 0 )
        { 
            event.getString() => string type;
            // <<<"playing drum: ", type>>>;
            if (type == "hh" || type == "h") {
                0 => hh.pos;
            }
            else if (type == "click" || type == "c") {
                0 => click.pos;
            }
            else if (type == "kick" || type == "k") {
                0 => kick.pos;
            }
            else if (type == "snare" || type == "s") {
                0 => snare.pos;
            }
        }
    }         
}

fun void playDemo() {
    if (Math.random2(0, 100) < 30) {
        0 => kick.pos;
    }
    if (Math.random2(0, 100) < 30) {
        0 => snare.pos;
    }
    if (Math.random2(0, 100) < 80) {
        0 => hh.pos;
    }
    if (Math.random2(0, 100) < 50) {
        0 => click.pos;
    }
    0.25::second => now;   
}

spork ~ oscPlayDrum();
spork ~ oscLoadDrum();

while (true) {
    1::second => now;
}
