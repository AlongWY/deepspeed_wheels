# Install libaio
echo "Install libaio 0.3.113..."
curl https://pagure.io/libaio/archive/libaio-0.3.113/libaio-libaio-0.3.113.tar.gz -o libaio-libaio-0.3.113.tar.gz
tar -zxvf libaio-libaio-0.3.113.tar.gz
cd /project/libaio-libaio-0.3.113
make prefix=/usr install
make clean
cd /project

# install oneCCL: /project/oneCCL/build/_install
echo "Install oneCCL"
cd /project/oneCCL
mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=/oneCCL -DCMAKE_BUILD_TYPE=Release
make -j 1 install
make clean
cd /project
