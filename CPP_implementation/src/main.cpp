#include <fstream>
#include <iostream>
#include <string>
#include "MYORB.h"
#include <opencv2/opencv.hpp>

using namespace std;
using namespace cv;

#define FAST_N                          9
#define FAST_threshold                  20
#define FAST_orientation_patch_size     7
#define FAST_scorethreshold             80
#define FAST_edgethreshold              31
#define keypoints_num                   500
#define MATCH_threshold                 30
#define DISPLAY                         true
#define FIXED                           true
#define DEBUG                           true
#define TESTBENCH                       true

int main(int argc, char *argv[]){
    string img1_path = argv[1];
    string img2_path = argv[2];

    string depth1_path = argv[3];
    string depth2_path = argv[4];
    
    // read the image
    Mat img1 = imread(img1_path, 0);
    Mat img2 = imread(img2_path, 0);
    Mat depth1 = imread(depth1_path, IMREAD_UNCHANGED);
    Mat depth2 = imread(depth2_path, IMREAD_UNCHANGED);

    // Paramter sequence: 
    MYORB orb(FAST_N, FAST_threshold, FAST_orientation_patch_size, FAST_scorethreshold, FAST_edgethreshold, keypoints_num, MATCH_threshold, img1, img2, depth1, depth2, DISPLAY, FIXED, DEBUG, TESTBENCH);
    orb.Matching();
}