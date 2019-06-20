TMPDIR="$HOME/stratux-tmp"

# cd to script directory
cd "$(dirname "$0")"
SRCDIR="$(realpath $(pwd)/..)"
mkdir -p $TMPDIR
cd $TMPDIR

cd ../..

cd root
wget https://dl.google.com/go/go1.12.4.linux-armv6l.tar.gz
tar xzf go1.12.4.linux-armv6l.tar.gz
rm go1.12.4.linux-armv6l.tar.gz

if [ "$1" == "dev" ]; then
    cp -r $SRCDIR .
else
    git clone --recursive https://github.com/biturbo/stratux.git
fi
cd ../..

# Now download a specific kernel to run raspbian images in qemu and boot it..
bash /root/stratux/image/mk_europe_edition_device_setup_stretch.sh
