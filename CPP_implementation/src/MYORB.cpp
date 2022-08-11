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

MYORB::MYORB( int N, int t , int op, int st, int et, int kn, int mt, int l, float sf, Mat img1, Mat img2, bool D = false, bool F = false, bool T = false){
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

    // bool 
    DISPLAY = D;
    FIXED = F;
    TESTBENCH = T; 

    // outfile
    outfile_name = "../result/result.txt";
    outfile.open(outfile_name, ios::out);

    // result
    if(TESTBENCH){
        result_test.open("../result/result_test.txt", ios::out);
        result_NMS.open("../result/result_NMS.txt", ios::out);
        result_coordinates.open("../result/result_coordinates.txt", ios::out);
        result_mx.open("../result/result_mx.txt", ios::out);
        result_my.open("../result/result_my.txt", ios::out);
        result_score.open("../result/result_score.txt", ios::out);
        read.open("../result/read.txt", ios::out);
        pixel_in.open("../result/pixel_in.txt", ios::out);
        pixel_smooth.open("../result/pixel_smooth.txt", ios::out);
    }

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

    // sort(keylist_1.begin(), keylist_1.end(), response_comparator);
    // while (keylist_1.size() > keypoints_num) keylist_1.pop_back();
    // sort(keylist_2.begin(), keylist_2.end(), response_comparator);
    // while (keylist_2.size() > keypoints_num) keylist_2.pop_back();
    FAST_sort();
    cout << keylist_1.size() << "  " << keylist_2.size() << endl;
    

    // vector<KeyPoint> temp = keylist_1;
    // sort(temp.begin(), temp.end(), response_comparator);
    // while (temp.size() > keypoints_num) temp.pop_back();
    // min_thres = int(temp[-1].response);
    
    // smoothing the image
    // for (int i = -2; i < 3; i++){
    //     for (int j = -2; j < 3; j++){
    //         cout << int(img_1.at<uchar>(97+i, 231+j)) << " ";
    //     }
    //     cout << endl;
    // }
    BRIEF_smoothing();

    // Create descriptor matrix and use BRIEF descriptor
    // cout << "Produce descriptor..." << endl;
    descriptor_1 = Mat(keylist_1.size(), 32, CV_8UC1, Scalar(0));
    descriptor_2 = Mat(keylist_2.size(), 32, CV_8UC1, Scalar(0));
    BRIEF_descriptor(1);
    BRIEF_descriptor(2);
    // BRIEF_descriptor_old();

    // if(TESTBENCH){
    //     for (int i = 0; i < keylist_1.size(); i++){
    //         read << hex << setw(3) << setfill('0') <<  int(keylist_1[i].pt.x)  << " " << setw(3) << setfill('0') << int(keylist_1[i].pt.y) << " ";
    //         read << hex << setw(2) << int(keylist_1[i].response) << " ";
    //         for (int j = 0; j < 32; j++){
    //             read << hex << setw(2) << setfill('0') << int(descriptor_1.at<uchar>(i, 31-j));
    //         }
    //         read << endl;
    //     }
    // }


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

    if(1){
        for(int i = 0; i < matches.size(); i++){
            cout << "(" << hex << setw(3) << setfill('0') << int(keylist_1[matches[i].trainIdx].pt.x) << ", " << hex << setw(3) << setfill('0') << int(keylist_1[matches[i].trainIdx].pt.y) << ")";
            cout << " <---> ";
            cout << "(" << hex << setw(3) << setfill('0') << int(keylist_2[matches[i].queryIdx].pt.x) << ", " << hex << setw(3) << setfill('0') << int(keylist_2[matches[i].queryIdx].pt.y) << ") ";
            cout << matches[i].distance << endl;
        }
    }

    if(DISPLAY){
        DISPLAY_matches();
        for(int i = 0; i < good_matches.size(); i++){
            read << "(" << hex << setw(3) << setfill('0') << int(keylist_1[good_matches[i].trainIdx].pt.x) << ", " << hex << setw(3) << setfill('0') << int(keylist_1[good_matches[i].trainIdx].pt.y) << ")";
            read << " <---> ";
            read << "(" << hex << setw(3) << setfill('0') << int(keylist_2[good_matches[i].queryIdx].pt.x) << ", " << hex << setw(3) << setfill('0') << int(keylist_2[good_matches[i].queryIdx].pt.y) << ")" << endl;
        }
    }

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
    // cout << "all matching pair" << endl;
    drawMatches(img_2, keylist_2, img_1, keylist_1, matches, img_match);
    imshow ( "all matching pair", img_match );

    Mat img_goodmatch;
    // cout << "optimized matching pair" << endl;
    drawMatches(img_2, keylist_2, img_1, keylist_1, good_matches, img_goodmatch);
    imshow ( "optimized matching pair", img_goodmatch );
    waitKey(0);
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
        Mat reserved(img.rows, img.cols, CV_8UC1, Scalar(0));
        Mat cos(img.rows, img.cols, CV_32SC1, Scalar(0));
        Mat sin(img.rows, img.cols, CV_32SC1, Scalar(0));
        Mat orient(img.rows, img.cols, CV_64FC1, Scalar(0));

        vector<KeyPoint> candidate;

        vector<int> p(16, 0);

        for (int i = 0; i < img.rows; i++) {
            for (int j = 0; j < img.cols; j++) {
                int score_temp = 0;
                key.at<uchar>(i, j) = 0;
                score.at<uchar>(i, j) = 0;
                orient.at<float>(i, j) = 0;
                cos.at<int>(i, j) = 0;
                sin.at<int>(i, j) = 0;

                if (i < 4 || j < 4 || i > img.rows - 4 || j > img.cols - 4)
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
                        // orient.at<uchar>(i, j) = k;
                        score_temp = local_threshold;
                    }
                }
                // score.at<uchar>(i, j) = score_temp == 0 ? 0 : score_temp - 1;
                score.at<uchar>(i, j) = score_temp;

                // Orientation
                int x_sum = 0;
                int y_sum = 0;
                
                for(int x = -3; x < 4; x++ ){
                    for(int y = -3; y < 4; y++){
                        // if(i == 34 && j== 137) cout << (int)img.at<uchar>(i+y, j+x) << endl;
                        x_sum += x*(int)img.at<uchar>(i+y, j+x);
                        y_sum += y*(int)img.at<uchar>(i+y, j+x);
                    }
                }

                orient.at<float>(i, j) = atan2(y_sum, x_sum);
                unsigned int sum2 = (x_sum*x_sum + y_sum*y_sum);
                int denominator = int(sqrt(sum2));
                int x_sign = (x_sum < 0) ? -1 : 1;
                int y_sign = (y_sum < 0) ? -1 : 1;

                // denominator = int(denominator / 32);
                // cout << denominator << " " << denominator_2 << endl;

                if(denominator != 0){
                    cos.at<int>(i, j) = int(1024 * abs(x_sum) / denominator );
                    sin.at<int>(i, j) = int(1024 * abs(y_sum) / denominator );
                }
                else {
                    cos.at<int>(i, j) = int(1024 * abs(x_sum));
                    sin.at<int>(i, j) = int(1024 * abs(y_sum));
                }
                cos.at<int>(i, j) = cos.at<int>(i, j) * x_sign;
                sin.at<int>(i, j) = sin.at<int>(i, j) * y_sign;
            }
        }

        // if(level == 0 && option == 1){
        //     for (int i = 0; i < img.rows; i++) {
        //         for (int j = 0; j < img.cols; j++) {
        //             result_test << int(key.at<uchar>(i, j)) << endl;
        //         }
        //     }
        // }
        
        // Non-maximal suppression
        // cout << "test" << endl;
        for (int i = 0; i < img.rows; i++) {
            for (int j = 0; j < img.cols; j++) {
                if (i < FAST_edgethreshold || j < FAST_edgethreshold || i > img.rows - FAST_edgethreshold || j > img.cols - FAST_edgethreshold){
                    reserved.at<uchar>(i, j) = 0;
                    continue;
                }
                // if(i == 37 && j == 136){
                //     cout << hex << int(score.at<uchar>(i-1, j-1)) << " ";
                //     cout << hex << int(score.at<uchar>(i-1, j)) << " ";
                //     cout << hex << int(score.at<uchar>(i-1, j+1)) << " ";
                //     cout << hex << int(score.at<uchar>(i, j-1)) << " ";
                //     cout << hex << int(score.at<uchar>(i, j)) << " ";
                //     cout << hex << int(score.at<uchar>(i, j+1)) << " ";
                //     cout << hex << int(score.at<uchar>(i+1, j-1)) << " ";
                //     cout << hex << int(score.at<uchar>(i+1, j)) << " ";
                //     cout << hex << int(score.at<uchar>(i+1, j+1)) << " " << endl;
                //     bool a = int(score.at<uchar>(i, j)) > int(score.at<uchar>(i-1, j+1));
                //     bool b = int(key.at<uchar>(i-1, j+1)) == 0;
                //     cout << a <<" "<< b<<" " << (a || b) << endl;
                // }
                if (key.at<uchar>(i, j) == 1 // keypoint candidate
                    && (int(score.at<uchar>(i, j)) > int(score.at<uchar>(i-1, j-1)) || int(key.at<uchar>(i-1, j-1)) == 0)
                    && (int(score.at<uchar>(i, j)) > int(score.at<uchar>(i+0, j-1)) || int(key.at<uchar>(i+0, j-1)) == 0)
                    && (int(score.at<uchar>(i, j)) > int(score.at<uchar>(i+1, j-1)) || int(key.at<uchar>(i+1, j-1)) == 0)
                    && (int(score.at<uchar>(i, j)) > int(score.at<uchar>(i-1, j+0)) || int(key.at<uchar>(i-1, j+0)) == 0)
                    && (int(score.at<uchar>(i, j)) > int(score.at<uchar>(i+1, j+0)) || int(key.at<uchar>(i+1, j+0)) == 0)
                    && (int(score.at<uchar>(i, j)) > int(score.at<uchar>(i-1, j+1)) || int(key.at<uchar>(i-1, j+1)) == 0)
                    && (int(score.at<uchar>(i, j)) > int(score.at<uchar>(i+0, j+1)) || int(key.at<uchar>(i+0, j+1)) == 0)
                    && (int(score.at<uchar>(i, j)) > int(score.at<uchar>(i+1, j+1)) || int(key.at<uchar>(i+1, j+1)) == 0)
                    ){
                    reserved.at<uchar>(i, j) = 1;
                    // Remember to convert the coordinates back to original coordinates
                    int power = int(pow(2, level));
                    // cout << "add keypoints: (" << j*power << ", " << i*power << ")" << endl;
                    KeyPoint temp = KeyPoint(Point2f(j*power, i*power), 1, orient.at<float>(i, j), int(score.at<uchar>(i, j)), 0, -1);
                    // cout << j << " " << i << " " << temp.pt.x << " " << temp.pt.y << endl;
                    // cout << cos << " " << sin << endl;
                    if(option == 1){
                        // if(keylist_1.size() < keypoints_num)
                        keylist_1.push_back(temp);
                        cos_1.push_back(cos.at<int>(i, j));
                        sin_1.push_back(sin.at<int>(i, j));
                    
                    }
                    else if(option == 2){
                        // if(keylist_2.size() < keypoints_num)
                        keylist_2.push_back(temp);
                        cos_2.push_back(cos.at<int>(i, j));
                        sin_2.push_back(sin.at<int>(i, j));

                    }
                }
            }
        }

        // cout << int(key.at<uchar>(37, 136)) << endl;

        // output to files (for testbench usage)
        if(level == 0 && option == 2){
            for (int i = 0; i < img.rows; i++) {
                for (int j = 0; j < img.cols; j++) {
                    // result_NMS << int(reserved.at<uchar>(i, j)) << endl;
                    // result_coordinates << hex << i << " " << j << endl;
                    // result_score << hex << int(score.at<uchar>(i, j)) << endl;
                    // result_mx << hex << mx.at<int>(i, j) << endl;
                    // result_my << hex << my.at<int>(i, j) << endl;
                    pixel_in << hex << (int)img.at<uchar>(i, j) << endl;
                    
        //             if(int(reserved.at<uchar>(i, j)) == 1){
        //                 read << hex << setw(3) << setfill('0') <<  j  << " " << setw(3) << setfill('0') << i << " ";
        //                 read << setw(2) << int(score.at<uchar>(i, j)) << " ";
        //                 int x = mx.at<int>(i, j);
        //                 int y = my.at<int>(i, j);
        //                 if(j == 137 && i == 34){
        //                     cout << "haha" << endl;
        //                     cout << x << " " << y << endl;
        //                 }

        //                 read << dec << 1024*x/(int)sqrt(x*x+y*y) << " ";
        //                 read << dec << 1024*y/(int)sqrt(x*x+y*y) << " ";
        //                 read << endl;
        //             }
                }
            }
        }
    }
}

