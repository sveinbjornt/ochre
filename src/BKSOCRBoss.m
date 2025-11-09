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

#import "BKSOCRBoss.h"

#import "BKSTextPiece.h"

#import <Vision/Vision.h>

NS_ASSUME_NONNULL_BEGIN

enum {
    kBKSErrorOCR = 100,
};

static NSString *const kBKSAppDomain = @"BKSAppDomain";

@implementation BKSOCRBoss

- (nullable NSArray<BKSTextPiece *> *)recognizeImageURL:(NSURL *)url error:(NSError **)errorp {
    __block NSArray<BKSTextPiece *> *pieces = nil;
    __block NSError *__autoreleasing _Nullable *error1p = errorp;
    __weak typeof(self) weakSelf = self;
    VNRecognizeTextRequest *textRequest =
        [[VNRecognizeTextRequest alloc] initWithCompletionHandler:^(VNRequest *request, NSError *error) {
          [weakSelf handleTextRequst:request
                               error:error
                        continuation:^(NSArray *_Nullable idx, NSError *_Nullable error) {
                          pieces = idx;
                          if (error && error1p) {
                              *error1p = error;
                          }
                        }];
        }];
    VNImageRequestHandler *handler = nil;
    if (textRequest) {
        handler = [[VNImageRequestHandler alloc] initWithURL:url options:@{}];
        [handler performRequests:@[ textRequest ] error:errorp];
    }
    if (nil == handler && errorp) {
        NSString *desc = @"Couldn't allocate handler";
        NSError *err = [NSError errorWithDomain:kBKSAppDomain
                                           code:kBKSErrorOCR
                                       userInfo:@{NSLocalizedDescriptionKey : desc}];
        *errorp = err;
    }
    return pieces;
}

- (void)handleTextRequst:(VNRequest *)request
                   error:(NSError *)error
            continuation:(void (^)(NSArray *_Nullable idx, NSError *_Nullable error))continuation
    API_AVAILABLE(macos(10.15)) {
    if (error) {
        continuation(nil, error);
    } else if ([request isKindOfClass:[VNRecognizeTextRequest class]]) {
        VNRecognizeTextRequest *textRequests = (VNRecognizeTextRequest *)request;
        NSMutableArray<BKSTextPiece *> *pieces = [NSMutableArray array];
        NSArray *results = textRequests.results;
        for (id rawResult in results) {
            if ([rawResult isKindOfClass:[VNRecognizedTextObservation class]]) {
                VNRecognizedTextObservation *textO = (VNRecognizedTextObservation *)rawResult;
                NSArray<VNRecognizedText *> *text1 = [textO topCandidates:1];
                if (text1.count) {
                    BKSTextPiece *textPiece = [[BKSTextPiece alloc] init];
                    textPiece.text = text1.firstObject.string;
                    textPiece.topLeft = textO.topLeft;
                    textPiece.topRight = textO.topRight;
                    textPiece.bottomLeft = textO.bottomLeft;
                    textPiece.bottomRight = textO.bottomRight;
                    [pieces addObject:textPiece];
                }
            } else {
                NSLog(@"E %@", rawResult);
            }
        }
        continuation(pieces, nil);
    } else {
        NSString *desc = @"Unrecognized request";
        NSError *err = [NSError errorWithDomain:kBKSAppDomain
                                           code:kBKSErrorOCR
                                       userInfo:@{NSLocalizedDescriptionKey : desc}];
        continuation(nil, err);
    }
}

@end

NS_ASSUME_NONNULL_END
