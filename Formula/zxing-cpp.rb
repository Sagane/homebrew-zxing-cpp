# Homebrew Formula for zxing-cpp
# Usage:
#   1. Create a GitHub repo: homebrew-zxing (or homebrew-<name>)
#   2. Copy this file to: Formula/zxing-cpp.rb
#   3. Push to GitHub
#   4. Users install with:
#      brew tap YOUR-USERNAME/zxing
#      brew install zxing-cpp

class ZxingCpp < Formula
  desc "Multi-format 1D/2D barcode image processing library"
  homepage "https://github.com/zxing-cpp/zxing-cpp"
  url "https://github.com/zxing-cpp/zxing-cpp/archive/refs/tags/v2.2.1.tar.gz"
  sha256 "02078ae15f19f9d423a441f205b1d1bee32349ddda7467e2c84e8f08876f8635"
  license "Apache-2.0"
  head "https://github.com/zxing-cpp/zxing-cpp.git", branch: "master"

  depends_on "cmake" => :build

  def install
    # Configure with CMake
    system "cmake", "-S", ".", "-B", "build",
                    "-DCMAKE_BUILD_TYPE=Release",
                    "-DCMAKE_CXX_STANDARD=20",
                    "-DBUILD_WRITERS=ON",
                    "-DBUILD_READERS=ON",
                    "-DBUILD_EXAMPLES=OFF",
                    "-DBUILD_BLACKBOX_TESTS=OFF",
                    "-DBUILD_UNIT_TESTS=OFF",
                    "-DBUILD_PYTHON_MODULE=OFF",
                    *std_cmake_args

    # Build
    system "cmake", "--build", "build"

    # Install
    system "cmake", "--install", "build"
  end

  test do
    # Test 1: Verify headers are installed
    assert_path_exists include/"ZXing/ReadBarcode.h"

    # Test 2: Compile a simple test program
    (testpath/"test.cpp").write <<~EOS
      #include <ZXing/ReadBarcode.h>
      #include <ZXing/BarcodeFormat.h>
      using namespace ZXing;
      int main() {
        BarcodeFormat format = BarcodeFormat::DataMatrix;
        return 0;
      }
    EOS

    system ENV.cxx, "test.cpp",
                    "-std=c++20",
                    "-I#{include}",
                    "-L#{lib}",
                    "-lZXing",
                    "-o", "test"

    # Test 3: Run the compiled program
    system "./test"

    # Test 4: Verify pkg-config works
    assert_match version.to_s, shell_output("pkg-config --modversion zxing").strip
  end
end
