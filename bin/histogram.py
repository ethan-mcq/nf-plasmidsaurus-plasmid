import sys
import pysam
import matplotlib.pyplot as plt

def get_read_lengths(bam_file, include_unmapped=False):
    lengths_primary = []
    lengths_unmapped = []

    with pysam.AlignmentFile(bam_file, "rb") as bam:
        for read in bam:
            if read.is_unmapped:
                if include_unmapped:
                    lengths_unmapped.append(read.query_length)
            elif not read.is_secondary:  # Primary alignments (not secondary/supplementary)
                lengths_primary.append(read.query_length)

    return lengths_primary, lengths_unmapped

def plot_read_lengths(ecoli, assembly, prefix):
    bam1_primary, _ = get_read_lengths(ecoli)
    bam2_primary, bam2_unmapped = get_read_lengths(assembly, include_unmapped=True)
    
    plt.figure(figsize=(10, 6))
    plt.hist(bam1_primary, bins=100, alpha=0.5, label='Ecoli Aligned Reads)', color='blue')
    plt.hist(bam2_primary, bins=100, alpha=0.5, label='Ref Assembly Aligned Reads', color='green')
    plt.hist(bam2_unmapped, bins=100, alpha=0.5, label='Unmapped', color='orange')
    
    plt.xlabel("Read Length")
    plt.ylabel("Frequency")
    plt.legend()

    output_file = f"{prefix}.png"
    plt.savefig(output_file, dpi=300)
    plt.close()

if __name__ == "__main__":
    ecoli = sys.argv[1]
    assembly = sys.argv[2]
    prefix = sys.argv[3]
    plot_read_lengths(ecoli, assembly, prefix)
