from pythonosc import osc_message_builder
from pythonosc import udp_client
import argparse
import time
import sys
import random

# music stuff
KICK = 0
SNARE = 1
CLICK = 2
HH = 3
drum_types = ["kick", "snare", "click", "hh"]

measure_length = 8
sequences = [
        [1,0,0,0,1,0,0,0],
        [0,1,0,0,0,1,0,0],
        [1,0,1,0,0,1,0,1],
        [1,1,1,0,0,1,0,1]]
samples = [[1,0,2,0,2,0,2,1],[2,2,0,1,0,1,0,0],[2,2,1,2,2,1,0,1],[0,0,1,2,0,0,0,3]]
beat_durations = [0.1, 0.1, 0.2, 0.1, 0.2, 0.1, 0.1, 0.2]
drum_sequence_map = [0, 1, 2, 3]

def parseCommandLineArgs():
    parser = argparse.ArgumentParser()
    parser.add_argument("-v", "--verbose",
                        action="store_true", help="will enable print statements")
    return parser.parse_args()

def playRandomBeat():
    current_beat = 0
    # this function will play a random beat which follows the beat_durations note lengths
    while True:

        current_beat = (current_beat + 1) % measure_length

        # kick
        if random.random() < 0.3:
            if args.verbose is True:
                sys.stdout.write("k")
                sys.stdout.flush()
            client.send_message("/play", "kick")
        # snare
        if random.random() < 0.2:
            if args.verbose is True:
                sys.stdout.write("s")
                sys.stdout.flush()
            client.send_message("/play", "snare")
        # click
        if random.random() < 0.5:
            if args.verbose is True:
                sys.stdout.write("c")
                sys.stdout.flush()
            client.send_message("/play", "click")
        # hat
        if random.random() < 0.7:
            if args.verbose is True:
                sys.stdout.write("h")
                sys.stdout.flush()
            client.send_message("/play", "hh")

        # randomly change the samples
        if random.random() < 0.1:
            index = random.randint(0, 2)
            dt = random.randint(0, 3)
            client.send_message("/load", [drum_types[dt], index])

        if current_beat == measure_length - 1:
            if args.verbose is True:
                sys.stdout.write("\n")
                sys.stdout.flush()
        else:
            if args.verbose is True:
                sys.stdout.write("\t")
                sys.stdout.flush()
        time.sleep(beat_durations[current_beat])

def playEachDrumHadSequence():
    current_beat = 0
    while True:

        current_beat = (current_beat + 1) % measure_length

        # kick
        if sequences[KICK][current_beat] == 1:
            if args.verbose is True:
                sys.stdout.write("k")
                sys.stdout.flush()
            client.send_message("/play", "kick")
        # snare
        if sequences[SNARE][current_beat] == 1:
            if args.verbose is True:
                sys.stdout.write("s")
                sys.stdout.flush()
            client.send_message("/play", "snare")
        # click
        if sequences[CLICK][current_beat] == 1:
            if args.verbose is True:
                sys.stdout.write("c")
                sys.stdout.flush()
            client.send_message("/play", "click")
        # hat
        if sequences[HH][current_beat] == 1:
            if args.verbose is True:
                sys.stdout.write("h")
                sys.stdout.flush()
            client.send_message("/play", "hh")

        # randomly change the samples
        if random.random() < 0.1:
            index = random.randint(0, 2)
            dt = random.randint(0, 3)
            client.send_message("/load", [drum_types[dt], index])

        if args.verbose is True:
            if current_beat  == measure_length - 1:
                sys.stdout.write("\n")
                sys.stdout.flush()
            else:
                sys.stdout.write("\t")
                sys.stdout.flush()
        time.sleep(beat_durations[current_beat])

