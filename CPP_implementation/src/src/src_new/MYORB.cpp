#include "MYORB.h"
#include <opencv2/opencv.hpp>
#include <iostream>

using namespace cv;
using namespace std;

inline int smoothedSum(Mat& sum, KeyPoint& pt, int y, int x){
    int HALF_KERNEL = 4;
    int img_y = pt.pt.y + y;
    int img_x = pt.pt.x + x;
    return sum.at<int>(img_y + HALF_KERNEL + 1, img_x + HALF_KERNEL + 1)
            - sum.at<int>(img_y + HALF_KERNEL + 1, img_x - HALF_KERNEL)
            - sum.at<int>(img_y - HALF_KERNEL, img_x + HALF_KERNEL + 1)
            + sum.at<int>(img_y - HALF_KERNEL, img_x - HALF_KERNEL);
}

void MYORB::BRIEF_descriptor_old(){
    Mat sum_1, sum_2;
    integral(img_1, sum_1, CV_32S);
    integral(img_2, sum_2, CV_32S);
    for(int i =0 ; i < keylist_1.size(); i++){
        KeyPoint pt = keylist_1[i];
        uchar desc[32];
        #define SMOOTHED(y,x) smoothedSum(sum_1, pt, y, x)
            desc[0] = (uchar)(((SMOOTHED(-2, -1) < SMOOTHED(7, -1)) << 7) + ((SMOOTHED(-14, -1) < SMOOTHED(-3, 3)) << 6) + ((SMOOTHED(1, -2) < SMOOTHED(11, 2)) << 5) + ((SMOOTHED(1, 6) < SMOOTHED(-10, -7)) << 4) + ((SMOOTHED(13, 2) < SMOOTHED(-1, 0)) << 3) + ((SMOOTHED(-14, 5) < SMOOTHED(5, -3)) << 2) + ((SMOOTHED(-2, 8) < SMOOTHED(2, 4)) << 1) + ((SMOOTHED(-11, 8) < SMOOTHED(-15, 5)) << 0));
            desc[1] = (uchar)(((SMOOTHED(-6, -23) < SMOOTHED(8, -9)) << 7) + ((SMOOTHED(-12, 6) < SMOOTHED(-10, 8)) << 6) + ((SMOOTHED(-3, -1) < SMOOTHED(8, 1)) << 5) + ((SMOOTHED(3, 6) < SMOOTHED(5, 6)) << 4) + ((SMOOTHED(-7, -6) < SMOOTHED(5, -5)) << 3) + ((SMOOTHED(22, -2) < SMOOTHED(-11, -8)) << 2) + ((SMOOTHED(14, 7) < SMOOTHED(8, 5)) << 1) + ((SMOOTHED(-1, 14) < SMOOTHED(-5, -14)) << 0));
            desc[2] = (uchar)(((SMOOTHED(-14, 9) < SMOOTHED(2, 0)) << 7) + ((SMOOTHED(7, -3) < SMOOTHED(22, 6)) << 6) + ((SMOOTHED(-6, 6) < SMOOTHED(-8, -5)) << 5) + ((SMOOTHED(-5, 9) < SMOOTHED(7, -1)) << 4) + ((SMOOTHED(-3, -7) < SMOOTHED(-10, -18)) << 3) + ((SMOOTHED(4, -5) < SMOOTHED(0, 11)) << 2) + ((SMOOTHED(2, 3) < SMOOTHED(9, 10)) << 1) + ((SMOOTHED(-10, 3) < SMOOTHED(4, 9)) << 0));
            desc[3] = (uchar)(((SMOOTHED(0, 12) < SMOOTHED(-3, 19)) << 7) + ((SMOOTHED(1, 15) < SMOOTHED(-11, -5)) << 6) + ((SMOOTHED(14, -1) < SMOOTHED(7, 8)) << 5) + ((SMOOTHED(7, -23) < SMOOTHED(-5, 5)) << 4) + ((SMOOTHED(0, -6) < SMOOTHED(-10, 17)) << 3) + ((SMOOTHED(13, -4) < SMOOTHED(-3, -4)) << 2) + ((SMOOTHED(-12, 1) < SMOOTHED(-12, 2)) << 1) + ((SMOOTHED(0, 8) < SMOOTHED(3, 22)) << 0));
            desc[4] = (uchar)(((SMOOTHED(-13, 13) < SMOOTHED(3, -1)) << 7) + ((SMOOTHED(-16, 17) < SMOOTHED(6, 10)) << 6) + ((SMOOTHED(7, 15) < SMOOTHED(-5, 0)) << 5) + ((SMOOTHED(2, -12) < SMOOTHED(19, -2)) << 4) + ((SMOOTHED(3, -6) < SMOOTHED(-4, -15)) << 3) + ((SMOOTHED(8, 3) < SMOOTHED(0, 14)) << 2) + ((SMOOTHED(4, -11) < SMOOTHED(5, 5)) << 1) + ((SMOOTHED(11, -7) < SMOOTHED(7, 1)) << 0));
            desc[5] = (uchar)(((SMOOTHED(6, 12) < SMOOTHED(21, 3)) << 7) + ((SMOOTHED(-3, 2) < SMOOTHED(14, 1)) << 6) + ((SMOOTHED(5, 1) < SMOOTHED(-5, 11)) << 5) + ((SMOOTHED(3, -17) < SMOOTHED(-6, 2)) << 4) + ((SMOOTHED(6, 8) < SMOOTHED(5, -10)) << 3) + ((SMOOTHED(-14, -2) < SMOOTHED(0, 4)) << 2) + ((SMOOTHED(5, -7) < SMOOTHED(-6, 5)) << 1) + ((SMOOTHED(10, 4) < SMOOTHED(4, -7)) << 0));
            desc[6] = (uchar)(((SMOOTHED(22, 0) < SMOOTHED(7, -18)) << 7) + ((SMOOTHED(-1, -3) < SMOOTHED(0, 18)) << 6) + ((SMOOTHED(-4, 22) < SMOOTHED(-5, 3)) << 5) + ((SMOOTHED(1, -7) < SMOOTHED(2, -3)) << 4) + ((SMOOTHED(19, -20) < SMOOTHED(17, -2)) << 3) + ((SMOOTHED(3, -10) < SMOOTHED(-8, 24)) << 2) + ((SMOOTHED(-5, -14) < SMOOTHED(7, 5)) << 1) + ((SMOOTHED(-2, 12) < SMOOTHED(-4, -15)) << 0));
            desc[7] = (uchar)(((SMOOTHED(4, 12) < SMOOTHED(0, -19)) << 7) + ((SMOOTHED(20, 13) < SMOOTHED(3, 5)) << 6) + ((SMOOTHED(-8, -12) < SMOOTHED(5, 0)) << 5) + ((SMOOTHED(-5, 6) < SMOOTHED(-7, -11)) << 4) + ((SMOOTHED(6, -11) < SMOOTHED(-3, -22)) << 3) + ((SMOOTHED(15, 4) < SMOOTHED(10, 1)) << 2) + ((SMOOTHED(-7, -4) < SMOOTHED(15, -6)) << 1) + ((SMOOTHED(5, 10) < SMOOTHED(0, 24)) << 0));
            desc[8] = (uchar)(((SMOOTHED(3, 6) < SMOOTHED(22, -2)) << 7) + ((SMOOTHED(-13, 14) < SMOOTHED(4, -4)) << 6) + ((SMOOTHED(-13, 8) < SMOOTHED(-18, -22)) << 5) + ((SMOOTHED(-1, -1) < SMOOTHED(-7, 3)) << 4) + ((SMOOTHED(-19, -12) < SMOOTHED(4, 3)) << 3) + ((SMOOTHED(8, 10) < SMOOTHED(13, -2)) << 2) + ((SMOOTHED(-6, -1) < SMOOTHED(-6, -5)) << 1) + ((SMOOTHED(2, -21) < SMOOTHED(-3, 2)) << 0));
            desc[9] = (uchar)(((SMOOTHED(4, -7) < SMOOTHED(0, 16)) << 7) + ((SMOOTHED(-6, -5) < SMOOTHED(-12, -1)) << 6) + ((SMOOTHED(1, -1) < SMOOTHED(9, 18)) << 5) + ((SMOOTHED(-7, 10) < SMOOTHED(-11, 6)) << 4) + ((SMOOTHED(4, 3) < SMOOTHED(19, -7)) << 3) + ((SMOOTHED(-18, 5) < SMOOTHED(-4, 5)) << 2) + ((SMOOTHED(4, 0) < SMOOTHED(-20, 4)) << 1) + ((SMOOTHED(7, -11) < SMOOTHED(18, 12)) << 0));
            desc[10] = (uchar)(((SMOOTHED(-20, 17) < SMOOTHED(-18, 7)) << 7) + ((SMOOTHED(2, 15) < SMOOTHED(19, -11)) << 6) + ((SMOOTHED(-18, 6) < SMOOTHED(-7, 3)) << 5) + ((SMOOTHED(-4, 1) < SMOOTHED(-14, 13)) << 4) + ((SMOOTHED(17, 3) < SMOOTHED(2, -8)) << 3) + ((SMOOTHED(-7, 2) < SMOOTHED(1, 6)) << 2) + ((SMOOTHED(17, -9) < SMOOTHED(-2, 8)) << 1) + ((SMOOTHED(-8, -6) < SMOOTHED(-1, 12)) << 0));
            desc[11] = (uchar)(((SMOOTHED(-2, 4) < SMOOTHED(-1, 6)) << 7) + ((SMOOTHED(-2, 7) < SMOOTHED(6, 8)) << 6) + ((SMOOTHED(-8, -1) < SMOOTHED(-7, -9)) << 5) + ((SMOOTHED(8, -9) < SMOOTHED(15, 0)) << 4) + ((SMOOTHED(0, 22) < SMOOTHED(-4, -15)) << 3) + ((SMOOTHED(-14, -1) < SMOOTHED(3, -2)) << 2) + ((SMOOTHED(-7, -4) < SMOOTHED(17, -7)) << 1) + ((SMOOTHED(-8, -2) < SMOOTHED(9, -4)) << 0));
            desc[12] = (uchar)(((SMOOTHED(5, -7) < SMOOTHED(7, 7)) << 7) + ((SMOOTHED(-5, 13) < SMOOTHED(-8, 11)) << 6) + ((SMOOTHED(11, -4) < SMOOTHED(0, 8)) << 5) + ((SMOOTHED(5, -11) < SMOOTHED(-9, -6)) << 4) + ((SMOOTHED(2, -6) < SMOOTHED(3, -20)) << 3) + ((SMOOTHED(-6, 2) < SMOOTHED(6, 10)) << 2) + ((SMOOTHED(-6, -6) < SMOOTHED(-15, 7)) << 1) + ((SMOOTHED(-6, -3) < SMOOTHED(2, 1)) << 0));
            desc[13] = (uchar)(((SMOOTHED(11, 0) < SMOOTHED(-3, 2)) << 7) + ((SMOOTHED(7, -12) < SMOOTHED(14, 5)) << 6) + ((SMOOTHED(0, -7) < SMOOTHED(-1, -1)) << 5) + ((SMOOTHED(-16, 0) < SMOOTHED(6, 8)) << 4) + ((SMOOTHED(22, 11) < SMOOTHED(0, -3)) << 3) + ((SMOOTHED(19, 0) < SMOOTHED(5, -17)) << 2) + ((SMOOTHED(-23, -14) < SMOOTHED(-13, -19)) << 1) + ((SMOOTHED(-8, 10) < SMOOTHED(-11, -2)) << 0));
            desc[14] = (uchar)(((SMOOTHED(-11, 6) < SMOOTHED(-10, 13)) << 7) + ((SMOOTHED(1, -7) < SMOOTHED(14, 0)) << 6) + ((SMOOTHED(-12, 1) < SMOOTHED(-5, -5)) << 5) + ((SMOOTHED(4, 7) < SMOOTHED(8, -1)) << 4) + ((SMOOTHED(-1, -5) < SMOOTHED(15, 2)) << 3) + ((SMOOTHED(-3, -1) < SMOOTHED(7, -10)) << 2) + ((SMOOTHED(3, -6) < SMOOTHED(10, -18)) << 1) + ((SMOOTHED(-7, -13) < SMOOTHED(-13, 10)) << 0));
            desc[15] = (uchar)(((SMOOTHED(1, -1) < SMOOTHED(13, -10)) << 7) + ((SMOOTHED(-19, 14) < SMOOTHED(8, -14)) << 6) + ((SMOOTHED(-4, -13) < SMOOTHED(7, 1)) << 5) + ((SMOOTHED(1, -2) < SMOOTHED(12, -7)) << 4) + ((SMOOTHED(3, -5) < SMOOTHED(1, -5)) << 3) + ((SMOOTHED(-2, -2) < SMOOTHED(8, -10)) << 2) + ((SMOOTHED(2, 14) < SMOOTHED(8, 7)) << 1) + ((SMOOTHED(3, 9) < SMOOTHED(8, 2)) << 0));
            desc[16] = (uchar)(((SMOOTHED(-9, 1) < SMOOTHED(-18, 0)) << 7) + ((SMOOTHED(4, 0) < SMOOTHED(1, 12)) << 6) + ((SMOOTHED(0, 9) < SMOOTHED(-14, -10)) << 5) + ((SMOOTHED(-13, -9) < SMOOTHED(-2, 6)) << 4) + ((SMOOTHED(1, 5) < SMOOTHED(10, 10)) << 3) + ((SMOOTHED(-3, -6) < SMOOTHED(-16, -5)) << 2) + ((SMOOTHED(11, 6) < SMOOTHED(-5, 0)) << 1) + ((SMOOTHED(-23, 10) < SMOOTHED(1, 2)) << 0));
            desc[17] = (uchar)(((SMOOTHED(13, -5) < SMOOTHED(-3, 9)) << 7) + ((SMOOTHED(-4, -1) < SMOOTHED(-13, -5)) << 6) + ((SMOOTHED(10, 13) < SMOOTHED(-11, 8)) << 5) + ((SMOOTHED(19, 20) < SMOOTHED(-9, 2)) << 4) + ((SMOOTHED(4, -8) < SMOOTHED(0, -9)) << 3) + ((SMOOTHED(-14, 10) < SMOOTHED(15, 19)) << 2) + ((SMOOTHED(-14, -12) < SMOOTHED(-10, -3)) << 1) + ((SMOOTHED(-23, -3) < SMOOTHED(17, -2)) << 0));
            desc[18] = (uchar)(((SMOOTHED(-3, -11) < SMOOTHED(6, -14)) << 7) + ((SMOOTHED(19, -2) < SMOOTHED(-4, 2)) << 6) + ((SMOOTHED(-5, 5) < SMOOTHED(3, -13)) << 5) + ((SMOOTHED(2, -2) < SMOOTHED(-5, 4)) << 4) + ((SMOOTHED(17, 4) < SMOOTHED(17, -11)) << 3) + ((SMOOTHED(-7, -2) < SMOOTHED(1, 23)) << 2) + ((SMOOTHED(8, 13) < SMOOTHED(1, -16)) << 1) + ((SMOOTHED(-13, -5) < SMOOTHED(1, -17)) << 0));
            desc[19] = (uchar)(((SMOOTHED(4, 6) < SMOOTHED(-8, -3)) << 7) + ((SMOOTHED(-5, -9) < SMOOTHED(-2, -10)) << 6) + ((SMOOTHED(-9, 0) < SMOOTHED(-7, -2)) << 5) + ((SMOOTHED(5, 0) < SMOOTHED(5, 2)) << 4) + ((SMOOTHED(-4, -16) < SMOOTHED(6, 3)) << 3) + ((SMOOTHED(2, -15) < SMOOTHED(-2, 12)) << 2) + ((SMOOTHED(4, -1) < SMOOTHED(6, 2)) << 1) + ((SMOOTHED(1, 1) < SMOOTHED(-2, -8)) << 0));
            desc[20] = (uchar)(((SMOOTHED(-2, 12) < SMOOTHED(-5, -2)) << 7) + ((SMOOTHED(-8, 8) < SMOOTHED(-9, 9)) << 6) + ((SMOOTHED(2, -10) < SMOOTHED(3, 1)) << 5) + ((SMOOTHED(-4, 10) < SMOOTHED(-9, 4)) << 4) + ((SMOOTHED(6, 12) < SMOOTHED(2, 5)) << 3) + ((SMOOTHED(-3, -8) < SMOOTHED(0, 5)) << 2) + ((SMOOTHED(-13, 1) < SMOOTHED(-7, 2)) << 1) + ((SMOOTHED(-1, -10) < SMOOTHED(7, -18)) << 0));
            desc[21] = (uchar)(((SMOOTHED(-1, 8) < SMOOTHED(-9, -10)) << 7) + ((SMOOTHED(-23, -1) < SMOOTHED(6, 2)) << 6) + ((SMOOTHED(-5, -3) < SMOOTHED(3, 2)) << 5) + ((SMOOTHED(0, 11) < SMOOTHED(-4, -7)) << 4) + ((SMOOTHED(15, 2) < SMOOTHED(-10, -3)) << 3) + ((SMOOTHED(-20, -8) < SMOOTHED(-13, 3)) << 2) + ((SMOOTHED(-19, -12) < SMOOTHED(5, -11)) << 1) + ((SMOOTHED(-17, -13) < SMOOTHED(-3, 2)) << 0));
            desc[22] = (uchar)(((SMOOTHED(7, 4) < SMOOTHED(-12, 0)) << 7) + ((SMOOTHED(5, -1) < SMOOTHED(-14, -6)) << 6) + ((SMOOTHED(-4, 11) < SMOOTHED(0, -4)) << 5) + ((SMOOTHED(3, 10) < SMOOTHED(7, -3)) << 4) + ((SMOOTHED(13, 21) < SMOOTHED(-11, 6)) << 3) + ((SMOOTHED(-12, 24) < SMOOTHED(-7, -4)) << 2) + ((SMOOTHED(4, 16) < SMOOTHED(3, -14)) << 1) + ((SMOOTHED(-3, 5) < SMOOTHED(-7, -12)) << 0));
            desc[23] = (uchar)(((SMOOTHED(0, -4) < SMOOTHED(7, -5)) << 7) + ((SMOOTHED(-17, -9) < SMOOTHED(13, -7)) << 6) + ((SMOOTHED(22, -6) < SMOOTHED(-11, 5)) << 5) + ((SMOOTHED(2, -8) < SMOOTHED(23, -11)) << 4) + ((SMOOTHED(7, -10) < SMOOTHED(-1, 14)) << 3) + ((SMOOTHED(-3, -10) < SMOOTHED(8, 3)) << 2) + ((SMOOTHED(-13, 1) < SMOOTHED(-6, 0)) << 1) + ((SMOOTHED(-7, -21) < SMOOTHED(6, -14)) << 0));
            desc[24] = (uchar)(((SMOOTHED(18, 19) < SMOOTHED(-4, -6)) << 7) + ((SMOOTHED(10, 7) < SMOOTHED(-1, -4)) << 6) + ((SMOOTHED(-1, 21) < SMOOTHED(1, -5)) << 5) + ((SMOOTHED(-10, 6) < SMOOTHED(-11, -2)) << 4) + ((SMOOTHED(18, -3) < SMOOTHED(-1, 7)) << 3) + ((SMOOTHED(-3, -9) < SMOOTHED(-5, 10)) << 2) + ((SMOOTHED(-13, 14) < SMOOTHED(17, -3)) << 1) + ((SMOOTHED(11, -19) < SMOOTHED(-1, -18)) << 0));
            desc[25] = (uchar)(((SMOOTHED(8, -2) < SMOOTHED(-18, -23)) << 7) + ((SMOOTHED(0, -5) < SMOOTHED(-2, -9)) << 6) + ((SMOOTHED(-4, -11) < SMOOTHED(2, -8)) << 5) + ((SMOOTHED(14, 6) < SMOOTHED(-3, -6)) << 4) + ((SMOOTHED(-3, 0) < SMOOTHED(-15, 0)) << 3) + ((SMOOTHED(-9, 4) < SMOOTHED(-15, -9)) << 2) + ((SMOOTHED(-1, 11) < SMOOTHED(3, 11)) << 1) + ((SMOOTHED(-10, -16) < SMOOTHED(-7, 7)) << 0));
            desc[26] = (uchar)(((SMOOTHED(-2, -10) < SMOOTHED(-10, -2)) << 7) + ((SMOOTHED(-5, -3) < SMOOTHED(5, -23)) << 6) + ((SMOOTHED(13, -8) < SMOOTHED(-15, -11)) << 5) + ((SMOOTHED(-15, 11) < SMOOTHED(6, -6)) << 4) + ((SMOOTHED(-16, -3) < SMOOTHED(-2, 2)) << 3) + ((SMOOTHED(6, 12) < SMOOTHED(-16, 24)) << 2) + ((SMOOTHED(-10, 0) < SMOOTHED(8, 11)) << 1) + ((SMOOTHED(-7, 7) < SMOOTHED(-19, -7)) << 0));
            desc[27] = (uchar)(((SMOOTHED(5, 16) < SMOOTHED(9, -3)) << 7) + ((SMOOTHED(9, 7) < SMOOTHED(-7, -16)) << 6) + ((SMOOTHED(3, 2) < SMOOTHED(-10, 9)) << 5) + ((SMOOTHED(21, 1) < SMOOTHED(8, 7)) << 4) + ((SMOOTHED(7, 0) < SMOOTHED(1, 17)) << 3) + ((SMOOTHED(-8, 12) < SMOOTHED(9, 6)) << 2) + ((SMOOTHED(11, -7) < SMOOTHED(-8, -6)) << 1) + ((SMOOTHED(19, 0) < SMOOTHED(9, 3)) << 0));
            desc[28] = (uchar)(((SMOOTHED(1, -7) < SMOOTHED(-5, -11)) << 7) + ((SMOOTHED(0, 8) < SMOOTHED(-2, 14)) << 6) + ((SMOOTHED(12, -2) < SMOOTHED(-15, -6)) << 5) + ((SMOOTHED(4, 12) < SMOOTHED(0, -21)) << 4) + ((SMOOTHED(17, -4) < SMOOTHED(-6, -7)) << 3) + ((SMOOTHED(-10, -9) < SMOOTHED(-14, -7)) << 2) + ((SMOOTHED(-15, -10) < SMOOTHED(-15, -14)) << 1) + ((SMOOTHED(-7, -5) < SMOOTHED(5, -12)) << 0));
            desc[29] = (uchar)(((SMOOTHED(-4, 0) < SMOOTHED(15, -4)) << 7) + ((SMOOTHED(5, 2) < SMOOTHED(-6, -23)) << 6) + ((SMOOTHED(-4, -21) < SMOOTHED(-6, 4)) << 5) + ((SMOOTHED(-10, 5) < SMOOTHED(-15, 6)) << 4) + ((SMOOTHED(4, -3) < SMOOTHED(-1, 5)) << 3) + ((SMOOTHED(-4, 19) < SMOOTHED(-23, -4)) << 2) + ((SMOOTHED(-4, 17) < SMOOTHED(13, -11)) << 1) + ((SMOOTHED(1, 12) < SMOOTHED(4, -14)) << 0));
            desc[30] = (uchar)(((SMOOTHED(-11, -6) < SMOOTHED(-20, 10)) << 7) + ((SMOOTHED(4, 5) < SMOOTHED(3, 20)) << 6) + ((SMOOTHED(-8, -20) < SMOOTHED(3, 1)) << 5) + ((SMOOTHED(-19, 9) < SMOOTHED(9, -3)) << 4) + ((SMOOTHED(18, 15) < SMOOTHED(11, -4)) << 3) + ((SMOOTHED(12, 16) < SMOOTHED(8, 7)) << 2) + ((SMOOTHED(-14, -8) < SMOOTHED(-3, 9)) << 1) + ((SMOOTHED(-6, 0) < SMOOTHED(2, -4)) << 0));
            desc[31] = (uchar)(((SMOOTHED(1, -10) < SMOOTHED(-1, 2)) << 7) + ((SMOOTHED(8, -7) < SMOOTHED(-6, 18)) << 6) + ((SMOOTHED(9, 12) < SMOOTHED(-7, -23)) << 5) + ((SMOOTHED(8, -6) < SMOOTHED(5, 2)) << 4) + ((SMOOTHED(-9, 6) < SMOOTHED(-12, -7)) << 3) + ((SMOOTHED(-1, -2) < SMOOTHED(-7, 2)) << 2) + ((SMOOTHED(9, 9) < SMOOTHED(7, 15)) << 1) + ((SMOOTHED(6, 2) < SMOOTHED(-6, 6)) << 0));
        #undef SMOOTHED

        for(int k = 0; k < 32; k++){
            descriptor_1.at<uchar>(i, k) = desc[k];
        }
    }
    for(int i =0 ; i < keylist_2.size(); i++){
        KeyPoint pt = keylist_2[i];
        uchar desc[32];
        #define SMOOTHED(y,x) smoothedSum(sum_2, pt, y, x)
            desc[0] = (uchar)(((SMOOTHED(-2, -1) < SMOOTHED(7, -1)) << 7) + ((SMOOTHED(-14, -1) < SMOOTHED(-3, 3)) << 6) + ((SMOOTHED(1, -2) < SMOOTHED(11, 2)) << 5) + ((SMOOTHED(1, 6) < SMOOTHED(-10, -7)) << 4) + ((SMOOTHED(13, 2) < SMOOTHED(-1, 0)) << 3) + ((SMOOTHED(-14, 5) < SMOOTHED(5, -3)) << 2) + ((SMOOTHED(-2, 8) < SMOOTHED(2, 4)) << 1) + ((SMOOTHED(-11, 8) < SMOOTHED(-15, 5)) << 0));
            desc[1] = (uchar)(((SMOOTHED(-6, -23) < SMOOTHED(8, -9)) << 7) + ((SMOOTHED(-12, 6) < SMOOTHED(-10, 8)) << 6) + ((SMOOTHED(-3, -1) < SMOOTHED(8, 1)) << 5) + ((SMOOTHED(3, 6) < SMOOTHED(5, 6)) << 4) + ((SMOOTHED(-7, -6) < SMOOTHED(5, -5)) << 3) + ((SMOOTHED(22, -2) < SMOOTHED(-11, -8)) << 2) + ((SMOOTHED(14, 7) < SMOOTHED(8, 5)) << 1) + ((SMOOTHED(-1, 14) < SMOOTHED(-5, -14)) << 0));
            desc[2] = (uchar)(((SMOOTHED(-14, 9) < SMOOTHED(2, 0)) << 7) + ((SMOOTHED(7, -3) < SMOOTHED(22, 6)) << 6) + ((SMOOTHED(-6, 6) < SMOOTHED(-8, -5)) << 5) + ((SMOOTHED(-5, 9) < SMOOTHED(7, -1)) << 4) + ((SMOOTHED(-3, -7) < SMOOTHED(-10, -18)) << 3) + ((SMOOTHED(4, -5) < SMOOTHED(0, 11)) << 2) + ((SMOOTHED(2, 3) < SMOOTHED(9, 10)) << 1) + ((SMOOTHED(-10, 3) < SMOOTHED(4, 9)) << 0));
            desc[3] = (uchar)(((SMOOTHED(0, 12) < SMOOTHED(-3, 19)) << 7) + ((SMOOTHED(1, 15) < SMOOTHED(-11, -5)) << 6) + ((SMOOTHED(14, -1) < SMOOTHED(7, 8)) << 5) + ((SMOOTHED(7, -23) < SMOOTHED(-5, 5)) << 4) + ((SMOOTHED(0, -6) < SMOOTHED(-10, 17)) << 3) + ((SMOOTHED(13, -4) < SMOOTHED(-3, -4)) << 2) + ((SMOOTHED(-12, 1) < SMOOTHED(-12, 2)) << 1) + ((SMOOTHED(0, 8) < SMOOTHED(3, 22)) << 0));
            desc[4] = (uchar)(((SMOOTHED(-13, 13) < SMOOTHED(3, -1)) << 7) + ((SMOOTHED(-16, 17) < SMOOTHED(6, 10)) << 6) + ((SMOOTHED(7, 15) < SMOOTHED(-5, 0)) << 5) + ((SMOOTHED(2, -12) < SMOOTHED(19, -2)) << 4) + ((SMOOTHED(3, -6) < SMOOTHED(-4, -15)) << 3) + ((SMOOTHED(8, 3) < SMOOTHED(0, 14)) << 2) + ((SMOOTHED(4, -11) < SMOOTHED(5, 5)) << 1) + ((SMOOTHED(11, -7) < SMOOTHED(7, 1)) << 0));
            desc[5] = (uchar)(((SMOOTHED(6, 12) < SMOOTHED(21, 3)) << 7) + ((SMOOTHED(-3, 2) < SMOOTHED(14, 1)) << 6) + ((SMOOTHED(5, 1) < SMOOTHED(-5, 11)) << 5) + ((SMOOTHED(3, -17) < SMOOTHED(-6, 2)) << 4) + ((SMOOTHED(6, 8) < SMOOTHED(5, -10)) << 3) + ((SMOOTHED(-14, -2) < SMOOTHED(0, 4)) << 2) + ((SMOOTHED(5, -7) < SMOOTHED(-6, 5)) << 1) + ((SMOOTHED(10, 4) < SMOOTHED(4, -7)) << 0));
            desc[6] = (uchar)(((SMOOTHED(22, 0) < SMOOTHED(7, -18)) << 7) + ((SMOOTHED(-1, -3) < SMOOTHED(0, 18)) << 6) + ((SMOOTHED(-4, 22) < SMOOTHED(-5, 3)) << 5) + ((SMOOTHED(1, -7) < SMOOTHED(2, -3)) << 4) + ((SMOOTHED(19, -20) < SMOOTHED(17, -2)) << 3) + ((SMOOTHED(3, -10) < SMOOTHED(-8, 24)) << 2) + ((SMOOTHED(-5, -14) < SMOOTHED(7, 5)) << 1) + ((SMOOTHED(-2, 12) < SMOOTHED(-4, -15)) << 0));
            desc[7] = (uchar)(((SMOOTHED(4, 12) < SMOOTHED(0, -19)) << 7) + ((SMOOTHED(20, 13) < SMOOTHED(3, 5)) << 6) + ((SMOOTHED(-8, -12) < SMOOTHED(5, 0)) << 5) + ((SMOOTHED(-5, 6) < SMOOTHED(-7, -11)) << 4) + ((SMOOTHED(6, -11) < SMOOTHED(-3, -22)) << 3) + ((SMOOTHED(15, 4) < SMOOTHED(10, 1)) << 2) + ((SMOOTHED(-7, -4) < SMOOTHED(15, -6)) << 1) + ((SMOOTHED(5, 10) < SMOOTHED(0, 24)) << 0));
            desc[8] = (uchar)(((SMOOTHED(3, 6) < SMOOTHED(22, -2)) << 7) + ((SMOOTHED(-13, 14) < SMOOTHED(4, -4)) << 6) + ((SMOOTHED(-13, 8) < SMOOTHED(-18, -22)) << 5) + ((SMOOTHED(-1, -1) < SMOOTHED(-7, 3)) << 4) + ((SMOOTHED(-19, -12) < SMOOTHED(4, 3)) << 3) + ((SMOOTHED(8, 10) < SMOOTHED(13, -2)) << 2) + ((SMOOTHED(-6, -1) < SMOOTHED(-6, -5)) << 1) + ((SMOOTHED(2, -21) < SMOOTHED(-3, 2)) << 0));
            desc[9] = (uchar)(((SMOOTHED(4, -7) < SMOOTHED(0, 16)) << 7) + ((SMOOTHED(-6, -5) < SMOOTHED(-12, -1)) << 6) + ((SMOOTHED(1, -1) < SMOOTHED(9, 18)) << 5) + ((SMOOTHED(-7, 10) < SMOOTHED(-11, 6)) << 4) + ((SMOOTHED(4, 3) < SMOOTHED(19, -7)) << 3) + ((SMOOTHED(-18, 5) < SMOOTHED(-4, 5)) << 2) + ((SMOOTHED(4, 0) < SMOOTHED(-20, 4)) << 1) + ((SMOOTHED(7, -11) < SMOOTHED(18, 12)) << 0));
            desc[10] = (uchar)(((SMOOTHED(-20, 17) < SMOOTHED(-18, 7)) << 7) + ((SMOOTHED(2, 15) < SMOOTHED(19, -11)) << 6) + ((SMOOTHED(-18, 6) < SMOOTHED(-7, 3)) << 5) + ((SMOOTHED(-4, 1) < SMOOTHED(-14, 13)) << 4) + ((SMOOTHED(17, 3) < SMOOTHED(2, -8)) << 3) + ((SMOOTHED(-7, 2) < SMOOTHED(1, 6)) << 2) + ((SMOOTHED(17, -9) < SMOOTHED(-2, 8)) << 1) + ((SMOOTHED(-8, -6) < SMOOTHED(-1, 12)) << 0));
            desc[11] = (uchar)(((SMOOTHED(-2, 4) < SMOOTHED(-1, 6)) << 7) + ((SMOOTHED(-2, 7) < SMOOTHED(6, 8)) << 6) + ((SMOOTHED(-8, -1) < SMOOTHED(-7, -9)) << 5) + ((SMOOTHED(8, -9) < SMOOTHED(15, 0)) << 4) + ((SMOOTHED(0, 22) < SMOOTHED(-4, -15)) << 3) + ((SMOOTHED(-14, -1) < SMOOTHED(3, -2)) << 2) + ((SMOOTHED(-7, -4) < SMOOTHED(17, -7)) << 1) + ((SMOOTHED(-8, -2) < SMOOTHED(9, -4)) << 0));
            desc[12] = (uchar)(((SMOOTHED(5, -7) < SMOOTHED(7, 7)) << 7) + ((SMOOTHED(-5, 13) < SMOOTHED(-8, 11)) << 6) + ((SMOOTHED(11, -4) < SMOOTHED(0, 8)) << 5) + ((SMOOTHED(5, -11) < SMOOTHED(-9, -6)) << 4) + ((SMOOTHED(2, -6) < SMOOTHED(3, -20)) << 3) + ((SMOOTHED(-6, 2) < SMOOTHED(6, 10)) << 2) + ((SMOOTHED(-6, -6) < SMOOTHED(-15, 7)) << 1) + ((SMOOTHED(-6, -3) < SMOOTHED(2, 1)) << 0));
            desc[13] = (uchar)(((SMOOTHED(11, 0) < SMOOTHED(-3, 2)) << 7) + ((SMOOTHED(7, -12) < SMOOTHED(14, 5)) << 6) + ((SMOOTHED(0, -7) < SMOOTHED(-1, -1)) << 5) + ((SMOOTHED(-16, 0) < SMOOTHED(6, 8)) << 4) + ((SMOOTHED(22, 11) < SMOOTHED(0, -3)) << 3) + ((SMOOTHED(19, 0) < SMOOTHED(5, -17)) << 2) + ((SMOOTHED(-23, -14) < SMOOTHED(-13, -19)) << 1) + ((SMOOTHED(-8, 10) < SMOOTHED(-11, -2)) << 0));
            desc[14] = (uchar)(((SMOOTHED(-11, 6) < SMOOTHED(-10, 13)) << 7) + ((SMOOTHED(1, -7) < SMOOTHED(14, 0)) << 6) + ((SMOOTHED(-12, 1) < SMOOTHED(-5, -5)) << 5) + ((SMOOTHED(4, 7) < SMOOTHED(8, -1)) << 4) + ((SMOOTHED(-1, -5) < SMOOTHED(15, 2)) << 3) + ((SMOOTHED(-3, -1) < SMOOTHED(7, -10)) << 2) + ((SMOOTHED(3, -6) < SMOOTHED(10, -18)) << 1) + ((SMOOTHED(-7, -13) < SMOOTHED(-13, 10)) << 0));
            desc[15] = (uchar)(((SMOOTHED(1, -1) < SMOOTHED(13, -10)) << 7) + ((SMOOTHED(-19, 14) < SMOOTHED(8, -14)) << 6) + ((SMOOTHED(-4, -13) < SMOOTHED(7, 1)) << 5) + ((SMOOTHED(1, -2) < SMOOTHED(12, -7)) << 4) + ((SMOOTHED(3, -5) < SMOOTHED(1, -5)) << 3) + ((SMOOTHED(-2, -2) < SMOOTHED(8, -10)) << 2) + ((SMOOTHED(2, 14) < SMOOTHED(8, 7)) << 1) + ((SMOOTHED(3, 9) < SMOOTHED(8, 2)) << 0));
            desc[16] = (uchar)(((SMOOTHED(-9, 1) < SMOOTHED(-18, 0)) << 7) + ((SMOOTHED(4, 0) < SMOOTHED(1, 12)) << 6) + ((SMOOTHED(0, 9) < SMOOTHED(-14, -10)) << 5) + ((SMOOTHED(-13, -9) < SMOOTHED(-2, 6)) << 4) + ((SMOOTHED(1, 5) < SMOOTHED(10, 10)) << 3) + ((SMOOTHED(-3, -6) < SMOOTHED(-16, -5)) << 2) + ((SMOOTHED(11, 6) < SMOOTHED(-5, 0)) << 1) + ((SMOOTHED(-23, 10) < SMOOTHED(1, 2)) << 0));
            desc[17] = (uchar)(((SMOOTHED(13, -5) < SMOOTHED(-3, 9)) << 7) + ((SMOOTHED(-4, -1) < SMOOTHED(-13, -5)) << 6) + ((SMOOTHED(10, 13) < SMOOTHED(-11, 8)) << 5) + ((SMOOTHED(19, 20) < SMOOTHED(-9, 2)) << 4) + ((SMOOTHED(4, -8) < SMOOTHED(0, -9)) << 3) + ((SMOOTHED(-14, 10) < SMOOTHED(15, 19)) << 2) + ((SMOOTHED(-14, -12) < SMOOTHED(-10, -3)) << 1) + ((SMOOTHED(-23, -3) < SMOOTHED(17, -2)) << 0));
            desc[18] = (uchar)(((SMOOTHED(-3, -11) < SMOOTHED(6, -14)) << 7) + ((SMOOTHED(19, -2) < SMOOTHED(-4, 2)) << 6) + ((SMOOTHED(-5, 5) < SMOOTHED(3, -13)) << 5) + ((SMOOTHED(2, -2) < SMOOTHED(-5, 4)) << 4) + ((SMOOTHED(17, 4) < SMOOTHED(17, -11)) << 3) + ((SMOOTHED(-7, -2) < SMOOTHED(1, 23)) << 2) + ((SMOOTHED(8, 13) < SMOOTHED(1, -16)) << 1) + ((SMOOTHED(-13, -5) < SMOOTHED(1, -17)) << 0));
            desc[19] = (uchar)(((SMOOTHED(4, 6) < SMOOTHED(-8, -3)) << 7) + ((SMOOTHED(-5, -9) < SMOOTHED(-2, -10)) << 6) + ((SMOOTHED(-9, 0) < SMOOTHED(-7, -2)) << 5) + ((SMOOTHED(5, 0) < SMOOTHED(5, 2)) << 4) + ((SMOOTHED(-4, -16) < SMOOTHED(6, 3)) << 3) + ((SMOOTHED(2, -15) < SMOOTHED(-2, 12)) << 2) + ((SMOOTHED(4, -1) < SMOOTHED(6, 2)) << 1) + ((SMOOTHED(1, 1) < SMOOTHED(-2, -8)) << 0));
            desc[20] = (uchar)(((SMOOTHED(-2, 12) < SMOOTHED(-5, -2)) << 7) + ((SMOOTHED(-8, 8) < SMOOTHED(-9, 9)) << 6) + ((SMOOTHED(2, -10) < SMOOTHED(3, 1)) << 5) + ((SMOOTHED(-4, 10) < SMOOTHED(-9, 4)) << 4) + ((SMOOTHED(6, 12) < SMOOTHED(2, 5)) << 3) + ((SMOOTHED(-3, -8) < SMOOTHED(0, 5)) << 2) + ((SMOOTHED(-13, 1) < SMOOTHED(-7, 2)) << 1) + ((SMOOTHED(-1, -10) < SMOOTHED(7, -18)) << 0));
            desc[21] = (uchar)(((SMOOTHED(-1, 8) < SMOOTHED(-9, -10)) << 7) + ((SMOOTHED(-23, -1) < SMOOTHED(6, 2)) << 6) + ((SMOOTHED(-5, -3) < SMOOTHED(3, 2)) << 5) + ((SMOOTHED(0, 11) < SMOOTHED(-4, -7)) << 4) + ((SMOOTHED(15, 2) < SMOOTHED(-10, -3)) << 3) + ((SMOOTHED(-20, -8) < SMOOTHED(-13, 3)) << 2) + ((SMOOTHED(-19, -12) < SMOOTHED(5, -11)) << 1) + ((SMOOTHED(-17, -13) < SMOOTHED(-3, 2)) << 0));
            desc[22] = (uchar)(((SMOOTHED(7, 4) < SMOOTHED(-12, 0)) << 7) + ((SMOOTHED(5, -1) < SMOOTHED(-14, -6)) << 6) + ((SMOOTHED(-4, 11) < SMOOTHED(0, -4)) << 5) + ((SMOOTHED(3, 10) < SMOOTHED(7, -3)) << 4) + ((SMOOTHED(13, 21) < SMOOTHED(-11, 6)) << 3) + ((SMOOTHED(-12, 24) < SMOOTHED(-7, -4)) << 2) + ((SMOOTHED(4, 16) < SMOOTHED(3, -14)) << 1) + ((SMOOTHED(-3, 5) < SMOOTHED(-7, -12)) << 0));
            desc[23] = (uchar)(((SMOOTHED(0, -4) < SMOOTHED(7, -5)) << 7) + ((SMOOTHED(-17, -9) < SMOOTHED(13, -7)) << 6) + ((SMOOTHED(22, -6) < SMOOTHED(-11, 5)) << 5) + ((SMOOTHED(2, -8) < SMOOTHED(23, -11)) << 4) + ((SMOOTHED(7, -10) < SMOOTHED(-1, 14)) << 3) + ((SMOOTHED(-3, -10) < SMOOTHED(8, 3)) << 2) + ((SMOOTHED(-13, 1) < SMOOTHED(-6, 0)) << 1) + ((SMOOTHED(-7, -21) < SMOOTHED(6, -14)) << 0));
            desc[24] = (uchar)(((SMOOTHED(18, 19) < SMOOTHED(-4, -6)) << 7) + ((SMOOTHED(10, 7) < SMOOTHED(-1, -4)) << 6) + ((SMOOTHED(-1, 21) < SMOOTHED(1, -5)) << 5) + ((SMOOTHED(-10, 6) < SMOOTHED(-11, -2)) << 4) + ((SMOOTHED(18, -3) < SMOOTHED(-1, 7)) << 3) + ((SMOOTHED(-3, -9) < SMOOTHED(-5, 10)) << 2) + ((SMOOTHED(-13, 14) < SMOOTHED(17, -3)) << 1) + ((SMOOTHED(11, -19) < SMOOTHED(-1, -18)) << 0));
            desc[25] = (uchar)(((SMOOTHED(8, -2) < SMOOTHED(-18, -23)) << 7) + ((SMOOTHED(0, -5) < SMOOTHED(-2, -9)) << 6) + ((SMOOTHED(-4, -11) < SMOOTHED(2, -8)) << 5) + ((SMOOTHED(14, 6) < SMOOTHED(-3, -6)) << 4) + ((SMOOTHED(-3, 0) < SMOOTHED(-15, 0)) << 3) + ((SMOOTHED(-9, 4) < SMOOTHED(-15, -9)) << 2) + ((SMOOTHED(-1, 11) < SMOOTHED(3, 11)) << 1) + ((SMOOTHED(-10, -16) < SMOOTHED(-7, 7)) << 0));
            desc[26] = (uchar)(((SMOOTHED(-2, -10) < SMOOTHED(-10, -2)) << 7) + ((SMOOTHED(-5, -3) < SMOOTHED(5, -23)) << 6) + ((SMOOTHED(13, -8) < SMOOTHED(-15, -11)) << 5) + ((SMOOTHED(-15, 11) < SMOOTHED(6, -6)) << 4) + ((SMOOTHED(-16, -3) < SMOOTHED(-2, 2)) << 3) + ((SMOOTHED(6, 12) < SMOOTHED(-16, 24)) << 2) + ((SMOOTHED(-10, 0) < SMOOTHED(8, 11)) << 1) + ((SMOOTHED(-7, 7) < SMOOTHED(-19, -7)) << 0));
            desc[27] = (uchar)(((SMOOTHED(5, 16) < SMOOTHED(9, -3)) << 7) + ((SMOOTHED(9, 7) < SMOOTHED(-7, -16)) << 6) + ((SMOOTHED(3, 2) < SMOOTHED(-10, 9)) << 5) + ((SMOOTHED(21, 1) < SMOOTHED(8, 7)) << 4) + ((SMOOTHED(7, 0) < SMOOTHED(1, 17)) << 3) + ((SMOOTHED(-8, 12) < SMOOTHED(9, 6)) << 2) + ((SMOOTHED(11, -7) < SMOOTHED(-8, -6)) << 1) + ((SMOOTHED(19, 0) < SMOOTHED(9, 3)) << 0));
            desc[28] = (uchar)(((SMOOTHED(1, -7) < SMOOTHED(-5, -11)) << 7) + ((SMOOTHED(0, 8) < SMOOTHED(-2, 14)) << 6) + ((SMOOTHED(12, -2) < SMOOTHED(-15, -6)) << 5) + ((SMOOTHED(4, 12) < SMOOTHED(0, -21)) << 4) + ((SMOOTHED(17, -4) < SMOOTHED(-6, -7)) << 3) + ((SMOOTHED(-10, -9) < SMOOTHED(-14, -7)) << 2) + ((SMOOTHED(-15, -10) < SMOOTHED(-15, -14)) << 1) + ((SMOOTHED(-7, -5) < SMOOTHED(5, -12)) << 0));
            desc[29] = (uchar)(((SMOOTHED(-4, 0) < SMOOTHED(15, -4)) << 7) + ((SMOOTHED(5, 2) < SMOOTHED(-6, -23)) << 6) + ((SMOOTHED(-4, -21) < SMOOTHED(-6, 4)) << 5) + ((SMOOTHED(-10, 5) < SMOOTHED(-15, 6)) << 4) + ((SMOOTHED(4, -3) < SMOOTHED(-1, 5)) << 3) + ((SMOOTHED(-4, 19) < SMOOTHED(-23, -4)) << 2) + ((SMOOTHED(-4, 17) < SMOOTHED(13, -11)) << 1) + ((SMOOTHED(1, 12) < SMOOTHED(4, -14)) << 0));
            desc[30] = (uchar)(((SMOOTHED(-11, -6) < SMOOTHED(-20, 10)) << 7) + ((SMOOTHED(4, 5) < SMOOTHED(3, 20)) << 6) + ((SMOOTHED(-8, -20) < SMOOTHED(3, 1)) << 5) + ((SMOOTHED(-19, 9) < SMOOTHED(9, -3)) << 4) + ((SMOOTHED(18, 15) < SMOOTHED(11, -4)) << 3) + ((SMOOTHED(12, 16) < SMOOTHED(8, 7)) << 2) + ((SMOOTHED(-14, -8) < SMOOTHED(-3, 9)) << 1) + ((SMOOTHED(-6, 0) < SMOOTHED(2, -4)) << 0));
            desc[31] = (uchar)(((SMOOTHED(1, -10) < SMOOTHED(-1, 2)) << 7) + ((SMOOTHED(8, -7) < SMOOTHED(-6, 18)) << 6) + ((SMOOTHED(9, 12) < SMOOTHED(-7, -23)) << 5) + ((SMOOTHED(8, -6) < SMOOTHED(5, 2)) << 4) + ((SMOOTHED(-9, 6) < SMOOTHED(-12, -7)) << 3) + ((SMOOTHED(-1, -2) < SMOOTHED(-7, 2)) << 2) + ((SMOOTHED(9, 9) < SMOOTHED(7, 15)) << 1) + ((SMOOTHED(6, 2) < SMOOTHED(-6, 6)) << 0));
        #undef SMOOTHED

        for(int k = 0; k < 32; k++){
            descriptor_2.at<uchar>(i, k) = desc[k];
        }
    }
}



