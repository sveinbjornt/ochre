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

#import "BKSTextPiece.h"

@implementation BKSTextPiece

- (NSString *)description {
    CGFloat x = (self.topLeft.x + self.topRight.x + self.bottomLeft.x + self.bottomRight.x)/4.0;
    CGFloat y = (self.topLeft.y + self.topRight.y + self.bottomLeft.y + self.bottomRight.y)/4.0;
    return [NSString stringWithFormat:@"%3.1f %3.1f %@", x, y, self.text];
}

@end
