/*
    ocr - macOS Optical Character Recognition via the command line

    Copyright (c) 2022 Sveinbjorn Thordarson <sveinbjorn@sveinbjorn.org>

    Adapted from code Copyright © 2020 David Phillip Oster.
 
    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@class BKSTextPiece;

@interface BKSOCRBoss : NSObject

/// OCR the image on the current thread returning an array of BKSTextPieces else nil.
/// Run this on a separate thread!
///
/// requires macOS 10.15
///
/// @param url The image, in a file to OCR
/// @param error Assigned to if an error occurred
/// @return The array of recognized pieces else nil.
- (nullable NSArray<BKSTextPiece *> *)recognizeImageURL:(NSURL *)url
                                                  error:(NSError *__autoreleasing  _Nullable *)error API_AVAILABLE(macos(10.15));

@end

NS_ASSUME_NONNULL_END
