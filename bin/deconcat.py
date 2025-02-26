#!/usr/bin/env python
"""Go deconcatenate your sequences."""
import argparse
import sys
import mappy as mp


def get_output_handler(path):
    """Open file path or stdout."""
    return open(path, 'w') if path != '-' else sys.stdout


def get_aligner(reference):
    """Return a ready aligner."""
    aligner = mp.Aligner(seq=reference, preset='asm5')
    if not aligner:
        raise RuntimeError("ERROR: failed to load/build index")
    return aligner


def align_self(seq):
    """Split read and align one half to the other."""
    half = len(seq) // 2
    first, second = seq[:half], seq[half:]
    aligner = get_aligner(first)
    hits = [hit for hit in aligner.map(second)]
    return hits, first, second


def deconcatenate(seq, approx_size):
    """Self-align to remove duplicate regions."""
    iteration = 0
    trimmed_assm = seq
    approx_size = int(approx_size)
    upper_limit = approx_size * 1.2
    lower_limit = approx_size * 0.8

    while True:
        iteration += 1
        sys.stdout.write(f"Trimming sequence... Round {iteration}\n")

        hits, first, second = align_self(trimmed_assm)
        
        # Check if the sequence length is within the expected range
        if lower_limit < len(trimmed_assm) < upper_limit:
            sys.stdout.write("Approx size is as expected, stopping here.\n")
            break
        
        # Handling the different cases based on self-alignments
        if len(hits) == 1:
            sys.stdout.write("> Single self-alignment detected.\n")
        elif len(hits) > 1:
            sys.stdout.write("> Multiple self-alignments detected.\n")
            hits = [hit for hit in hits if hit.q_st < 5]
            if not hits:
                sys.stdout.write("> No self-alignments match criteria, stopping here.\n")
                break
        else:
            sys.stdout.write("> No self-alignments, stopping here.\n")
            break

        # Try to adjust sequence based on the best self-alignment hit
        try:
            hit = hits[0]
            trimmed_assm = second[:hit.q_en] + first[hit.r_en:]
        except IndexError:
            sys.stdout.write("> Error: Invalid alignment, reverting to original sequence.\n")
            trimmed_assm = seq

    return trimmed_assm


def process_sequences(sequence_fasta, approx_size, output):
    """For each sequence, deconcatenate and write to output."""
    corrected = []

    for name, seq, _ in mp.fastx_read(sequence_fasta):
        corrected.append([name, deconcatenate(seq, approx_size)])

    if corrected:
        handler = get_output_handler(output)
        for name, seq in corrected:
            handler.write(f">{name}\n{seq}\n")
        handler.close()


def argparser():
    """Argument parser for entrypoint."""
    parser = argparse.ArgumentParser(
        description="Deconcatenate sequences based on self-alignment.",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter
    )
    parser.add_argument(
        "sequence",
        help="File in .FASTA format containing sequences/contigs."
    )
    parser.add_argument(
        "--approx_size",
        type=int,
        required=True,
        help="Approximate plasmid size in base pairs."
    )
    parser.add_argument(
        "-o", "--output",
        default="-",
        help="Path at which to write the fixed sequence/contig, or use stdout."
    )
    return parser


def main():
    """Main function to parse arguments and process sequences."""
    args = argparser().parse_args()
    process_sequences(args.sequence, args.approx_size, args.output)


if __name__ == '__main__':
    main()
