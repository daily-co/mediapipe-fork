# Description:
#   OpenCV libraries for video/image processing on Linux

licenses(["notice"])  # BSD license

exports_files(["LICENSE"])

cc_library(
    name = "opencv",
    hdrs = glob([
        # For OpenCV 4.x
        #"include/aarch64-linux-gnu/opencv4/opencv2/cvconfig.h",
        #"include/arm-linux-gnueabihf/opencv4/opencv2/cvconfig.h",
        #"include/x86_64-linux-gnu/opencv2/cvconfig.h",
        "include/opencv4/opencv2/**/*.h*",
    ]),
    includes = [
        # For OpenCV 4.x
        #"include/aarch64-linux-gnu/opencv4/",
        #"include/arm-linux-gnueabihf/opencv4/",
        #"include/x86_64-linux-gnu/opencv4/",
        "include/opencv4/",
    ],
    linkopts = [
        "-L/home/joao/ext/opencv_lib/lib",
        "-L/home/joao/ext/opencv_lib/lib",
        "-L/usr/local/lib",
        "-L/usr/local/lib",
        "-L/usr/local/lib",
        "-L/usr/local/lib",
        "-l:libopencv_core.a",
        "-l:libopencv_calib3d.a",
        "-l:libopencv_features2d.a",
        "-l:libopencv_highgui.a",
        "-l:libopencv_imgcodecs.a",
        "-l:libopencv_imgproc.a",
        "-l:libopencv_video.a",
        "-l:libopencv_videoio.a",
    ],
    visibility = ["//visibility:public"],
)
