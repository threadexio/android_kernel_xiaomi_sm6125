#!/usr/bin/env bash

DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# You are supposed to provide the repo of binutils at this path.
# It is available at:
#
#	https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9
#
PREBUILT_AARCH64_BINUTILS_PATH="$DIR/toolchain/aarch64-linux-android-4.9"

# You are supposed to provide the repo of clang at this path.
# It is available at:
#
#	https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86
#
PREBUILT_CLANG_PATH="$DIR/toolchain/clang-linux-x86/clang-r383902"

# You should also checkout to the correct branch. This is dependent on the version
# of the kernel you are compiling. This kernel requires clang-r383902 because it is
# old. This is also specified in the build.config.common file. So the branch we need
# is: android-11.0.0_r0.100

# It is good to also provide the latest version of Android's own build tools.
# They are available with `sdkmanager`. You can then simple symlink the lastest
# version to this path.
PREBUILT_BUILD_TOOLS_PATH="$DIR/toolchain/build-tools-latest"

NCPUS="$(nproc --all)"

__construct_new_path() {
	local tmp="$PATH"
	for p in "$@"; do
		tmp="$p:$tmp"
	done
	echo "$tmp"
}

kmake() {
	local new_path="$(__construct_new_path \
		"${PREBUILT_BUILD_TOOLS_PATH}/bin" \
		"${PREBUILT_CLANG_PATH}/bin" \
		"${PREBUILT_AARCH64_BINUTILS_PATH}/bin" \
	)"

	command env PATH="$new_path" \
		make -j "$NCPUS" \
			CC=clang \
			ARCH=arm64 \
			CLANG_TRIPLE=aarch64-linux-gnu- \
			CROSS_COMPILE=aarch64-linux-android- \
			"$@"
}

echo "\`source\`-ing this script will give you access to the \`kmake\` command."
echo "A shorthand for \`make\` that sets all the appropriate variables."
echo
echo "Quick-start:"
echo "============"
echo "Get a reference config:     kmake ginkgo-perf_defconfig"
echo "Modify your config:         kmake menuconfig"
echo "Build a compressed kernel:  kmake Image.gz-dtb"
echo
echo "For more, see: kmake help"
