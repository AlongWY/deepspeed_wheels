# Auto Build [Deepspeed](https://github.com/microsoft/DeepSpeed) [![Build](https://github.com/AlongWY/deepspeed_wheels/actions/workflows/build.yml/badge.svg)](https://github.com/AlongWY/deepspeed_wheels/actions/workflows/build.yml)

自动构建 [Deepspeed](https://github.com/microsoft/DeepSpeed) 的不同版本

## Build Args

+ TORCH_CUDA_ARCH_LIST="6.0;6.1;7.0;7.5;8.0;8.6;8.9;9.0+PTX"
+ DS_BUILD_OPS=1
+ DS_BUILD_AIO=0
+ DS_BUILD_SPARSE_ATTN=0
+ DS_BUILD_EVOFORMER_ATTN=0

# 类似项目
+ [Apex Wheels](https://github.com/AlongWY/apex_wheels)
+ [Deepspeed Wheels](https://github.com/AlongWY/deepspeed_wheels)
+ [TransfomrtEngine Wheels](https://github.com/AlongWY/TransformerEngine_wheels)
+ [llamafactory Docker](https://github.com/AlongWY/llamafactory-docker)
