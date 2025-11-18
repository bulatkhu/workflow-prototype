FROM ubuntu:22.04

# Comet dependency: only libgomp at most for some builds
RUN apt-get update && apt-get install -y libc6 libstdc++6 libgomp1 wget

# Install Comet
RUN wget https://github.com/UWPR/Comet/releases/download/v2025.03.0/comet.linux.exe -O /usr/local/bin/comet && \
    chmod +x /usr/local/bin/comet

CMD ["comet"]
