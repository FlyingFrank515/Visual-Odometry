// This file is part of OpenCV project.
// It is subject to the license terms in the LICENSE file found in the top-level directory
// of this distribution and at http://opencv.org/license.html

// This code is also subject to the license terms in the LICENSE_WillowGarage.md file found in this module's directory


#include <opencv2/highgui.hpp>
#include <opencv2/calib3d.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/core/utility.hpp>
#include "vo.hpp"

#include <iostream>
#include <fstream>

using namespace std;
using namespace cv;

class MyTickMeter
{
public:
    MyTickMeter() { reset(); }
    void start() { startTime = getTickCount(); }
    void stop()
    {
        int64 time = getTickCount();
        if ( startTime == 0 )
            return;
        ++counter;
        sumTime += ( time - startTime );
        startTime = 0;
    }

    int64 getTimeTicks() const { return sumTime; }
    double getTimeSec()   const { return (double)getTimeTicks()/getTickFrequency(); }
    int64 getCounter() const { return counter; }

    void reset() { startTime = sumTime = 0; counter = 0; }
private:
    int64 counter;
    int64 sumTime;
    int64 startTime;
};

static
void writeResults( const string& filename, const vector<string>& timestamps, const vector<Mat>& Rt, const int &v_max )
{
    CV_Assert( timestamps.size() == Rt.size() );

    ofstream file( filename.c_str() );
    if( !file.is_open() )
        return;

    cout.precision(4);
    for( size_t i = 0; i < Rt.size(); i++ )
    {
        const Mat& Rt_curr = Rt[i];
        if( Rt_curr.empty() )
            continue;

        CV_Assert( Rt_curr.type() == CV_64FC1 );

        Mat R = Rt_curr(Rect(0,0,3,3)), rvec;
        Rodrigues(R, rvec);
        double alpha = norm( rvec );
        if(alpha > DBL_MIN)
            rvec = rvec / alpha;

        double cos_alpha2 = std::cos(0.5 * alpha);
        double sin_alpha2 = std::sin(0.5 * alpha);

        rvec *= sin_alpha2;

        CV_Assert( rvec.type() == CV_64FC1 );
        // timestamp tx ty tz qx qy qz qw
        file << timestamps[i] << " " << fixed
             << Rt_curr.at<double>(0,3) << " " << Rt_curr.at<double>(1,3) << " " << Rt_curr.at<double>(2,3) << " "
             << rvec.at<double>(0) << " " << rvec.at<double>(1) << " " << rvec.at<double>(2) << " " << cos_alpha2 << endl;

    }
    //file << v_max << endl;
    file.close();
}

static
void setCameraMatrixFreiburg1(double& fx, double& fy, double& cx, double& cy)
{
    fx = 517.3; fy = 516.5; cx = 318.6; cy = 255.3;
}

static
void setCameraMatrixFreiburg2(double& fx, double& fy, double& cx, double& cy)
{
    fx = 520.9; fy = 521.0; cx = 325.1; cy = 249.7;
}

/*
 * This sample helps to evaluate odometry on TUM datasets and benchmark http://vision.in.tum.de/data/datasets/rgbd-dataset.
 * At this link you can find instructions for evaluation. The sample runs some opencv odometry and saves a camera trajectory
 * to file of format that the benchmark requires. Saved file can be used for online evaluation.
 */
int main(int argc, char** argv)
{
    if(argc != 4)
    {
        cout << "Format: file_with_rgb_depth_pairs trajectory_file odometry_name [Rgbd or ICP or RgbdICP or FastICP]" << endl;
        return -1;
    }
    
    int v_max = 0;

    vector<string> timestamps;
    vector<Mat> Rts;

    const string filename = argv[1];
    ifstream file( filename.c_str() );
    if( !file.is_open() )
        return -1;

    char dlmrt = '/';
    size_t pos = filename.rfind(dlmrt);
    string dirname = pos == string::npos ? "" : filename.substr(0, pos) + dlmrt;

    const int timestampLength = 17;
    const int rgbPathLehgth = 17+8;
    const int depthPathLehgth = 17+10;

    double fx = 525.0, // default
           fy = 525.0,
           cx = 319.5,
           cy = 239.5;
    if(filename.find("fr1") != string::npos)
        setCameraMatrixFreiburg1(fx, fy, cx, cy);
    if(filename.find("fr2") != string::npos)
        setCameraMatrixFreiburg2(fx, fy, cx, cy);
    Mat cameraMatrix = Mat::eye(3,3,CV_64FC1);
    {
        cameraMatrix.at<double>(0,0) = fx;
        cameraMatrix.at<double>(1,1) = fy;
        cameraMatrix.at<double>(0,2) = cx;
        cameraMatrix.at<double>(1,2) = cy;
    }

    Ptr<OdometryFrame> frame_prev = Ptr<OdometryFrame>(new OdometryFrame()),
                           frame_curr = Ptr<OdometryFrame>(new OdometryFrame());
    Odometry odometry;
    odometry.setCameraMatrix(cameraMatrix);

    MyTickMeter gtm;
    int count = 0;
    for(int i = 0; !file.eof(); i++)
    {
        string str;
        std::getline(file, str);
        if(str.empty()) break;
        if(str.at(0) == '#') continue; /* comment */

        Mat image, depth;
        // Read one pair (rgb and depth)
        // example: 1305031453.359684 rgb/1305031453.359684.png 1305031453.374112 depth/1305031453.374112.png
        {
            string rgbFilename = str.substr(timestampLength + 1, rgbPathLehgth );
            string timestap = str.substr(0, timestampLength);
            string depthFilename = str.substr(2*timestampLength + rgbPathLehgth + 3, depthPathLehgth );

            image = imread(dirname + rgbFilename);
            depth = imread(dirname + depthFilename, -1);

            CV_Assert(!image.empty());
            CV_Assert(!depth.empty());
            CV_Assert(depth.type() == CV_16UC1);

            cout << i << " " << rgbFilename << " " << depthFilename << endl;

            // scale depth
            Mat depth_flt;
            //depth.convertTo(depth_flt, CV_32FC1, 1.f/5000.f);
            depth.convertTo(depth_flt, CV_64FC1, 1.f);
            //depth_flt.setTo(std::numeric_limits<float>::quiet_NaN(), depth == 0);
            depth = depth_flt;
            timestamps.push_back( timestap );
        }

        {
            Mat gray;
            cvtColor(image, gray, COLOR_BGR2GRAY);
            frame_curr->image = gray;
            frame_curr->depth = depth;
            
            Mat Rt;
            if(!Rts.empty())
            {
                MyTickMeter tm;
                tm.start();
                gtm.start();
                bool res = odometry.compute(frame_curr, frame_prev, Rt, v_max);
                gtm.stop();
                tm.stop();
                count++;
                cout << "Time " << tm.getTimeSec() << endl;
                if(!res)
                    Rt = Mat::eye(4,4,CV_64FC1);
            }

            if( Rts.empty() )
                Rts.push_back(Mat::eye(4,4,CV_64FC1));
            else
            {
                Mat& prevRt = *Rts.rbegin();
                cout << "Rt " << Rt << endl;
                Rts.push_back( prevRt * Rt );
            }

            if(!frame_prev.empty())
                frame_prev->release();
            std::swap(frame_prev, frame_curr);
        }
    }

    std::cout << "Average time " << gtm.getTimeSec()/count << std::endl;
    writeResults(argv[2], timestamps, Rts, v_max);
    std::cout << "v_max " << v_max << std::endl;

    return 0;
}
