pip install setuptools==68.0.0 wheel auditwheel-symbols
pip install lit
# We want to figure out the CUDA version to download pytorch
# e.g. we can have system CUDA version being 11.7 but if torch==1.12 then we need to download the wheel from cu116
# see https://github.com/pytorch/pytorch/blob/main/RELEASE.md#release-compatibility-matrix
# This code is ugly, maybe there's a better way to do this.
export TORCH_CUDA_VERSION=$(python -c "from os import environ as env; \
    minv = {'1.12': 113, '1.13': 116, '2.0': 117, '2.1': 118, '2.2': 118, '2.3': 118, '2.4': 118}[env['MATRIX_TORCH_VERSION']]; \
    maxv = {'1.12': 116, '1.13': 117, '2.0': 118, '2.1': 121, '2.2': 121, '2.3': 121, '2.4': 124}[env['MATRIX_TORCH_VERSION']]; \
    print(max(min(int(env['MATRIX_CUDA_VERSION']), maxv), minv))" \
)
python --version
pip --version
which python
which pip

# Check if /etc/os-release exists
if [ -f /etc/os-release ]; then
    # Source the os-release file
    . /etc/os-release

    # Check if PLATFORM_ID is set and matches "platform:el7" or earlier versions
    if [[ $PLATFORM_ID == "platform:el7" || $PLATFORM_ID < "platform:el7" ]]; then
        echo "Match found. Install libaio 0.3.112..."
        curl https://pagure.io/libaio/archive/libaio-0.3.112/libaio-libaio-0.3.113.tar.gz -o libaio-libaio-0.3.113.tar.gz
        tar -zxvf libaio-libaio-0.3.113.tar.gz
        cd /project/libaio-libaio-0.3.113
        make prefix=/usr install
        cd /project
    fi
fi

pip install hjson ninja numpy packaging psutil py-cpuinfo pydantic pynvml tqdm libaio deepspeed-kernels triton

echo "install torch==${CI_TORCH_VERSION}+cu${TORCH_CUDA_VERSION}"
pip install --no-cache-dir torch==${CI_TORCH_VERSION} --index-url https://download.pytorch.org/whl/cu${TORCH_CUDA_VERSION}

