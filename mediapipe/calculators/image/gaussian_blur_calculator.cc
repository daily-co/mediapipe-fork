#include "mediapipe/framework/calculator_framework.h"
#include "mediapipe/framework/calculator_options.pb.h"
#include "mediapipe/framework/formats/image_format.pb.h"
#include "mediapipe/framework/formats/image_frame.h"
#include "mediapipe/framework/formats/image_frame_opencv.h"
#include "mediapipe/framework/port/logging.h"
#include "mediapipe/framework/port/opencv_core_inc.h"
#include "mediapipe/framework/port/opencv_imgproc_inc.h"
#include "mediapipe/framework/port/status.h"
#include "mediapipe/framework/port/vector.h"


#if !MEDIAPIPE_DISABLE_GPU
#include "mediapipe/gpu/gl_calculator_helper.h"
#include "mediapipe/gpu/gl_simple_shaders.h"
#include "mediapipe/gpu/shader_util.h"
#endif  // !MEDIAPIPE_DISABLE_GPU


namespace mediapipe {

// Name of the calculator.
constexpr char kGaussianBlurCalculator[] = "GaussianBlurCalculator";
// Input streams.
constexpr char kImageFrameTag[] = "IMAGE";
constexpr char kSegmentationMapTag[] = "SEGMENTATION_MAP";
// Output stream.
constexpr char kBlurredImageFrameTag[] = "BLURRED_IMAGE";



// A calculator for applying a Gaussian blur to an image.
//
// Inputs:
//  IMAGE: ImageFrame containing input image - Grayscale or RGB only.
//  SEGMENTATION_MAP: ImageFrame containing segmentation map - Grayscale only.
//
//
// Output:
//   One of the following two tags:
//   BLURRED_IMAGE:    A blurred image
//

// GaussianBlurCalculator class definition.
class GaussianBlurCalculator : public CalculatorBase {

 public:

  // Contract
  static absl::Status GetContract(CalculatorContract* cc) {
    cc->Inputs().Tag(kImageFrameTag).Set<ImageFrame>();
    cc->Inputs().Tag(kSegmentationMapTag).Set<ImageFrame>();
    cc->Outputs().Tag(kBlurredImageFrameTag).Set<ImageFrame>();
    return absl::OkStatus();
  }

  // Process
  absl::Status Process(CalculatorContext* cc) {

    // Get input image and segmentation map.
    const auto& input_image = cc->Inputs().Tag(kImageFrameTag).Get<ImageFrame>();
    const auto& segmentation_map = cc->Inputs().Tag(kSegmentationMapTag).Get<ImageFrame>();

    // Convert input image and segmentation map to OpenCV Mat format.
    cv::Mat input_mat = formats::MatView(&input_image);
    cv::Mat segmentation_mat = formats::MatView(&segmentation_map);

    // Define kernel size and standard deviation for Gaussian blur.
    const int kernel_size = 11;
    const double sigma = 7;

    // Apply Gaussian blur to input image based on segmentation map.
    cv::Mat blurred_mat;
 
    // cv::GaussianBlur(input_mat, blurred_mat, cv::Size(kernel_size, kernel_size), sigma, sigma, cv::BORDER_DEFAULT);
    cv::GaussianBlur(input_mat, blurred_mat, cv::Size(kernel_size, kernel_size), sigma);
    cv::Mat blurred_masked_mat;
    blurred_mat.copyTo(blurred_masked_mat, segmentation_mat);

    // Convert blurred image back to ImageFrame format.
    auto blurred_image = absl::make_unique<ImageFrame>(
        input_image.Format(), blurred_masked_mat.cols, blurred_masked_mat.rows, ImageFrame::kDefaultAlignmentBoundary);
    // cv::MatView(&*blurred_image) = blurred_masked_mat;

    // Send blurred image to output stream.
    cc->Outputs().Tag(kBlurredImageFrameTag).Add(blurred_image.release(), cc->InputTimestamp());

    return absl::OkStatus();
  }
};

// Register the GaussianBlurCalculator.
REGISTER_CALCULATOR(GaussianBlurCalculator);

}  // namespace mediapipe
