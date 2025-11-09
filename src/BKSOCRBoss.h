/*
    ochre - macOS Optical Character Recognition via the command line

    Copyright (c) 2022-2025 Sveinbjorn Thordarson <sveinbjorn@sveinbjorn.org>
    Adapted from code Copyright (c) 2020 David Phillip Oster.

    Redistribution and use in source and binary forms, with or without modification,
    are permitted provided that the following conditions are met:

    1. Redistributions of source code must retain the above copyright notice, this
    list of conditions and the following disclaimer.

    2. Redistributions in binary form must reproduce the above copyright notice, this
    list of conditions and the following disclaimer in the documentation and/or other
    materials provided with the distribution.

    3. Neither the name of the copyright holder nor the names of its contributors may
    be used to endorse or promote products derived from this software without specific
    prior written permission.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
    ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
    WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
    IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
    INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
    NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
    PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
    WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
    ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
    POSSIBILITY OF SUCH DAMAGE.
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
