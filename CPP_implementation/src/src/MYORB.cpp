#include "MYORB.h"
#include <opencv2/opencv.hpp>
#include <iostream>

using namespace cv;
using namespace std;


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

MYORB::MYORB( int N, int t , int op, int st, int et, int kn, int mt, int l, float sf, Mat img1, Mat img2, string fn){
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
    outfile_name = fn;
    outfile.open(outfile_name, ios::out);

    // img1
    img_1 = img1;
    img_2 = img2;
    keylist_1 = vector<KeyPoint>();
    keylist_2 = vector<KeyPoint>();

    matches = vector<DMatch>();
    good_matches = vector<DMatch>();
}

Mat MYORB::Matching(){
    cout << "build image pyramid..." << endl;
    FAST_build_pyramid();
    
    // FAST algorithm to produce keypoint lists
    cout << "detect keypoints..." << endl;
    FAST_detector(1);
    FAST_detector(2);

    // Rank the keypoints and delete redundable keypoints
    // sort(keylist_1.begin(), keylist_1.end(), response_comparator);
    // sort(keylist_2.begin(), keylist_2.end(), response_comparator);
    // while (keylist_1.size() > keypoints_num) keylist_1.pop_back();
    // while (keylist_2.size() > keypoints_num) keylist_2.pop_back();
    
    //=================================================================

    // DISPLAY_image_with_keypoints(img_1, keylist_1, "Keypoint(image1)");
    
    // FAST_keypoint_output(keylist_1);
    BRIEF_smoothing();

    // Create descriptor matrix and use BRIEF descriptor
    cout << "Produce descriptor..." << endl;
    descriptor_1 = Mat(keylist_1.size(), 32, CV_8UC1, Scalar(0));
    descriptor_2 = Mat(keylist_2.size(), 32, CV_8UC1, Scalar(0));
    BRIEF_descriptor(1);
    BRIEF_descriptor(2);

    // Match keypoints by brute force
    cout << "Match keypoints..." << endl;
    
    // MATCH_HBST_construct();
    // MATCH_HBST_matcher();

    MATCH_BFmatcher();

    MATCH_optimization();

    MATCH_matches_output();
    
    // show the match
    DISPLAY_matches();
    waitKey(0);

    // Produce corresps_feature
    Mat corresps_feature;
    corresps_feature.create(good_matches.size(), 1, CV_32SC4);
    Vec4i * corresps_feature_ptr = corresps_feature.ptr<Vec4i>();
    for(int idx = 0, i = 0; idx < good_matches.size(); idx++)
    {
        corresps_feature_ptr[i++] = Vec4i(keypoints_1[good_matches[idx].queryIdx].pt.x, keypoints_1[good_matches[idx].queryIdx].pt.y, keypoints_2[good_matches[idx].trainIdx].pt.x, keypoints_2[good_matches[idx].trainIdx].pt.y);
    }
    return corresps_feature;
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
        Mat orient(img.rows, img.cols, CV_8UC1, Scalar(0));

        vector<KeyPoint> candidate;

        vector<int> p(16, 0);

        for (int i = 0; i < img.rows; i++) {
            for (int j = 0; j < img.cols; j++) {
                int score_temp = 0;
                key.at<uchar>(i, j) = 0;
                score.at<uchar>(i, j) = 0;

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
                    && (int(score.at<uchar>(i, j)) > FAST_scorethreshold)){
                    // Remember to convert the coordinates back to original coordinates
                    int power = int(pow(2, level));
                    // cout << "add keypoints: (" << j*power << ", " << i*power << ")" << endl;
                    KeyPoint temp = KeyPoint(Point2f(j*power, i*power), 1, -1, int(score.at<uchar>(i, j)), 0, -1);
                    
                    if(option == 1){
                        keylist_1.push_back(temp);
                        orientation_1.push_back(int(orient.at<uchar>(i, j)));
                    }
                    else if(option == 2){
                        keylist_2.push_back(temp);
                        orientation_2.push_back(int(orient.at<uchar>(i, j)));
                    }
                }
            }
        }
    }
}

void MYORB::BRIEF_smoothing(){
    Mat_<float> kernel(5, 5);
    kernel << 1, 4, 6, 4, 1, 4, 16, 24, 16, 4, 6, 24, 46, 24, 6, 4, 16, 24, 16, 4, 1, 4, 6, 4, 1;
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
    assert(orient.size() == keylist.size());
    for(int i = 0; i < keylist.size(); i++){
        int x = keylist[i].pt.x;
        int y = keylist[i].pt.y;
        for(int ic = 0; ic < 32; ic++){
            uchar desc = 0;
            for(int bit = 0; bit < 8; bit++){
                int x_d1, x_d2, y_d1, y_d2;
                BRIEF_pattern_LUT(ic*8+bit, orient[i], x_d1, x_d2, y_d1, y_d2);
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
    assert(descriptor_1.cols == descriptor_2.cols);
    // For each descriptor in desc2, find the most similar desciptor in desc1
    // query -> img2
    // train -> img1
    for(int idx2 = 0; idx2 < descriptor_2.rows; idx2++){
        int min_index = -1;
        int min_value = 256;
        for(int idx1 = 0; idx1 < descriptor_1.rows; idx1++){
            int hamming_distance_counter = 0;
            for(int k = 0; k < descriptor_1.cols; k++){
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
    assert(descriptor_1.cols == descriptor_2.cols);
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