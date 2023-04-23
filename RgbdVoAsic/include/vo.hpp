#include <opencv2/highgui.hpp>
#include <opencv2/calib3d.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/core/utility.hpp>

//#define MUL 65536.0  //  2^16
//#define MUL 1048576.0  //  2^20
//#define MUL 4294967296.0  //  2^32
//#define MUL 1099511627776.0  //  2^40
//#define MUL 18446744073709551616.0  //  2^64

using namespace cv;
  /** Object that contains a frame data.
   */
  struct  RgbdFrame
  {
      RgbdFrame();
      RgbdFrame(const Mat& image, const Mat& depth, const Mat& mask=Mat(), const Mat& normals=Mat(), int ID=-1);
      virtual ~RgbdFrame();

      virtual void
      release();

      int ID;
      Mat image;
      Mat depth;
      Mat mask;
      Mat normals;
      Mat cloud;
  };

  struct  OdometryFrame : public RgbdFrame
  {
    /** These constants are used to set a type of cache which has to be prepared depending on the frame role:
     * srcFrame or dstFrame (see compute method of the Odometry class). For the srcFrame and dstFrame different cache data may be required,
     * some part of a cache may be common for both frame roles.
     * @param CACHE_SRC The cache data for the srcFrame will be prepared.
     * @param CACHE_DST The cache data for the dstFrame will be prepared.
     * @param CACHE_ALL The cache data for both srcFrame and dstFrame roles will be computed.
     */
    enum
    {
      CACHE_SRC = 1, CACHE_DST = 2, CACHE_ALL = CACHE_SRC + CACHE_DST
    };

    OdometryFrame();
    OdometryFrame(const Mat& image, const Mat& depth, const Mat& mask=Mat(), const Mat& normals=Mat(), int ID=-1);

    virtual void
    release();

    void
    releasePyramids();

    Mat dI_dx;
    Mat dI_dy;
    Mat maskDepth;
    Mat maskText;
    Mat maskNormal;
  };

  class Odometry
  {
  public:

    static inline double
    DEFAULT_MIN_DEPTH()
    {
      return 0; // in meters
    }
    static inline double
    DEFAULT_MAX_DEPTH()
    {
      return 4*5000; // in meters
    }
    static inline double
    DEFAULT_MAX_DEPTH_DIFF()
    {
      return 0.07*5000; // in meters
    }
    static inline double
    DEFAULT_MAX_POINTS_PART()
    {
      //return 0.07f; // in [0, 1]
      return 1; // in [0, 1]
    }
    static inline double
    DEFAULT_MAX_TRANSLATION()
    {
      return 0.15*5000; // in meters
    }
    static inline double
    DEFAULT_MAX_ROTATION()
    {
      return 15; // in degrees
    }
    cv::Mat getCameraMatrix() const
    {
        return cameraMatrix;
    }
    Odometry();
    Odometry(const Mat& cameraMatrix, double minDepth = DEFAULT_MIN_DEPTH(), double maxDepth = DEFAULT_MAX_DEPTH(),
                 double maxDepthDiff = DEFAULT_MAX_DEPTH_DIFF(), const std::vector<int>& iterCounts = std::vector<int>(),
                 const std::vector<double>& minGradientMagnitudes = std::vector<double>(), double maxPointsPart = DEFAULT_MAX_POINTS_PART());


    void setCameraMatrix(const cv::Mat &val)
    {
        cameraMatrix = val;
    }
    double getMinDepth() const
    {
        return minDepth;
    }
    void setMinDepth(double val)
    {
        minDepth = val;
    }
    double getMaxDepth() const
    {
        return maxDepth;
    }
    void setMaxDepth(double val)
    {
        maxDepth = val;
    }
    double getMaxDepthDiff() const
    {
        return maxDepthDiff;
    }
    void setMaxDepthDiff(double val)
    {
        maxDepthDiff = val;
    }
    cv::Mat getIterationCounts() const
    {
        return iterCounts;
    }
    void setIterationCounts(const cv::Mat &val)
    {
        iterCounts = val;
    }
    cv::Mat getMinGradientMagnitudes() const
    {
        return minGradientMagnitudes;
    }
    void setMinGradientMagnitudes(const cv::Mat &val)
    {
        minGradientMagnitudes = val;
    }
    double getMaxPointsPart() const
    {
        return maxPointsPart;
    }
    void setMaxPointsPart(double val)
    {
        maxPointsPart = val;
    }
    double getMaxTranslation() const
    {
        return maxTranslation;
    }
    void setMaxTranslation(double val)
    {
        maxTranslation = val;
    }
    double getMaxRotation() const
    {
        return maxRotation;
    }
    void setMaxRotation(double val)
    {
        maxRotation = val;
    }

    bool
    compute(Ptr<OdometryFrame>& srcFrame, Ptr<OdometryFrame>& dstFrame, Mat& Rt, int& v_max, const Mat& initRt = Mat()) const;

    Size prepareFrameCache(Ptr<OdometryFrame>& frame, int cacheType) const;

  protected:

    double minDepth, maxDepth, maxDepthDiff;

    Mat iterCounts;

    Mat minGradientMagnitudes;
    double maxPointsPart;

    Mat cameraMatrix;

    double maxTranslation, maxRotation;
  };
