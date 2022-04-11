import numpy as np
import math
pattern = [
        [3, -8, 4, 1],
        [-1, 5, 1, -5],
        [-8, -8, 8, 5],
        [-3, 1, -6, -4],
        [7, -6, 6, 0],
        [-3, 6, 7, -2],
        [0, 5, -7, 1],
        [-5, 1, 3, 2],
        [-6, 8, 4, 5],
        [6, 8, 6, 8],
        [6, -7, 0, -4],
        [5, -8, -3, 0],
        [1, -2, 7, 2],
        [4, -2, -2, 4],
        [2, -2, -2, 6],
        [-1, 3, 8, -5],
        [0, -3, 7, 2],
        [0, 1, -2, 6],
        [8, -2, -7, 1],
        [2, -7, 1, 0],
        [1, 8, -8, 8],
        [7, -7, -7, -7],
        [8, 5, -6, 4],
        [0, -2, -5, -2],
        [-3, -8, 3, -7],
        [-2, -1, 5, 6],
        [7, 5, 7, 1],
        [3, 4, 8, 5],
        [6, -4, 6, -6],
        [-2, -2, -3, 5],
        [-3, -4, -3, -7],
        [-2, -2, 2, -8],
        [-4, -4, -7, -1],
        [-3, -5, -8, 8],
        [7, 3, -4, 6],
        [0, -2, 7, -4],
        [0, -1, 4, 3],
        [2, -6, 7, -4],
        [-3, 5, -3, -7],
        [-2, 8, 7, -8],
        [-2, 4, -1, -3],
        [2, 6, 1, -5],
        [2, 6, -5, 3],
        [-8, 2, 7, -5],
        [-3, -5, -2, 3],
        [8, -4, -2, 1],
        [0, 0, 1, 0],
        [6, -1, -4, -2],
        [1, 8, -1, 0],
        [-2, 6, -3, 3],
        [1, -7, 7, -1],
        [-5, 8, 0, 4],
        [1, -3, 3, -4],
        [4, -5, -6, 6],
        [2, 4, -2, -7],
        [2, 0, 1, -3],
        [-2, -6, -3, 6],
        [-2, -8, 8, 7],
        [-8, 6, 6, 4],
        [2, -5, 3, 5],
        [-1, 4, 8, 6],
        [6, 4, -7, 2],
        [1, -4, -2, 6],
        [3, 1, 7, 3],
        [-2, 2, 6, 8],
        [6, -1, 8, -3],
        [-6, -4, 3, 8],
        [-7, 2, 1, -5],
        [6, 7, 1, 1],
        [-3, -6, 7, -3],
        [6, 7, -2, 7],
        [8, 1, 4, -5],
        [1, 1, 4, -1],
        [-4, 7, -4, 4],
        [-2, -2, -8, -3],
        [3, -2, -4, 8],
        [5, 4, 5, -1],
        [-2, 7, -5, -1],
        [-6, -1, 3, -5],
        [1, 6, -6, 3],
        [-2, -4, 6, 3],
        [-3, 5, -2, 2],
        [0, 1, -7, 5],
        [3, 8, 4, -5],
        [3, -8, 4, 5],
        [7, -8, -6, 0],
        [3, -3, -1, -7],
        [-8, -5, 5, 8],
        [-8, -4, 4, 6],
        [4, 7, 6, 6],
        [5, 8, 1, 8],
        [-6, 8, -6, -2],
        [-7, 5, 7, 5],
        [5, 6, 0, 5],
        [8, -1, 1, -3],
        [-6, 7, 4, 0],
        [-3, -1, 3, 8],
        [5, 0, 8, 0],
        [8, -8, -8, 5],
        [-6, -6, 8, 5],
        [-2, 5, 4, -1],
        [6, -8, 7, 4],
        [0, 6, 0, -6],
        [-5, 8, -2, 7],
        [8, -1, 4, 5],
        [-2, 0, -1, -3],
        [4, 4, -5, 7],
        [1, 8, -7, -5],
        [4, -6, 4, -2],
        [3, -3, 6, 4],
        [-8, 0, 8, 4],
        [2, -3, 0, 6],
        [-2, -5, -1, 4],
        [-4, -6, -8, 1],
        [6, 0, -4, -8],
        [-7, 2, 5, 3],
        [7, -5, -6, 0],
        [0, -8, -8, 0],
        [-5, -4, 0, -2],
        [3, 0, -6, 8],
        [-4, -2, 5, 3],
        [6, 8, 1, -1],
        [6, 3, -1, 0],
        [7, -7, 0, -1],
        [-6, -7, -1, 1],
        [-3, 0, -3, 5],
        [-5, 0, 0, 3],
        [8, 5, -4, -5],
        [-3, 5, -1, -6],
        [-5, -4, 5, 2],
        [6, -4, -4, -3],
        [1, 2, 2, 5],
        [3, 1, 6, -3],
        [-8, -6, -7, -1],
        [-5, 5, 2, -2],
        [-4, 3, 2, -5],
        [2, 0, -2, 5],
        [-4, -6, -7, 2],
        [3, -1, -5, -5],
        [2, 4, 6, 6],
        [8, -8, -7, -4],
        [7, 7, 1, -7],
        [3, -8, -1, 8],
        [2, 5, 4, -1],
        [-1, 1, -5, 4],
        [-3, -2, 3, 8],
        [1, -6, -8, 8],
        [3, -6, -8, -2],
        [3, 6, 2, 3],
        [4, 4, -1, 2],
        [6, 6, -8, 3],
        [5, -6, -2, -8],
        [8, -6, 5, 7],
        [0, -6, -5, -3],
        [8, 6, 7, 1],
        [8, -6, -2, 6],
        [6, -6, -5, 4],
        [7, -4, 8, 3],
        [8, 1, 5, -4],
        [-6, 0, 4, 6],
        [3, 5, 4, -3],
        [2, 7, 5, -1],
        [3, 6, 4, -4],
        [7, 2, 6, -6],
        [3, 7, 3, 3],
        [8, 1, 4, -3],
        [-2, -6, 2, 6],
        [5, 0, 3, -5],
        [0, -8, -7, 3],
        [-7, 1, -3, 5],
        [-4, 2, 0, 8],
        [-8, 3, -6, -1],
        [-6, -1, 6, 3],
        [5, -1, -4, -3],
        [-7, -7, 4, 5],
        [7, -2, 5, -2],
        [-5, 5, 1, 3],
        [-2, -5, 1, -4],
        [2, 0, -4, 8],
        [4, 3, -3, 1],
        [4, 1, 5, 6],
        [0, -7, 8, 6],
        [-7, -4, 6, 0],
        [-4, 8, -5, -2],
        [-1, 4, -2, -8],
        [0, 1, -1, -2],
        [2, 1, -1, 5],
        [-4, 6, -3, 2],
        [6, 6, 7, 3],
        [-7, -7, -6, -3],
        [-3, -2, -2, 1],
        [-7, 0, 0, -8],
        [-5, 0, -2, -8],
        [-7, -7, -3, 3],
        [6, -1, 3, 2],
        [5, -2, 2, -6],
        [3, -6, 3, 8],
        [-3, 1, 6, 3],
        [2, -7, -2, -7],
        [-4, 3, -1, -1],
        [8, 0, 5, 5],
        [-1, -7, 7, 3],
        [-7, 0, -4, -7],
        [3, 0, -2, 8],
        [6, 4, 0, -1],
        [4, -6, -5, 2],
        [-7, 8, -7, -4],
        [-4, -8, -5, -5],
        [0, 7, 6, 1],
        [6, -6, 3, 2],
        [-7, 8, 0, -7],
        [-6, -1, 3, 7],
        [4, -4, 7, 5],
        [-1, -2, 5, 1],
        [-6, 4, 8, 3],
        [7, 1, -4, 1],
        [-7, 3, 4, -6],
        [2, -2, 1, -6],
        [2, -2, -2, -5],
        [0, -8, 6, -2],
        [2, 5, -1, -2],
        [0, -7, -6, 7],
        [8, 4, -5, 4],
        [-1, -8, 6, -3],
        [8, 6, -3, 2],
        [1, -6, -6, 2],
        [-8, 2, 3, -7],
        [-3, -7, -2, -4],
        [3, 0, -4, -5],
        [-7, -8, -3, 5],
        [8, -6, 0, -6],
        [0, 8, 8, 0],
        [-6, 2, -5, -6],
        [8, 3, -5, 3],
        [5, 7, -1, -3],
        [-1, -7, -5, 6],
        [2, -3, -1, 4],
        [6, 8, -3, -6],
        [6, 7, -3, 8],
        [1, -2, -7, 6],
        [-4, -2, 6, -1],
        [6, 8, -3, -8],
        [5, -1, -7, 1],
        [-1, -1, -2, 2],
        [-8, 1, 8, 0],
        [-4, -7, 2, -4],
        [0, -2, 7, -1],
        [2, 8, 6, 7],
        [3, 8, 8, -2],
        [-7, -6, 5, 8],
        [-8, 6, 5, 1],
        [-6, 8, -3, 8],
        [1, -7, 0, -6],
        [-6, -8, 5, -1],
        [3, 1, -2, -3],
        [-3, -3, -6, 3]
        ]

