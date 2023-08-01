'''
Author: weizema
Date: 2023-08-01 15:03:19
LastEditors: weizema
LastEditTime: 2023-08-01 15:15:38
Description: 
'''
import torch
from utils import *
from ops import *

psum_tensor = torch.rand(32, 28, 28)
activation = torch.nn.GELU()
ofmap_tensor_ref = activation(psum_tensor)

psum_tensor_transform = psum_transform(psum_tensor, dtype="fp16")
psum_expand_store(psum_tensor_transform, "fp16", "psum.dat")

ofmap_tensor_ref_transform = psum_transform(ofmap_tensor_ref, dtype="fp16")
psum_expand_store(ofmap_tensor_ref_transform, "fp16", "ofmap_ref.dat")

cnt = 0
with open("./ofmap.dat", "w") as f:
    for i in range(psum_tensor_transform.shape[0]):
        for j in range(psum_tensor_transform.shape[1]):
            for k in range(psum_tensor_transform.shape[2]):
                for l in range(psum_tensor_transform.shape[3]):
                    value = gelu(psum_tensor_transform[i][j][k][l])
                    if cnt % 32 == 0:
                        ofmap_line = ""
                    ofmap_line = half2hex_tensor(value) + ofmap_line
                    if cnt % 32 == 31:
                        f.write(ofmap_line + "\n")
                    cnt += 1

with open("./para.dat", "w") as f:
    for i in range(64):
        if cnt % 64 == 0:
            para_line = ""
        para_line = half2hex_tensor(0.5) + para_line
        if cnt % 64 == 63:
            f.write(para_line + "\n")
        cnt += 1