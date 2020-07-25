#!/usr/bin/env bash
sudo apt-get install build-essential dkms linux-headers-$(uname -r) android-tools-adb android-tools-fastboot bc bison ca-certificates ccache clang cmake curl file flex gcc g++ git libelf-dev libssl-dev make ninja-build python3 texinfo u-boot-tools zlib1g-dev python vim
git clone https://github.com/Genom-Project/android_kernel_xiaomi_lavender.git kernel
cd kernel
git clone --depth==1 https://github.com/kdrag0n/proton-clang.git clang
export CONFIG_PATH=$PWD/arch/arm64/configs/lavender-perf_defconfig
PATH="${PWD}/clang/bin:$PATH"
export ARCH=arm64
export KBUILD_BUILD_HOST=circleci
export KBUILD_BUILD_USER="Am271"
make O=out ARCH=arm64 lavender-per_defconfig
make -j$(nproc --all) O=out ARCH=arm64 CC=clang CROSS_COMPILE=aarch64-linux-gnu- CROSS_COMPILE_ARM32=arm-linux-gnueabi-