array = np.array(pattern)

rad = 0

# for (int i = 0 ; i< 256; i++)  {
#             ia_x[i] = ROUND((gaussian_bit_pattern_31_x_a[i]*cos_angle - gaussian_bit_pattern_31_y_a[i]*sin_angle));
#             ia_y[i] = ROUND((gaussian_bit_pattern_31_x_a[i]*sin_angle + gaussian_bit_pattern_31_y_a[i]*cos_angle));
#             ib_x[i] = ROUND((gaussian_bit_pattern_31_x_b[i]*cos_angle - gaussian_bit_pattern_31_y_b[i]*sin_angle));
#             ib_y[i] = ROUND((gaussian_bit_pattern_31_x_b[i]*sin_angle + gaussian_bit_pattern_31_y_b[i]*cos_angle));
#         }

np.set_printoptions(threshold = np.inf)

turn = 15
rad = math.pi/8*turn
new_xa = np.int32(array[:,0]*math.cos(rad) - array[:,1]*math.sin(rad))
new_ya = np.int32(array[:,1]*math.sin(rad) + array[:,1]*math.cos(rad))
new_xb = np.int32(array[:,2]*math.cos(rad) - array[:,3]*math.sin(rad))
new_yb = np.int32(array[:,2]*math.sin(rad) + array[:,3]*math.cos(rad))
new_array = np.stack((new_xa, new_ya, new_xb, new_yb), axis = 1)

new_list = new_array.tolist()

print(new_list)
