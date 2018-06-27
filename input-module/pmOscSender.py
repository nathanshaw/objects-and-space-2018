from pythonosc import osc_message_builder
from pythonosc import udp_client
import argparse
import time
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

    current_instrument = 0
    current_mode = 0
    while True:
        pluck_pos = random.random()
        damping = random.random()
        detune = random.random()
        verb = random.random()/3
        vel = (random.random()+2)/3
        note = random.randint(0, 8)
        client.send_message("/parameters", [pluck_pos, damping, detune, verb])
        client.send_message("/play", [note, vel]);
        if random.random() < 0.07:
            if current_instrument == 0:
                current_instrument = 1
            else:
                current_instrument = 0
            client.send_message("/instrument", current_instrument)
            if args.verbose is True:
                print("changed instrument")
        if random.random() < 0.07:
            if current_mode == 0:
                current_mode = 1
            else:
                current_mode = 0
            client.send_message("/mode", current_mode)
            if args.verbose is True:
                print("changed playMode")
        if args.verbose is True:
            print("note:{} vel:{} pos:{} damp:{} detune:{} verb:{}".format(
            note, vel, pluck_pos, damping, detune, verb))
        time.sleep(0.2)