bool response_comparator(const KeyPoint& p1, const KeyPoint& p2)
{
    if (p1.response > p2.response)
        return 1;
    else if (p1.response == p2.response) {
        if (p1.pt.x > p2.pt.x)
            return 1;
        else if (p1.pt.x == p2.pt.x) {
            if (p1.pt.y > p2.pt.y)
                return 1;
        }
    }
    return 0;
}

MYORB::MYORB( int N, int t , int op, int st, int et, int kn, int mt, int l, float sf, Mat img1, Mat img2){
    // parameters
    FAST_N = N;
    FAST_threshold = t;
    FAST_orientation_patch_size = op;
    FAST_scorethreshold = st;
    FAST_edgethreshold = et;
    keypoints_num = kn;
    MATCH_threshold = mt;

    FAST_nlevels = l;
    FAST_scaling = sf;

    // outfile
    outfile_name = "../result.txt";
    outfile.open(outfile_name, ios::out);

    // img1
    img_1 = img1;
    img_2 = img2;
    keylist_1 = vector<KeyPoint>();
    keylist_2 = vector<KeyPoint>();

    matches = vector<DMatch>();
    good_matches = vector<DMatch>();
}


vector<DMatch> MYORB::Matching(){
    // cout << "build image pyramid..." << endl;
    FAST_build_pyramid();
    
    // FAST algorithm to produce keypoint lists
    // cout << "detect keypoints..." << endl;
    FAST_detector(1);
    FAST_detector(2);

    // cout << keylist_1.size() << endl;
    sort(keylist_1.begin(), keylist_1.end(), response_comparator);
    // sort(keylist_2.begin(), keylist_2.end(), response_comparator);
    while (keylist_1.size() > keypoints_num) keylist_1.pop_back();
    // while (keylist_2.size() > keypoints_num) keylist_2.pop_back();
    // smoothing the image
    BRIEF_smoothing();

    // Create descriptor matrix and use BRIEF descriptor
    // cout << "Produce descriptor..." << endl;
    descriptor_1 = Mat(keylist_1.size(), 32, CV_8UC1, Scalar(0));
    descriptor_2 = Mat(keylist_2.size(), 32, CV_8UC1, Scalar(0));
    BRIEF_descriptor(1);
    BRIEF_descriptor(2);
    // BRIEF_descriptor_old();


    // default descriptor
    // Ptr<DescriptorExtractor> descriptor = ORB::create(); 
    // descriptor->compute (img_1, keylist_1, descriptor_1);
    // descriptor->compute (img_2, keylist_2, descriptor_2);

    // Match keypoints by brute force
    // cout << "Match keypoints..." << endl;
    MATCH_BFmatcher();
    
    // Optimize the matches
    // cout << "Optimize matches..." << endl;
    MATCH_optimization();

    return good_matches;

// Produce corresps_feature (Do it outside)
    // Mat corresps_feature;
    // corresps_feature.create(good_matches.size(), 1, CV_32SC4);
    // Vec4i * corresps_feature_ptr = corresps_feature.ptr<Vec4i>();
    // for(int idx = 0, i = 0; idx < good_matches.size(); idx++)
    // {
    //     corresps_feature_ptr[i++] = Vec4i(keylist_1[good_matches[idx].trainIdx].pt.x, keylist_1[good_matches[idx].trainIdx].pt.y, keylist_2[good_matches[idx].queryIdx].pt.x, keylist_2[good_matches[idx].queryIdx].pt.y);
    // }
    // return corresps_feature;
}

