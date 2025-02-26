FROM debian:bullseye

# Update package list and install zip and bash
RUN apt-get update && \
    apt-get install -y zip bash && \
    apt-get clean

# Set default command to bash
CMD ["/bin/bash"]