void MYORB::FAST_sort(){
    for(int i = 0; i < keylist_1.size(); i++){
        KeyPoint target = keylist_1[i];
        for(int j = 0; j < i; j++){
            if(target.response > keylist_1[j].response){
                // swap
                KeyPoint temp = target;
                target = keylist_1[j];
                keylist_1[j] = temp;

                int cos_temp = cos_1[i];
                cos_1[i] = cos_1[j];
                cos_1[j] = cos_temp;

                int sin_temp = sin_1[i];
                sin_1[i] = sin_1[j];
                sin_1[j] = sin_temp;
            }
        }
        keylist_1[i] = target;
    }
    for(int i = 0; i < keylist_2.size(); i++){
        KeyPoint target = keylist_2[i];
        for(int j = 0; j < i; j++){
            if(target.response > keylist_2[j].response){
                // swap
                KeyPoint temp = target;
                target = keylist_2[j];
                keylist_2[j] = temp;

                int cos_temp = cos_2[i];
                cos_2[i] = cos_2[j];
                cos_2[j] = cos_temp;
                
                int sin_temp = sin_2[i];
                sin_2[i] = sin_2[j];
                sin_2[j] = sin_temp;
            }
        }
        keylist_2[i] = target;
    }
    
}

void MYORB::BRIEF_smoothing(){
    Mat_<float> kernel(5, 5);
    kernel << 1, 4, 6, 4, 1, 4, 16, 24, 16, 4, 6, 24, 36, 24, 6, 4, 16, 24, 16, 4, 1, 4, 6, 4, 1;
    kernel = kernel/256;
    // cout << kernel << endl;

    filter2D(img_1, smth_1, -1, kernel);
    filter2D(img_2, smth_2, -1, kernel);


    if(TESTBENCH){
        for (int i = 0; i < smth_1.rows; i++) {
            for (int j = 0; j < smth_1.cols; j++) {
                pixel_smooth << hex << (int)smth_1.at<uchar>(i, j) << endl;
            }
        }
    }
}


