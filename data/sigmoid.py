'''
Author: weizema
Date: 2023-07-31 11:16:47
LastEditors: weizema
LastEditTime: 2023-08-01 15:10:50
Description: 
'''
import torch
from utils import *
from ops import *

# 生成原始输入数据
psum_tensor = torch.rand(32, 28, 28)
# 生成软件参考输出
ofmap_tensor_ref = torch.sigmoid(psum_tensor)

# 将原始输入数据转换为npu需要的格式，即(ic_group, h, w, ic_32)
psum_tensor_transform = psum_transform(psum_tensor, dtype="fp16")
# 存文件
psum_expand_store(psum_tensor_transform, "fp16", "psum.dat")

# 将软件参考输出转换为npu需要的格式，即(ic_group, h, w, ic_32)
ofmap_tensor_ref_transform = psum_transform(ofmap_tensor_ref, dtype="fp16")
# 存文件
psum_expand_store(ofmap_tensor_ref_transform, "fp16", "ofmap_ref.dat")

# 进行软件模拟硬件计算过程
cnt = 0
with open("./ofmap.dat", "w") as f:
    for i in range(psum_tensor_transform.shape[0]):
        for j in range(psum_tensor_transform.shape[1]):
            for k in range(psum_tensor_transform.shape[2]):
                for l in range(psum_tensor_transform.shape[3]):
                    # 函数原型见ops.py
                    value = sigmoid(psum_tensor_transform[i][j][k][l])
                    if cnt % 32 == 0:
                        ofmap_line = ""
                    ofmap_line = half2hex_tensor(value) + ofmap_line
                    if cnt % 32 == 31:
                        f.write(ofmap_line + "\n")
                    cnt += 1
