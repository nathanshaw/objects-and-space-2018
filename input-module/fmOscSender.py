from pythonosc import osc_message_builder
from pythonosc import udp_client
import time
import sys
import random

if __name__ == "__main__":
    ip = "127.0.0.1"
    port = 6449

    client = udp_client.SimpleUDPClient(ip, port)

    while True:
        attack = random.random()*100
        decay = random.random()*100
        sustain = random.random() * 0.6 + 0.1
        release = random.random()*1000

        freq_ratio = float(random.randint(1,4))
        reverb_mix = random.random()

        if random.random() < 0.4:
            freq_ratio = freq_ratio - 0.5
        if random.random() < 0.02:
            client.send_message("/envParameters", [attack, decay, sustain, release]);
            print("envParameters: a:{} d:{} s:{} r{}".format(attack, decay,
                sustain, release))

        if random.random() < 0.05:
            client.send_message("/freqRatio", freq_ratio)
            print("changed freqRatio to :", freq_ratio)

        if random.random() < 0.05:
            client.send_message("/reverbMix", reverb_mix)
            print("changed reverb mix to :", reverb_mix)

        client.send_message("/noteOn", random.randint(0, 8))
        sys.stdout.write("note on ")
        sys.stdout.flush()
        time.sleep(random.random())
        client.send_message("/noteOff", 1)
        sys.stdout.write("note off \n")
        sys.stdout.flush()
        time.sleep(release/500)