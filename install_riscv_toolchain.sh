#!/bin/bash
# Install dependencies
sudo apt-get update
sudo apt-get install autoconf automake autotools-dev curl python3 libmpc-dev \
    libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf \
    libtool patchutils bc zlib1g-dev libexpat-dev ninja-build -y

# Install RISC-V GNU Toolchain
git clone --recursive https://github.com/riscv/riscv-gnu-toolchain
cd riscv-gnu-toolchain
./configure --prefix=/opt/riscv --enable-multilib
make linux
sudo make install
cd ..

# Install Spike Simulator
git clone https://github.com/riscv/riscv-isa-sim.git
cd riscv-isa-sim
mkdir build
cd build
../configure --prefix=/opt/riscv
make
sudo make install
cd ../..

echo "export PATH=/opt/riscv/bin:$PATH" >> ~/.bashrc
source ~/.bashrc
