cmake_minimum_required( VERSION 2.8 )
project( MYORB )

set( CMAKE_BUILD_TYPE "Release" )
set( CMAKE_CXX_FLAGS "-std=c++11 -O3" )

find_package( OpenCV 4.5 REQUIRED )

include_directories( 
    ${OpenCV_INCLUDE_DIRS} 
    ${G2O_INCLUDE_DIRS}
    ${CSPARSE_INCLUDE_DIR}
    "/usr/include/eigen3/"
)

file(GLOB TARGET_SRC
    src/*.cpp
    src/*.h
)


add_executable( MYORB ${TARGET_SRC})
target_link_libraries( MYORB ${OpenCV_LIBS} )

