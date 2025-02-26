import sys
import pysam
import matplotlib.pyplot as plt
from Bio import SeqIO

def get_reference_length(fasta_file):
    """Reads the FASTA file and returns the length of the reference sequence."""
    with open(fasta_file, "r") as f:
        for record in SeqIO.parse(f, "fasta"):
            return len(record.seq)  # Assumes single-sequence FASTA
    return 0  # Default if no sequence found

def compute_coverage(bam_file, fasta_file, output_prefix):
    """Computes and plots read coverage across the reference genome from a BAM file."""
    reference_length = get_reference_length(fasta_file)
    
    # Initialize coverage dictionary with zeros up to the reference length
    coverage = {pos: 0 for pos in range(reference_length)}

    with pysam.AlignmentFile(bam_file, "rb") as bam:
        for pileupcolumn in bam.pileup():
            pos = pileupcolumn.reference_pos  # 0-based index
            if pos < reference_length:  # Ensure within valid reference length
                coverage[pos] = pileupcolumn.nsegments

    # Convert to sorted lists
    positions = sorted(coverage.keys())
    depths = [coverage[pos] for pos in positions]

    # Plot the coverage
    plt.figure(figsize=(12, 5))
    plt.plot(positions, depths, color="blue", linewidth=1)

    # Labels and title
    plt.xlabel("Genomic Position")
    plt.ylabel("Read Depth (Coverage)")
    plt.title(f"Coverage Plot for {bam_file}")

    # Save plot
    output_file = f"{output_prefix}.png"
    plt.savefig(output_file, dpi=300)
    plt.close()

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: python coverage_plot.py <bam_file> <fasta_file> <output_prefix>")
        sys.exit(1)

    bam_path = sys.argv[1]
    fasta_path = sys.argv[2]
    output_prefix = sys.argv[3]

    compute_coverage(bam_path, fasta_path, output_prefix)