void MYORB::DISPLAY_image(Mat& image, string title){ 
    imshow(title, image); 
}

void MYORB::DISPLAY_image_with_keypoints(Mat& image, vector<KeyPoint>& key_list, string title){
    Mat outimg;
    drawKeypoints(image, key_list, outimg, Scalar::all(-1), DrawMatchesFlags::DEFAULT);
    imshow("ORB with features", outimg);
}

void MYORB::DISPLAY_matches(){
    Mat img_match;
    cout << "all matching pair" << endl;
    drawMatches(img_2, keylist_2, img_1, keylist_1, matches, img_match);
    imshow ( "all matching pair", img_match );

    Mat img_goodmatch;
    cout << "optimized matching pair" << endl;
    drawMatches(img_2, keylist_2, img_1, keylist_1, good_matches, img_goodmatch);
    imshow ( "optimized matching pair", img_goodmatch );
}

int MYORB::FAST_consecutive1_finder(vector<int>& array){
    int count = 0;
    int maxC = 0;
    for (int i = 0; i < array.size(); i++) {
        if (array[i]) {
            count = count + 1;
        } 
        else count = 0;
        if (maxC < count)
            maxC = count;
    }
    return maxC;
}

void MYORB::FAST_build_pyramid(){
    Mat blank;
    for (int level = 0; level < FAST_nlevels; level++) {
        img_pyramid_1.push_back(blank);
        img_pyramid_2.push_back(blank);
    }
    for (int level = 0; level < FAST_nlevels; level++) {
        // Compute the resized image
        if (level != 0) {
            Size sz(cvRound((float)img_pyramid_1[level-1].cols/FAST_scaling), cvRound((float)img_pyramid_1[level-1].rows/FAST_scaling));
            resize(img_pyramid_1[level-1], img_pyramid_1[level], sz, 0, 0, INTER_LINEAR);
        } else {
            img_pyramid_1[level] = img_1;
        }
    }
    for (int level = 0; level < FAST_nlevels; level++) {
        // Compute the resized image
        if (level != 0) {
            Size sz(cvRound((float)img_pyramid_2[level-1].cols/FAST_scaling), cvRound((float)img_pyramid_2[level-1].rows/FAST_scaling));
            resize(img_pyramid_2[level-1], img_pyramid_2[level], sz, 0, 0, INTER_LINEAR);
        } else {
            img_pyramid_2[level] = img_2;
        }
    }
}