def playWithSampleMap():
    current_beat = 0
    while True:
        # kick
        if sequences[drum_sequence_map[KICK]][current_beat] == 1:
            if args.verbose is True:
                sys.stdout.write("k")
                sys.stdout.flush()
            client.send_message("/load", [KICK, samples[KICK][current_beat]])
            client.send_message("/play", "kick")
        # snare
        if sequences[drum_sequence_map[SNARE]][current_beat] == 1:
            if args.verbose is True:
                sys.stdout.write("s")
                sys.stdout.flush()
            client.send_message("/load", [SNARE, samples[SNARE][current_beat]])
            client.send_message("/play", "snare")
        # click
        if sequences[drum_sequence_map[CLICK]][current_beat] == 1:
            if args.verbose is True:
                sys.stdout.write("c")
                sys.stdout.flush()
            client.send_message("/load", [CLICK, samples[CLICK][current_beat]])
            client.send_message("/play", "click")
        # hat
        if sequences[drum_sequence_map[HH]][current_beat] == 1:
            if args.verbose is True:
                sys.stdout.write("h")
                sys.stdout.flush()
            client.send_message("/load", [HH, samples[HH][current_beat]])
            client.send_message("/play", "hh")

        if random.random() < 0.05:
            _r1 = random.randint(0,3)
            _r2 = random.randint(0,3)
            drum_sequence_map[_r1] = _r2

        if args.verbose is True:
            if current_beat  == measure_length - 1:
                sys.stdout.write("\n")
                sys.stdout.flush()
            else:
                sys.stdout.write("\t")
                sys.stdout.flush()

        current_beat = (current_beat + 1) % measure_length

        time.sleep(beat_durations[current_beat])

def playWithDrumSequenceMap():
    current_beat = 0
    speed = 2.0
    while True:

        # kick
        if sequences[drum_sequence_map[KICK]][current_beat] == 1:
            if args.verbose is True:
                sys.stdout.write("k")
                sys.stdout.flush()
            client.send_message("/play", "kick")
        # snare
        if sequences[drum_sequence_map[SNARE]][current_beat] == 1:
            if args.verbose is True:
                sys.stdout.write("s")
                sys.stdout.flush()
            client.send_message("/play", "snare")
        # click
        if sequences[drum_sequence_map[CLICK]][current_beat] == 1:
            if args.verbose is True:
                sys.stdout.write("c")
                sys.stdout.flush()
            client.send_message("/play", "click")
        # hat
        if sequences[drum_sequence_map[HH]][current_beat] == 1:
            if args.verbose is True:
                sys.stdout.write("h")
                sys.stdout.flush()
            client.send_message("/play", "hh")

        # randomly change the samples
        if random.random() < 0.1:
            index = random.randint(0, 2)
            dt = random.randint(0, 3)
            client.send_message("/load", [drum_types[dt], index])

        if random.random() < 0.05:
            _r1 = random.randint(0,3)
            _r2 = random.randint(0,3)
            drum_sequence_map[_r1] = _r2

        if args.verbose is True:
            if current_beat  == measure_length - 1:
                sys.stdout.write("\n")
                sys.stdout.flush()
            else:
                sys.stdout.write("\t")
                sys.stdout.flush()

        # this example slowly increases the speed by 0.1% each run through the loop
        speed = speed * .999
        current_beat = (current_beat + 1) % measure_length

        time.sleep(beat_durations[current_beat] * speed)

if __name__ == "__main__":
    ip = "127.0.0.1"
    port = 6449

    client = udp_client.SimpleUDPClient(ip, port)

    args = parseCommandLineArgs()

    # demos and such
    choice = random.randint(0,3)
    if choice == 0:
        print("playing playWithSampleMap")
        playWithSampleMap()
    elif choice == 1:
        print("playing playWithDrumSequenceMap")
        playWithDrumSequenceMap()
    elif choice == 2:
        print("playing playRandomBeat")
        playRandomBeat()
    elif choice == 3:
        print("playing playEachDrumHadSequence")
        playEachDrumHadSequence()

