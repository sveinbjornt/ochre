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
  __block NSError *__autoreleasing  _Nullable *error1p = errorp;
  __weak typeof(self) weakSelf = self;
  VNRecognizeTextRequest *textRequest =
      [[VNRecognizeTextRequest alloc] initWithCompletionHandler:^(VNRequest *request, NSError *error) {
    [weakSelf handleTextRequst:request error:error continuation:
      ^(NSArray *_Nullable idx, NSError *_Nullable error){
        pieces = idx;
        if (error && error1p) {
          *error1p = error;
        }
      }];
  }];
  VNImageRequestHandler *handler  = nil;
  if (textRequest) {
    handler = [[VNImageRequestHandler alloc] initWithURL:url options:@{}];
    [handler performRequests:@[textRequest] error:errorp];
  }
  if (nil == handler && errorp) {
    NSString *desc = @"Couldn't allocate handler";
    NSError *err = [NSError errorWithDomain:kBKSAppDomain code:kBKSErrorOCR userInfo:@{NSLocalizedDescriptionKey : desc}];
    *errorp = err;
  }
  return pieces;
}

- (void)handleTextRequst:(VNRequest *)request
                   error:(NSError *)error
            continuation:(void (^)(NSArray *_Nullable idx, NSError *_Nullable error))continuation  API_AVAILABLE(macos(10.15)){
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
    NSError *err = [NSError errorWithDomain:kBKSAppDomain code:kBKSErrorOCR userInfo:@{NSLocalizedDescriptionKey : desc}];
    continuation(nil, err);
   }
}

@end

NS_ASSUME_NONNULL_END
