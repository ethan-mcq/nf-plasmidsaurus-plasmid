# Use a Miniconda base image
FROM mambaorg/micromamba

# Set environment variables
ENV PATH="/opt/micromamba/bin:$PATH"

# Create Conda environment and install R dependencies
RUN micromamba install -c conda-forge -c bioconda -c nanoporetech -y \
    medaka && \
    micromamba clean --all -y

# Define default command to run the container
CMD ["/bin/bash"]