void MYORB::FAST_keypoint_output(vector<KeyPoint>& k){
    int x, y, score;
    for (int i = 0; i < k.size(); i++) {
        x = k[i].pt.x;
        y = k[i].pt.y;
        score = int(k[i].response);
        // file << x << ", " << y << "," << score << endl;
        // cout << score << endl;
        outfile << x << ", " << y << "|" << score << endl;
    }
}

void MYORB::FAST_detector(int option){
    assert(img_pyramid_1.size() == FAST_nlevels);
    assert(img_pyramid_2.size() == FAST_nlevels);

    for(int level = 0; level < FAST_nlevels; level++){
        Mat img;
        if(option == 1) img = img_pyramid_1[level];
        else if(option == 2) img = img_pyramid_2[level];
        
        // cout << "   Processing level "<< level << ": size = (" << img.cols << ", " << img.rows << ")" << endl;

        int p_center;
        Mat score(img.rows, img.cols, CV_8UC1, Scalar(0));
        Mat key(img.rows, img.cols, CV_8UC1, Scalar(0));
        Mat orient(img.rows, img.cols, CV_64FC1, Scalar(0));

        vector<KeyPoint> candidate;

        vector<int> p(16, 0);

        for (int i = 0; i < img.rows; i++) {
            for (int j = 0; j < img.cols; j++) {
                int score_temp = 0;
                key.at<uchar>(i, j) = 0;
                score.at<uchar>(i, j) = 0;
                orient.at<float>(i, j) = 0;

                if (i < FAST_edgethreshold || j < FAST_edgethreshold || i > img.rows - FAST_edgethreshold || j > img.cols - FAST_edgethreshold)
                    continue;

                // FAST-N
                // 1. circle -> center at p and radius = 3 (pixels)
                p_center = (int)img.at<uchar>(i, j);
                p[0] = (int)img.at<uchar>(i - 3, j);
                p[1] = (int)img.at<uchar>(i - 3, j + 1);
                p[2] = (int)img.at<uchar>(i - 2, j + 2);
                p[3] = (int)img.at<uchar>(i - 1, j + 3);
                p[4] = (int)img.at<uchar>(i, j + 3);
                p[5] = (int)img.at<uchar>(i + 1, j + 3);
                p[6] = (int)img.at<uchar>(i + 2, j + 2);
                p[7] = (int)img.at<uchar>(i + 3, j + 1);
                p[8] = (int)img.at<uchar>(i + 3, j);
                p[9] = (int)img.at<uchar>(i + 3, j - 1);
                p[10] = (int)img.at<uchar>(i + 2, j - 2);
                p[11] = (int)img.at<uchar>(i + 1, j - 3);
                p[12] = (int)img.at<uchar>(i, j - 3);
                p[13] = (int)img.at<uchar>(i - 1, j - 3);
                p[14] = (int)img.at<uchar>(i - 2, j - 2);
                p[15] = (int)img.at<uchar>(i - 3, j - 1);

                // ================================================
                // 2. look if more than N contigious pixels in the circle (total 16) are
                // bigger or smaller enough (> p+t or < p-t)
                //      if so, label it as a feature point.
                //      else, reject it.
                vector<int> p_bigger(32, 0);
                vector<int> p_smaller(32, 0);
                for (int i = 0; i < 16; i++) {
                    // create array for step 2 usage
                    p_bigger[i] = 0;
                    p_smaller[i] = 0;
                    if (abs(p[i] - p_center) > FAST_threshold && p[i] > p_center)
                        p_bigger[i] = 1; // bigger
                    else if (abs(p[i] - p_center) > FAST_threshold && p[i] < p_center)
                        p_smaller[i] = 1; // smaller
                    p_bigger[i + 16] = p_bigger[i];
                    p_smaller[i + 16] = p_smaller[i];
                }

                // label it, the following part will do Non-maximal supression
                if (FAST_consecutive1_finder(p_bigger) >= FAST_N || FAST_consecutive1_finder(p_smaller) >= FAST_N)
                    key.at<uchar>(i, j) = 1;
                else {
                    key.at<uchar>(i, j) = 0;
                }

                // FAST_SCORE
                vector<int> p_double(32, 0);
                for (int k = 0; k < 16; k++) {
                    p_double[k] = p[k];
                    p_double[k + 16] = p[k];
                }
                for (int k = 0; k < 16; k++) {
                    int local_threshold = 255;
                    for (int s = 0; s < 9; s++) {
                        if (abs(p_double[k + s] - p_center) < local_threshold)
                            local_threshold = abs(p_double[k + s] - p_center);
                    }
                    if (local_threshold > score_temp){
                        orient.at<uchar>(i, j) = k;
                        score_temp = local_threshold;
                    }
                }
                score.at<uchar>(i, j) = score_temp == 0 ? 0 : score_temp - 1;

                // Orientation
                int x_sum = 0;
                int y_sum = 0;
                for(int x = -3; x < 4; x++ ){
                    for(int y = -3; y < 4; y++){
                        x_sum += x*(int)img.at<uchar>(i, j+x);
                        y_sum += y*(int)img.at<uchar>(i+y, j);
                    }
                }
                orient.at<float>(i, j) = atan2(y_sum, x_sum);
                

            }
        }
        
        // Non-maximal suppression
        // cout << "test" << endl;
        for (int i = FAST_edgethreshold; i < (img.rows - FAST_edgethreshold); i++) {
            for (int j = FAST_edgethreshold; j < (img.cols - FAST_edgethreshold); j++) {
                if (key.at<uchar>(i, j) == 1 // keypoint candidate
                    && (int(score.at<uchar>(i, j)) > int(score.at<uchar>(i-1, j-1)) || key.at<uchar>(i-1, j-1) == 0)
                    && (int(score.at<uchar>(i, j)) > int(score.at<uchar>(i+0, j-1)) || key.at<uchar>(i+0, j-1) == 0)
                    && (int(score.at<uchar>(i, j)) > int(score.at<uchar>(i+1, j-1)) || key.at<uchar>(i+1, j-1) == 0)
                    && (int(score.at<uchar>(i, j)) > int(score.at<uchar>(i-1, j+0)) || key.at<uchar>(i-1, j+0) == 0)
                    && (int(score.at<uchar>(i, j)) > int(score.at<uchar>(i+1, j+0)) || key.at<uchar>(i+1, j+0) == 0)
                    && (int(score.at<uchar>(i, j)) > int(score.at<uchar>(i-1, j+1)) || key.at<uchar>(i-1, j+1) == 0)
                    && (int(score.at<uchar>(i, j)) > int(score.at<uchar>(i+0, j+1)) || key.at<uchar>(i+0, j+1) == 0)
                    && (int(score.at<uchar>(i, j)) > int(score.at<uchar>(i+1, j+1)) || key.at<uchar>(i+1, j+1) == 0)
                    ){
                    // Remember to convert the coordinates back to original coordinates
                    int power = int(pow(2, level));
                    // cout << "add keypoints: (" << j*power << ", " << i*power << ")" << endl;
                    KeyPoint temp = KeyPoint(Point2f(j*power, i*power), 1, orient.at<uchar>(i, j), int(score.at<uchar>(i, j)), 0, -1);
                    
                    if(option == 1){
                        // if(keylist_1.size() < keypoints_num)
                        keylist_1.push_back(temp);

                    }
                    else if(option == 2){
                        // if(keylist_2.size() < keypoints_num)
                        keylist_2.push_back(temp);

                    }
                }
            }
        }
    }
}

