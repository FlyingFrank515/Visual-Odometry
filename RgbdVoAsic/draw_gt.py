#!/usr/bin/env python
# coding=utf-8

import numpy as np
import matplotlib.pyplot as plt
import mpl_toolkits.mplot3d

#f = open("./pose.txt")
#f1 = open("./estimated_trajectory.txt")
f = open("./result/pose_fr1_xyz.txt")
f1 = open("./result/pose_fr1_xyz.txt")
x = []
y = []
z = []
x1 = []
y1 = []
z1 = []
for line in f:
    if line[0] == '#':
        continue
    data = line.split()
    if str(data[1]) != 'NaN':
       x.append( float(data[1] ) )
       y.append( float(data[2] ) )
       z.append( float(data[3] ) )
for line in f1:
    if line[0] == '#':
        continue
    data = line.split()
    if str(data[1]) != 'NaN':
       x1.append( float(data[1] ) )
       y1.append( float(data[2] ) )
       z1.append( float(data[3] ) )
ax = plt.subplot( 111, projection='3d')
#ax.plot(x,y,z)
ax.plot(x1,y1,z1)
plt.show()
