from pythonosc import osc_message_builder
from pythonosc import udp_client
import argparse
import time
import sys
import random

def parseCommandLineArgs():
    parser = argparse.ArgumentParser()
    parser.add_argument("-v", "--verbose",
                        action="store_true", help="will enable print statements")
    return parser.parse_args()

if __name__ == "__main__":
    ip = "127.0.0.1"
    port = 6449

    client = udp_client.SimpleUDPClient(ip, port)

    args = parseCommandLineArgs()


    while True:
        attack = random.random()*100
        decay = random.random()*100
        sustain = random.random() * 0.6 + 0.1
        release = random.random()*100

        freq_ratio = random.randint(0,9)
        reverb_mix = random.random()

        if random.random() < 0.05:
            client.send_message("/envParameters", [attack, decay, sustain, release]);
            if args.verbose is True:
                print("envParameters: a:{} d:{} s:{} r{}".format(attack, decay,
                    sustain, release))

        if random.random() < 0.05:
            client.send_message("/freqRatio", freq_ratio)
            if args.verbose is True:
                print("changed freqRatio to :", freq_ratio)

        if random.random() < 0.05:
            client.send_message("/reverbMix", reverb_mix)
            if args.verbose is True:
                print("changed reverb mix to :", reverb_mix)

        if random.random() < 0.05:
            client.send_message("/mode", random.randint(0,2))
            if args.verbose is True:
                print("changed carrier mode")

        client.send_message("/noteOn", random.randint(0, 9))

        if args.verbose is True:
            sys.stdout.write("note on ")
            sys.stdout.flush()

        time.sleep(random.random())
        client.send_message("/noteOff", 1)

        if args.verbose is True:
            sys.stdout.write("note off \n")
            sys.stdout.flush()
        time.sleep(release/250)
