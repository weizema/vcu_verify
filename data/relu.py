'''
Author: weizema
Date: 2023-07-31 19:37:44
LastEditors: weizema
LastEditTime: 2023-08-01 15:03:46
Description: 
'''
import torch
from utils import *

psum_tensor = torch.rand(32, 28, 28)
ofmap_tensor_ref = torch.relu(psum_tensor)

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
                    value = torch.relu(psum_tensor_transform[i][j][k][l])
                    if cnt % 32 == 0:
                        ofmap_line = ""
                    ofmap_line = half2hex_tensor(value) + ofmap_line
                    if cnt % 32 == 31:
                        f.write(ofmap_line + "\n")
                    cnt += 1


        