void MYORB::BRIEF_descriptor(int option){
    Mat img;
    vector<KeyPoint> keylist;
    vector<int> cos, sin;
    if(option == 1){
        img = smth_1;
        keylist = keylist_1;
        cos = cos_1;
        sin = sin_1;
    }
    else if(option == 2){
        img = smth_2;
        keylist = keylist_2;
        cos = cos_2;
        sin = sin_2;
    }
    // for(int i = 0; i < keylist.size(); i++){
    //     cout << cos[i] << " " << sin[i] << endl;
    // }
    // assert(orient.size() == keylist.size());
    for(int i = 0; i < keylist.size(); i++){
        int x = keylist[i].pt.x;
        int y = keylist[i].pt.y;
        
        if(TESTBENCH){
            // result_test << cos[i] << " " << sin[i] << endl;
            result_test << hex << y << " " << x << " " << int(img.at<uchar>(y, x)) << dec << " " << cos[i] << " " << sin[i] << endl;
            for(int ky = -15; ky < 16; ky++){
                for(int kx = -15; kx < 16; kx++){
                    result_test << hex << setw(3) << int(img.at<uchar>(y+ky, x+kx)) << " ";
                }
                result_test << dec << endl;
            }
        }
        for(int ic = 0; ic < 32; ic++){
            uchar desc = 0;
            for(int bit = 0; bit < 8; bit++){
                int x_d1, x_d2, y_d1, y_d2;
                BRIEF_pattern_LUT(ic*8+bit, float(keylist[i].angle), cos[i], sin[i], x_d1, x_d2, y_d1, y_d2);
                if(TESTBENCH){
                    // result_test  << x_d1+15 << " " << y_d1+15 << " " << x_d2+15 << " " << y_d2+15 << " | ";
                    result_test  << x_d1 << " " << y_d1 << " " << x_d2 << " " << y_d2 << " | ";
                }
                // BRIEF_pattern_LUT(ic*8+bit, 0, x_d1, x_d2, y_d1, y_d2);
                bool result = int(img.at<uchar>(y+y_d1, x+x_d1)) > int(img.at<uchar>(y+y_d2, x+x_d2));
                if(TESTBENCH){
                    result_test  << int(img.at<uchar>(y+y_d1, x+x_d1)) << " " << int(img.at<uchar>(y+y_d2, x+x_d2)) << endl;
                }
                // cout << result;
                desc += int(result) << bit;
                // cout << endl;
            }

            if(option == 1) descriptor_1.at<uchar>(i, ic) = desc;
            else if(option == 2) descriptor_2.at<uchar>(i, ic) = desc;
        }
        if(TESTBENCH) result_test << endl;

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
        int min_index = 0;
        int min_value = 256;
        int min_dist = 999;
        // ----
        // read << "coor(" << keylist_2[idx2].pt.x << ", " << keylist_2[idx2].pt.y <<  ")";
        // for (int j = 0; j < 32; j++){
        //     read << hex << setw(2) << setfill('0') << int(descriptor_2.at<uchar>(idx2, 31-j));
        // }
        // read << endl;
        // ----
        for(int idx1 = 0; idx1 < descriptor_1.rows; idx1++){
            int hamming_distance_counter = 0;

            for(int k = 0; k < descriptor_2.cols; k++){
                hamming_distance_counter += MATCH_Hamming_distance(descriptor_2.at<uchar>(idx2, k), descriptor_1.at<uchar>(idx1, k));
            }
            // if(idx2 == 6){
            //     cout << "min_value = " << min_value << " ";
            //     cout << "present_hamming = " << hamming_distance_counter << endl;
            // }
            // ----
            // read << "comparing (" << keylist_1[idx1].pt.x << ", " << keylist_1[idx1].pt.y <<  ")" << " hamming = " << dec << hamming_distance_counter << " ";
            // ----
            if(hamming_distance_counter <= min_value){
                min_index = idx1;
                min_value = hamming_distance_counter;
                // read << "replaced" << endl;
            }
            // else read << "keep" << endl;
            
            // else if(hamming_distance_counter == min_value){
            //     int dist = abs(keylist_1[idx1].pt.x - keylist_2[idx2].pt.x) + abs(keylist_1[idx1].pt.y - keylist_2[idx2].pt.y);
            //     if(dist < min_dist){
            //         min_index = idx1;
            //         min_value = hamming_distance_counter;
            //         min_dist = dist;
            //     }
            // }
        }
        // constructor: query -> train -> distance
        //              img2     img1
        DMatch temp(idx2, min_index, min_value);
        matches.push_back(temp);
    }
}

void MYORB::MATCH_optimization(){
    for (int i = 0; i < matches.size(); i++) {
        if (matches[i].distance <= MATCH_threshold) {
            good_matches.push_back(matches[i]);
        }
    }

    // double min_dist=10000, max_dist=0;
    // for ( int i = 0; i < matches.size(); i++ )
    // {
    //     double dist = matches[i].distance;
    //     if ( dist < min_dist ) min_dist = dist;
    //     if ( dist > max_dist ) max_dist = dist;
    // }

    // int thres =  max ( 2*min_dist, 30.0 );
    // cout << thres << endl;
    // for ( int i = 0; i < matches.size(); i++ ){
    //     if ( matches[i].distance <= thres ){
    //         good_matches.push_back ( matches[i] );
    //     }
    // }
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