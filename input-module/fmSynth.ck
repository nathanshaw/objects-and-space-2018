// OSC time now
OscRecv orec;
//port 6449
6449 => orec.port;
orec.listen();

// FM synthesis instrument for O&S
SinOsc mod => blackhole;
SinOsc carrier => ADSR adsr => JCRev reverb => Gain output_gain => dac;
0 => carrier.sync;

0 => int current_mode;// 0 is note on 1 is continuous
1 => int GUI;
1000 => float cf;
cf => carrier.freq;
89 => float mf;
mf => mod.freq;
200 => float index; //mod.gain;
0.15 => output_gain.gain;

// note stuff
[36.0, 40.0, 43.0, 47.0, 48.0, 52.0, 55.0, 59.0, 60.0] @=> float notes[];
3.5 => float freq_ratio;
2 => int octave;

// envelope
adsr.set(35::ms, 70::ms, 0.3, 600::ms);

//GUI
/*
MAUI_View view;
MAUI_Slider s_mod_gain, s_mod_freq, s_carrier_freq, s_output_gain, s_reverb_mix;
MAUI_Button b_play, b_cont;
view.size(800, 400);

65 => int s_height;
350 => int s_width;

s_reverb_mix.range(0.0, 1.0);
s_reverb_mix.size(s_width, s_height);
s_reverb_mix.position(0,0);
s_reverb_mix.value(0.0);
s_reverb_mix.name("Reverb Mix");
view.addElement(s_reverb_mix);

s_mod_gain.range(10, 500);
s_mod_gain.size(s_width, s_height);
s_mod_gain.position(s_reverb_mix.x(), s_reverb_mix.y() + s_reverb_mix.height());
s_mod_gain.value(200);
s_mod_gain.name("Modulator Gain");
view.addElement(s_mod_gain);

s_mod_freq.range(0.5, 1000);
s_mod_freq.size(s_width, s_height);
s_mod_freq.position(0, s_mod_gain.y() + s_mod_gain.height());
s_mod_freq.value(mf);
s_mod_freq.name("Modulator Frequency");
view.addElement(s_mod_freq);
view.display();

s_carrier_freq.range(0.5, 10000);
s_carrier_freq.size(s_width, s_height);
s_carrier_freq.position(0, s_mod_freq.y() + s_mod_freq.height());
s_carrier_freq.value(cf);
s_carrier_freq.name("Carrier Frequency");
view.addElement(s_carrier_freq);
view.display();

s_output_gain.range(0.0, 0.9);
s_output_gain.size(s_width, s_height);
s_output_gain.position(0, s_carrier_freq.y() + s_carrier_freq.height());
s_output_gain.value(0.7);
s_output_gain.name("Output Gain");
view.addElement(s_output_gain);

b_play.pushType();
b_play.size(s_output_gain.width(), s_output_gain.height());
b_play.position(s_output_gain.x(), s_output_gain.y() + s_output_gain.height());
b_play.name("Play Note");
view.addElement(b_play);

b_cont.toggleType();
b_cont.size(b_play.width(), b_play.height());
b_cont.position(b_play.x() + b_play.width(), b_play.y());
b_cont.name("Note Mode");
view.addElement(b_cont);

view.display();

spork ~ modGainSlider(s_mod_gain);
spork ~ modFreqSlider(s_mod_freq);
spork ~ carrierFreqSlider(s_carrier_freq);
spork ~ outputGainSlider(s_output_gain);
spork ~ reverbMixSlider(s_reverb_mix);
spork ~ playButton(b_play);
spork ~ contButton(b_cont);
<<<"Created GUI Components">>>;
*/

fun void oscEnvParameters() {
    orec.event("/envParameters,ffff") @=> OscEvent event;   
    while ( true )
    { 
        event => now; // wait for events to arrive.
        while( event.nextMsg() != 0 )
        { 
            event.getFloat() => float a;
            event.getFloat() => float d;
            event.getFloat() => float s;
            event.getFloat() => float r;
            a::ms => adsr.attackTime;
            d::ms => adsr.decayTime;
            s => adsr.sustainLevel;
            r::ms => adsr.releaseTime;
            <<<"a:",a,"d:",d,"s:",s,"r:",r>>>;
        }
    }         
}

fun void oscNoteOn() {
    orec.event("/noteOn,i") @=> OscEvent event;   
    while ( true )
    { 
        event => now; // wait for events to arrive.
        while( event.nextMsg() != 0 )
        { 
            event.getInt() => int note;
            Std.mtof(notes[note] + (octave*12)) => float f;
            f => carrier.freq;
            carrier.freq() * freq_ratio => mod.freq;
            // s_carrier_freq.value(carrier.freq());
            // s_mod_freq.value(mod.freq());
            adsr.keyOn();
        }
    }    
}

fun void oscNoteOff() {
    orec.event("/noteOff,i") @=> OscEvent event;   
    while ( true )
    { 
        event => now; // wait for events to arrive.
        while( event.nextMsg() != 0 )
        { 
            event.getInt() => int _trash;
            adsr.keyOff();
        }    
    }    
}

fun void oscFreqRatio() {
    orec.event("/freqRatio,f") @=> OscEvent event;   
    while ( true )
    { 
        event => now; // wait for events to arrive.
        while( event.nextMsg() != 0 )
        { 
            event.getFloat() => freq_ratio;
            <<<"Freq Ratio Changed to ", freq_ratio>>>;
            carrier.freq() * freq_ratio => mod.freq;
        }    
    }    
}

fun void oscReverbMix() {
    orec.event("/reverbMix,f") @=> OscEvent event;   
    while ( true )
    { 
        event => now; // wait for events to arrive.
        while( event.nextMsg() != 0 )
        { 
            event.getFloat() => float r_mix;
            <<<"Reverb Mix Changed to ", r_mix>>>;
            // s_reverb_mix.value(r_mix);
            r_mix => reverb.mix;
        }    
    }    
}

fun void triggerADSR(float a, float d){
    adsr.keyOn();
    (a + d)::ms => now;
    adsr.keyOff(); 
}

/*
fun void playButton(MAUI_Button b) {
    while(1) {
        b => now;
        adsr.keyOn();
        0.5::second => now;
        adsr.keyOff();
    }
}

fun void contButton(MAUI_Button b) {
    while(1) {
        b => now;
        if (current_mode == 0) {
            carrier =< adsr;
            carrier => reverb;
            1 => current_mode;
        }
        else {
            carrier =< reverb;
            carrier => adsr;
            0 => current_mode;
        }
    }
}

fun void modGainSlider(MAUI_Slider s) {
    while(1){
        s => now;
        s.value() => mod.gain;
    }
}

fun void modFreqSlider(MAUI_Slider s) {
    while(1){
        s => now;
        s.value() => mod.freq;
    }    
}

fun void carrierFreqSlider(MAUI_Slider s) {
    while(1){
        s => now;
        s.value() => cf;
        cf => carrier.freq;
        <<<"set carrier freq to :", s.value()>>>;
    }  
}

fun void outputGainSlider(MAUI_Slider s) {
    while(1){
        s => now;
        s.value() => output_gain.gain;
    }  
}

fun void reverbMixSlider(MAUI_Slider s) {
    while(1){
        s => now;
        s.value() => reverb.mix;
    }  
}
*/

spork ~ oscNoteOn();
spork ~ oscNoteOff();
spork ~ oscEnvParameters();
spork ~ oscFreqRatio();
spork ~ oscReverbMix();

while(true) {
    cf + (index * mod.last()) => carrier.freq;
    1::samp => now;
}