void MYORB::BRIEF_smoothing(){
    Mat_<float> kernel(5, 5);
    kernel << 1, 4, 6, 4, 1, 4, 16, 24, 16, 4, 6, 24, 36, 24, 6, 4, 16, 24, 16, 4, 1, 4, 6, 4, 1;
    kernel = kernel/256;
    // cout << kernel << endl;

    filter2D(img_1, smth_1, -1, kernel);
    filter2D(img_2, smth_2, -1, kernel);

}


void MYORB::BRIEF_descriptor(int option){
    Mat img;
    vector<KeyPoint> keylist;
    vector<int> orient;
    if(option == 1){
        img = smth_1;
        keylist = keylist_1;
        orient = orientation_1;
    }
    else if(option == 2){
        img = smth_2;
        keylist = keylist_2;
        orient = orientation_2;
    }
    // assert(orient.size() == keylist.size());
    for(int i = 0; i < keylist.size(); i++){
        int x = keylist[i].pt.x;
        int y = keylist[i].pt.y;
        for(int ic = 0; ic < 32; ic++){
            uchar desc = 0;
            for(int bit = 0; bit < 8; bit++){
                int x_d1, x_d2, y_d1, y_d2;
                BRIEF_pattern_LUT(ic*8+bit, float(keylist[i].angle), x_d1, x_d2, y_d1, y_d2);
                // BRIEF_pattern_LUT(ic*8+bit, 0, x_d1, x_d2, y_d1, y_d2);
                bool result = img.at<uchar>(y+y_d1, x+x_d1) > img.at<uchar>(y+y_d2, x+x_d2);
                // cout << result;
                desc += int(result) << bit;
                // cout << endl;
            }

            if(option == 1) descriptor_1.at<uchar>(i, ic) = desc;
            else if(option == 2) descriptor_2.at<uchar>(i, ic) = desc;
        }

    }

}

