cmake_minimum_required(VERSION 2.8)

project(liyang-odometry)

#set(CMAKE_BUILD_TYPE "Debug")
set(CMAKE_BUILD_TYPE "Release")
#set(CMAKE_CXX_FLAGS_DEBUG "$ENV{CXXFLAGS} -O0 -Wall -g -ggdb")

#c++11
include(CheckCXXCompilerFlag)
CHECK_CXX_COMPILER_FLAG("-std=c++11" COMPILER_SUPPORTS_CXX11)
CHECK_CXX_COMPILER_FLAG("-std=c++0x" COMPILER_SUPPORTS_CXX0X)
if(COMPILER_SUPPORTS_CXX11)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")
elseif(COMPILER_SUPPORTS_CXX0X)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++0x")
else()
    message(STATUS "The compiler ${CMAKE_CXX_COMPILER} has no C++11 support. Please use a different C++ compiler.")
endif()

message(STATUS "Build type: ${CMAKE_BUILD_TYPE}")

#opencv
#find_package(OpenCV 3.1)
find_package(OpenCV REQUIRED)
if (OpenCV_FOUND)
	message("Find your opencv succesfully")
else()
	message("Cannot find your opencv, please specifiy your opencv path")
	set(OpenCV_INCLUDE_DIRS /home/darrenl/library/opencv/install/include)
	set(OpenCV_LIBS opencv_core opencv_highgui opencv_imgproc opencv_imgcodecs opencv_calib3d)
	link_directories(/home/darrenl/library/opencv/install/lib)
endif()

file(GLOB TARGET_SRC
     #src/*.cpp
     src/main.cpp
     src/vo.cpp
     src/MYORB.cpp
     src/Gaussian_pattern.cpp
)

#include_directories(${OpenCV_INCLUDE_DIRS} include)
set(GMP_DIRS ~/liyang_lib/include)
include_directories(${GMP_DIRS} ${OpenCV_INCLUDE_DIRS} include)
link_directories("~/liyang_lib/lib/" )

add_executable(liyang-odometry ${TARGET_SRC})
#target_link_libraries (liyang-odometry ${OpenCV_LIBS})
target_link_libraries (liyang-odometry ${OpenCV_LIBS} "~/liyang_lib/lib/libgmp.so.10.4.1" "~/liyang_lib/lib/libgmpxx.so.4.6.1")
