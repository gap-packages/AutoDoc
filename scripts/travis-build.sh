# If a command fails, exit this script with an error code
set -e

# Store this directory
PKGDIR=$(pwd)

# Download and compile GAP
cd ..
echo -en 'travis_fold:start:InstallGAP\r'
git clone -b $GAP_BRANCH --depth=1 https://github.com/$GAP_FORK/gap.git
cd gap
./configure --with-gmp=system $GAP_FLAGS
make
mkdir pkg
cd ..
echo -en 'travis_fold:end:InstallGAP\r'

# Compile the Digraphs package
echo -en 'travis_fold:start:InstallANATPH\r'
mv $PKGDIR gap/pkg/anatph
echo -en 'travis_fold:end:InstallANATPH\r'

cd gap

# Get the packages
echo -en 'travis_fold:start:InstallPackages\r'
cd pkg
echo -en 'travis_fold:start:$GAPDOC\r'
curl -O http://www.gap-system.org/pub/gap/gap4/tar.gz/packages/$GAPDOC.tar.gz
tar xzf $GAPDOC.tar.gz
rm $GAPDOC.tar.gz
echo -en 'travis_fold:end:$GAPDOC\r'
echo -en 'travis_fold:start:$PROFILING\r'
curl -O http://www.gap-system.org/pub/gap/gap4/tar.gz/packages/$PROFILING.tar.gz
tar xzf $PROFILING.tar.gz
rm $PROFILING.tar.gz
cd $PROFILING
./configure $PKG_FLAGS
make
cd ..
echo -en 'travis_fold:end:$PROFILING\r'
echo -en 'travis_fold:end:$IO\r'
curl -O http://www.gap-system.org/pub/gap/gap4/tar.gz/packages/$IO.tar.gz
tar xzf $IO.tar.gz
rm $IO.tar.gz
cd $IO
./configure $PKG_FLAGS
make
cd ..
echo -en 'travis_fold:end:$IO\r'
echo -en 'travis_fold:end:$ORB\r'
curl -O http://www.gap-system.org/pub/gap/gap4/tar.gz/packages/$ORB.tar.gz
tar xzf $ORB.tar.gz
rm $ORB.tar.gz
cd $ORB
./configure $PKG_FLAGS
make
cd ..
echo -en 'travis_fold:end:$ORB\r'
echo -en 'travis_fold:end:$DIGRAPHS\r'
curl -O http://www.gap-system.org/pub/gap/gap4/tar.gz/packages/$DIGRAPHS.tar.gz
tar xzf $DIGRAPHS.tar.gz
cd $DIGRAPHS
./configure $PKG_FLAGS
make
cd ../../..
echo -en 'travis_fold:end:$DIGRAPHS\r'
echo -en 'travis_fold:end:InstallPackages\r'