int MYORB::MATCH_Hamming_distance(uchar x, uchar y){
    int temp = int(x) ^ int(y);
    int setbits = 0;

    while (temp > 0){
        setbits += temp & 1;
        temp >>= 1;
    }

    return setbits;
}

bool MYORB::BRIEF_searcher(int index, int bit, Mat& descriptor){
    return bool( (int(descriptor.at<uchar>(index, int(bit/8))) >> (7-bit%8)) & 1);
}

void MYORB::MATCH_BFmatcher(){
    matches.clear();
    // assert(descriptor_1.cols == descriptor_2.cols);
    // For each descriptor in desc2, find the most similar desciptor in desc1
    // query -> img2
    // train -> img1
    for(int idx2 = 0; idx2 < descriptor_2.rows; idx2++){
        int min_index = -1;
        int min_value = 256;
        for(int idx1 = 0; idx1 < descriptor_1.rows; idx1++){
            int hamming_distance_counter = 0;
            for(int k = 0; k < descriptor_2.cols; k++){
                hamming_distance_counter += MATCH_Hamming_distance(descriptor_2.at<uchar>(idx2, k), descriptor_1.at<uchar>(idx1, k));

            }
            if(hamming_distance_counter < min_value){
                min_index = idx1;
                min_value = hamming_distance_counter;
            }
        }
        // constructor: query -> train -> distance
        //              img2     img1
        DMatch temp(idx2, min_index, min_value);
        matches.push_back(temp);
    }
}

