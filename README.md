# Odometry_OpenCV

## Software Implementation

Folder: CPP_implementation

1. cd to CPP_implemetation

2. create the folder "build/"

    ```
    // Under VO/CPP_implementation
    mkdir build
    ```

3. cd to build folder created in 2

4. prepare the makefile related files

    ```
    // Under VO/CPP_implementation/build
    cmake ..
    ```

5. Generate the execution file

    ```
    // Under VO/CPP_implementation/build
    make
    ```

6. Run the simulation of the hardware-ORB argorithm

    ```
    // Under VO/CPP_implementation/build
    ./MYORB ../testfile/360_1.png ../testfile/360_2.png ../testfile/depth_1.png ../testfile/depth_2.png
    ```

6. After 5, the generated input data and output data (golden) would be in "CPP_implemetation/result"

## Hardware Implementation

1. Copy all files generated from software ("CPP_implemetation/result") into testfile folder.
   
    ```
    // Under VO
    mkdir Hardware_implementation/testfile // if the folder hasn't been created yet
    cp CPP_implementation/result/* Hardware_implementation/testfile/
    ```

2. cd into Hardware_implemetation/src

3. Run the simulation. The testbench would compare the output with the golden file provided and print the compared results.

   ```
   // Under VO/Hardware_implementation/src
   ./run_check
   ```

   
