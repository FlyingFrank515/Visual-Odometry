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
// Image pyramid
#define FAST_nlevels                    4
#define FAST_scaling                    2

int main(int argc, char *argv[]){
    string filename = argv[3];
    string img1_path = argv[1];
    string img2_path = argv[2];
    
    // read the image
    Mat img1 = imread(img1_path, 0);
    Mat img2 = imread(img2_path, 0);

    // Paramter sequence: 
    MYORB orb(FAST_N, FAST_threshold, FAST_orientation_patch_size, FAST_scorethreshold, FAST_edgethreshold, keypoints_num, MATCH_threshold, FAST_nlevels, FAST_scaling, img1, img2, filename);
    orb.Matching();
}