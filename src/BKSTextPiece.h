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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Use to hold one line of text returned from the BKSOCRBoss :
/// Coordinate system is in a ratio to the image size. Y=0 is the bottom left.
@interface BKSTextPiece : NSObject
@property NSString *text;
@property(nonatomic) CGPoint topLeft;
@property(nonatomic) CGPoint topRight;
@property(nonatomic) CGPoint bottomLeft;
@property(nonatomic) CGPoint bottomRight;

@end

NS_ASSUME_NONNULL_END
