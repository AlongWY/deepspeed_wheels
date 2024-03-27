# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: Apache-2.0

# DeepSpeed Team
from typing import List
from .builder import CUDAOpBuilder, installed_cuda_version
import os
import sys


class EvoformerAttnBuilder(CUDAOpBuilder):
    BUILD_VAR = "DS_BUILD_EVOFORMER_ATTN"
    NAME = "evoformer_attn"

    def __init__(self, name=None):
        name = self.NAME if name is None else name
        super().__init__(name=name)
        self.cutlass_path = os.environ.get('CUTLASS_PATH')

    def absolute_name(self):
        return f'deepspeed.ops.{self.NAME}_op'

    def extra_ldflags(self):
        if not self.is_rocm_pytorch():
            return ['-lcurand']
        else:
            return []

    def sources(self):
        src_dir = 'csrc/deepspeed4science/evoformer_attn'
        return [f'{src_dir}/attention.cpp', f'{src_dir}/attention_back.cu', f'{src_dir}/attention_cu.cu']

    def filter_ccs(self, ccs: List[str]):
        """
        Prune any compute capabilities that are not compatible with the builder. Should log
        which CCs have been pruned.
        """
        return [cc for cc in ccs if int(cc.split('.')[0]) >= 7]

    def nvcc_args(self):
        nvcc_flags = ['-O3'] + self.version_dependent_macros()
        if not self.is_rocm_pytorch():
            nvcc_flags.extend(
                ['-allow-unsupported-compiler' if sys.platform == "win32" else '', '-lineinfo',
                 '--use_fast_math'] +
                self.compute_capability_args())

        return nvcc_flags

    def is_compatible(self, verbose=True):
        try:
            import torch
        except ImportError:
            self.warning("Please install torch if trying to pre-compile kernels")
            return False
        if self.cutlass_path is None:
            self.warning("Please specify the CUTLASS repo directory as environment variable $CUTLASS_PATH")
            return False
        with open(f'{self.cutlass_path}/CHANGELOG.md', 'r') as f:
            if '3.1.0' not in f.read():
                self.warning("Please use CUTLASS version >= 3.1.0")
                return False
        cuda_okay = True
        if not self.is_rocm_pytorch() and torch.cuda.is_available():  # ignore-cuda
            sys_cuda_major, _ = installed_cuda_version()
            torch_cuda_major = int(torch.version.cuda.split('.')[0])
            if torch_cuda_major < 11 or sys_cuda_major < 11:
                self.warning("Please use CUDA 11+")
                cuda_okay = False
        return super().is_compatible(verbose) and cuda_okay

    def include_paths(self):
        includes = [f'{self.cutlass_path}/include', f'{self.cutlass_path}/tools/util/include']
        return includes