void MYORB::MATCH_HBST_construct(){
    // Use descriptor matrix 1 to build the HBST
    // So the img1 -> train idnex
    vector<int> blank;
    for(int i = 0; i < 128; i++) 
        HBST_index_buckets.push_back(blank);
    
    for(int idx1 = 0; idx1 < descriptor_1.rows; idx1++){
        
        // Tracerse the tree
        int bit = 0;
        int next_bit = 0;
        while(1){
            if(BRIEF_searcher(idx1, bit, descriptor_1)){
                next_bit = bit*2 + 1;
            }
            else next_bit = bit*2 + 2;
            if(next_bit > 254) break;
            else bit = next_bit;
        }
        int bucket_num = bit - 127;

        // Reach the bucket, add the index into it
        cout << "Direct to bucket [" << bucket_num << "]" << endl;
        HBST_index_buckets[bucket_num].push_back(idx1);
    }

    // DEBUG
    for(int i = 0; i < 128; i++) {
        cout << "bucket [" << i << "] ";
        for(int j = 0; j < HBST_index_buckets[i].size(); j++){
            cout << HBST_index_buckets[i][j] << " ";
        }
        cout << endl;
    }
}

void MYORB::MATCH_HBST_matcher(){
    // assert(descriptor_1.cols == descriptor_2.cols);
    // For each descriptor in desc2, find the most similar desciptor in desc1
    // query -> img2
    // train -> img1
    for(int idx2 = 0; idx2 < descriptor_2.rows; idx2++){
        // Traverse the tree (Find the bucket)
        int bit = 0;
        int next_bit = 0;
        while(1){
            if(BRIEF_searcher(idx2, bit, descriptor_2)){
                next_bit = bit*2 + 1;
            }
            else next_bit = bit*2 + 2;
            if(next_bit > 254) break;
            else bit = next_bit;
        }
        int bucket_num = bit - 127;

        int min_index = -1;
        int min_value = 256;
        // Search the corresponding bucket
        for(int idx_bucket = 0; idx_bucket < HBST_index_buckets[bucket_num].size(); idx_bucket++){
            int hamming_distance_counter = 0;
            int idx1 = HBST_index_buckets[bucket_num][idx_bucket];
            for(int k = 0; k < descriptor_1.cols; k++){
                hamming_distance_counter += MATCH_Hamming_distance(descriptor_1.at<uchar>(idx1, k), descriptor_2.at<uchar>(idx2, k));
            }
            if(hamming_distance_counter < min_value){
                min_index = idx1;
                min_value = hamming_distance_counter;
            }
        }
        // constructor: query -> train -> distance
        //              img2     img1
        assert(idx2 < descriptor_2.rows && min_index < descriptor_1.rows);
        if(min_index != -1){
            cout << idx2 << " <-> " << min_index << endl; 
            DMatch temp(idx2, min_index, min_value);
            matches.push_back(temp);
        }
    }
}

void MYORB::MATCH_optimization(){
    for (int i = 0; i < matches.size(); i++) {
        if (matches[i].distance <= MATCH_threshold) {
            good_matches.push_back(matches[i]);
        }
    }
}

void MYORB::MATCH_matches_output(){
    int x1, y1, x2, y2;
    // cout << matches.size() << endl;
    for (int i = 0; i < matches.size(); i++) {
        x1 = keylist_1[matches[i].trainIdx].pt.x;
        y1 = keylist_1[matches[i].trainIdx].pt.y;
        x2 = keylist_2[matches[i].queryIdx].pt.x;
        y2 = keylist_2[matches[i].queryIdx].pt.y;
        outfile  << x1 << ", " << y1 << " <-> " << x2 << ", " << y2 << endl;
    }
}

KeyPoint MYORB::POINT_k1(int index){
    return keylist_1[index];
}
KeyPoint MYORB::POINT_k2(int index){
    return keylist_2[index];
}