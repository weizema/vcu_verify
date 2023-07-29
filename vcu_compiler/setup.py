'''
Author: weizema weizema@smail.nju.edu.cn
Date: 2023-07-28 16:30:59
LastEditors: weizema weizema@smail.nju.edu.cn
LastEditTime: 2023-07-28 16:38:06
FilePath: /vcu_compiler/setup.py
Description:
'''
from setuptools import setup, find_packages, Extension
import os
from pathlib import Path


this_dir = os.path.dirname(os.path.abspath(__file__))
ext_module = []
ext_module.append(
    Extension(
        name="vcu_compiler_cpp",
        sources=[
            './csrc/interface.cpp',
            './csrc/vcu_code.cpp',
            './csrc/instruction.cpp',
        ],
        extra_compile_args=
            ["-O3", "-std=c++17"],
        include_dirs=[
            Path(this_dir) / 'csrc'
        ]
    )
)


setup(name="vcu_compiler",
      version="0.1",
      packages=find_packages(exclude=("build", "csrc", "dist",
                                      "vcu_compiler.egg-info",)
                             ),
      ext_modules=ext_module
      )
