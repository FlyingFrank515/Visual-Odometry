#ifndef MYORB_H
#define MYORB_H

// 1. Read Image
// 2. Create Image pyramid
// 3. Do FAST detection to each image in the pyramid (Note that the coordinates should be converted into original coordinates)
// 4. When doing 3, calculate the orientation and the FAST score simultaneously. 
// 5. Thresholding the value, filter out bad key-points.
// 6. According to the orientation, Applying the pre-computed Gaussian pattern to keypoints and get the descriptor.
// 7. Create descriptor BST. Limit the size of the tree.
// 8. Search the tree to find matching points.
// 9. Thresholding the value, filter out bad matches.

#include <algorithm>
#include <cmath>
#include <fstream>
#include <iostream>
#include <opencv2/opencv.hpp>
#include <vector> // vector

using namespace std;
using namespace cv; 

class MYORB {
    private:
        // Parameters
        int                 FAST_N;
        int                 FAST_threshold;
        int                 FAST_orientation_patch_size;
        int                 FAST_scorethreshold;
        int                 FAST_edgethreshold;
        int                 keypoints_num;
        int                 MATCH_threshold;

        // Image pyramid
        int                 FAST_nlevels;
        float               FAST_scaling;
        vector<Mat>         img_pyramid_1;
        vector<Mat>         img_pyramid_2;

        // output to file
        string              outfile_name;
        fstream             outfile;
        
        // img1
        Mat                 img_1;
        Mat                 smth_1;
        vector<KeyPoint>    keylist_1;
        Mat                 descriptor_1; 
        vector<int>         orientation_1;

        // img2
        Mat                 img_2;
        Mat                 smth_2;
        vector<KeyPoint>    keylist_2;
        Mat                 descriptor_2; 
        vector<int>         orientation_2;

        // HBST (Hamming distance embedded binary search tree)
        vector<vector<int>> HBST_index_buckets;        
        
        // match
        vector<DMatch>      matches;
        vector<DMatch>      good_matches;
    
    public:
        // Constructor¡
        MYORB(int, int, int, int, int, int, int, int, float, Mat, Mat, string);

        // Called by the main program
        Mat     Matching();
        
        // Display
        void    DISPLAY_image(Mat&, string);
        void    DISPLAY_image_with_keypoints(Mat&, vector<KeyPoint>&, string);
        void    DISPLAY_matches();

        // FAST
        void    FAST_build_pyramid();
        void    FAST_detector(int);
        int     FAST_consecutive1_finder(vector<int>&);
        void    FAST_keypoint_output(vector<KeyPoint>&);

        // BRIEF
        void    BRIEF_pattern_LUT(int, int, int&, int&, int&, int&);
        void    BRIEF_descriptor(int);
        bool    BRIEF_searcher(int, int, Mat&);
        void    BRIEF_smoothing();

        // Matching
        int     MATCH_Hamming_distance(uchar, uchar);
        void    MATCH_BFmatcher();
        void    MATCH_HBST_matcher();
        void    MATCH_HBST_construct();
        void    MATCH_matches_output();
        void    MATCH_optimization();
    
};

#endif