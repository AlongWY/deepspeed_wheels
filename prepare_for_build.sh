pip install -U "setuptools<=77.0.1" wheel auditwheel-symbols
pip install lit
# We want to figure out the CUDA version to download pytorch
# e.g. we can have system CUDA version being 11.7 but if torch==1.12 then we need to download the wheel from cu116
# see https://github.com/pytorch/pytorch/blob/main/RELEASE.md#release-compatibility-matrix
# This code is ugly, maybe there's a better way to do this.
export TORCH_CUDA_VERSION=$(python -c "from os import environ as env; \
    minv = {'1.12': 113, '1.13': 116, '2.0': 117, '2.1': 118, '2.2': 118, '2.3': 118, '2.4': 118, '2.5': 118, '2.6': 118}[env['MATRIX_TORCH_VERSION']]; \
    maxv = {'1.12': 116, '1.13': 117, '2.0': 118, '2.1': 121, '2.2': 121, '2.3': 121, '2.4': 124, '2.5': 124, '2.6': 126}[env['MATRIX_TORCH_VERSION']]; \
    print(max(min(int(env['MATRIX_CUDA_VERSION']), maxv), minv))" \
)
python --version
pip --version
which python
which pip

# Install libaio
echo "Install libaio 0.3.113..."
curl https://pagure.io/libaio/archive/libaio-0.3.113/libaio-libaio-0.3.113.tar.gz -o libaio-libaio-0.3.113.tar.gz
tar -zxvf libaio-libaio-0.3.113.tar.gz
cd /project/libaio-libaio-0.3.113
make prefix=/usr install
cd /project

# install oneCCL: /project/oneCCL/build/_install
echo "Install oneCCL"
cd /project/oneCCL
mkdir build
cd build
cmake ..
make -j 1 install
cd /project

# patch "setup.py" and "deepspeed/env_report.py" to support ops of different accelerators
echo "Patch setup.py and env_report.py"
sed -i "s/'{accelerator_name}'/{{'{accelerator_name}', 'cpu'}}/g" setup.py
sed -i "s/accelerator_name == get_accelerator()._name/get_accelerator()._name in accelerator_name/g" deepspeed/env_report.py
sed -i "s/accelerator_name == get_accelerator()._name/get_accelerator()._name in accelerator_name/g" op_builder/builder.py
sed -i "s/accelerator_name == get_accelerator()._name/get_accelerator()._name in accelerator_name/g" op_builder/xpu/builder.py

# patch libaio
echo "Patch libaio"
sed -i "s/'-laio'/'-Wl,-Bstatic', '-laio', '-Wl,-Bdynamic'/g" op_builder/async_io.py
sed -i "s/'-laio'/'-Wl,-Bstatic', '-laio', '-Wl,-Bdynamic'/g" op_builder/cpu/async_io.py

# not support xpu and npu now
# sed -i "s/'-laio'/'-Wl,-Bstatic', '-laio', '-Wl,-Bdynamic'/g" op_builder/npu/async_io.py
# sed -i "s/'-laio'/'-Wl,-Bstatic', '-laio', '-Wl,-Bdynamic'/g" op_builder/xpu/async_io.py

# patch cufile use static link ?
# sed -i "s/'-lcufile'/'-Wl,-Bstatic', '-lcufile_static', '-Wl,-Bdynamic'/g" op_builder/gds.py

# patch oneCCL use static link
sed -i "s/'-lccl'/'-Wl,-Bstatic', '-lccl', '-Wl,-Bdynamic'/g" op_builder/cpu/comm.py

# patch cuda triton
cp build_scripts/cuda_accelerator.py accelerator/cuda_accelerator.py

# force compile comm ops
cp op_builder/cpu/comm.py op_builder/comm.py
sed -i 's/CPUOpBuilder/TorchCPUOpBuilder/g' op_builder/comm.py

# triton==3.0.0 to support fp_quantizer
pip install hjson ninja numpy packaging psutil py-cpuinfo pydantic pynvml tqdm libaio deepspeed-kernels "triton>=2.3.0,<=3.0.0"

echo "install torch==${CI_TORCH_VERSION}+cu${TORCH_CUDA_VERSION}"
pip install --no-cache-dir torch==${CI_TORCH_VERSION} --index-url https://download.pytorch.org/whl/cu${TORCH_CUDA_VERSION}

