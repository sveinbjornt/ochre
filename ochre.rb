class Ochre < Formula
  desc "Native macOS optical character recognition via the command line."
  homepage "https://github.com/sveinbjornt/ochre"
  url "https://github.com/sveinbjornt/ochre/archive/refs/tags/0.1.0.tar.gz"
  sha256 ""
  license "BSD-3-Clause"

  depends_on xcode: ["10.0", :build]
  depends_on macos: :catalina

  def install
    system "xcodebuild", "-project", "ochre.xcodeproj",
           "-target", "ochre",
           "-configuration", "Release",
           "SYMROOT=build",
           "CODE_SIGN_IDENTITY=",
           "CODE_SIGNING_REQUIRED=NO",
           "CODE_SIGNING_ALLOWED=NO"
    
    bin.install "build/Release/ochre"
    man1.install "ochre.1"
  end

  test do
    system "bin/\"ochre\"", "--version"
  end
end
