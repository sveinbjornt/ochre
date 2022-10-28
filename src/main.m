/*
    ocr - macOS Optical Character Recognition via the command line

    Copyright (c) 2022 Sveinbjorn Thordarson <sveinbjorn@sveinbjorn.org>

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
#import <getopt.h>

#import "BKSTextPiece.h"
#import "BKSOCRBoss.h"

static BOOL hasInitialLowercase(NSString *s) {
  if (s.length) {
    unichar c = [s characterAtIndex:0];
    return islower(c);
  }
  return NO;
}

static NSComparisonResult byEndX(id  _Nonnull obj1, id  _Nonnull obj2, void *unused){
  BKSTextPiece *p1 = (BKSTextPiece *)obj1;
  BKSTextPiece *p2 = (BKSTextPiece *)obj2;
  if (p1.bottomRight.x < p2.bottomRight.x) {
    return NSOrderedAscending;
  } else if (p1.bottomRight.x > p2.bottomRight.x) {
    return NSOrderedDescending;
  } else {
    return NSOrderedSame;
  }
}

static NSComparisonResult byStartX(id  _Nonnull obj1, id  _Nonnull obj2, void *unused){
  BKSTextPiece *p1 = (BKSTextPiece *)obj1;
  BKSTextPiece *p2 = (BKSTextPiece *)obj2;
  if (p1.bottomLeft.x < p2.bottomLeft.x) {
    return NSOrderedAscending;
  } else if (p1.bottomLeft.x > p2.bottomLeft.x) {
    return NSOrderedDescending;
  }
    return NSOrderedSame;
}

// A command line tool that given the path to an image file
// writes the array of text pieces to the standard output as a plist.
int main(int argc, const char * argv[]) {
  @autoreleasepool {
    if (@available(macOS 10.15, *)) {
    } else {
      fprintf(stderr, "Required macOS 10.15 or newer.\n");
      return 1;
    }
    if (argc == 2) {
      BKSOCRBoss *boss = [[BKSOCRBoss alloc] init];
      NSFileManager *fm = [NSFileManager defaultManager];
      NSString *path = [fm stringWithFileSystemRepresentation:argv[1] length:strlen(argv[1])];
      NSURL *url = [NSURL fileURLWithPath:path];
      if (nil == url) {
          fprintf(stderr, "Not found:%s.\n", argv[1]);
          return 1;
      }
      NSImage *image = [[NSImage alloc] initWithContentsOfURL:url];
      if (nil == image) {
          fprintf(stderr, "Not an image:%s.\n", argv[1]);
          return 1;
      }
      NSError *error = nil;
      NSArray<BKSTextPiece *> *pieces = [boss recognizeImageURL:url error:&error];
      if (pieces) {
        NSMutableArray<BKSTextPiece *> *sortPieces = [pieces mutableCopy];
        // Sort by bottomRight.x to find the median.
        [sortPieces sortUsingFunction:byEndX context:NULL];
        CGFloat medianEndX = sortPieces[sortPieces.count/2].bottomRight.x;
        [sortPieces sortUsingFunction:byStartX context:NULL];
        CGFloat medianStartX = sortPieces[sortPieces.count/2].bottomLeft.x;
        // Concatenate the page into an array of strings. If a previous line is short, the current one starts a new paragraph.
        NSMutableArray *a = [NSMutableArray array];
        for (NSUInteger i = 0; i < pieces.count; ++i) {
          BKSTextPiece *piece = pieces[i];
          if (piece.text) {
            // If the current line is indented, adjust the previous separator to be a paragaph separator.
            if (2 < a.count && medianStartX*1.1 < piece.bottomLeft.x && !hasInitialLowercase(piece.text)) {
              a[a.count - 1] = @"\n";
              [a addObject:piece.text];
              // Insert a paragraph separator if this is a short line, or at the end.
              if (piece.bottomRight.x < medianEndX*0.9 || i+1 == pieces.count){
                [a addObject:@"\n"];
              }else {
                [a addObject:@" "];
              }
            } else if (2 < a.count && [@" " isEqual:a.lastObject] && [a[a.count - 2] hasSuffix:@"-"]) {
              // If this isn't the first line of a paragraph, and the previous line ends in '-' assume
              // it is hypenated, and delete the hyphen and join.

              NSString *lastLine = a[a.count - 2];
              a[a.count - 2] = [[lastLine substringToIndex:lastLine.length-1] stringByAppendingString:piece.text];
            } else {
              [a addObject:piece.text];
              // Insert a paragraph separator if this is a short line, or at the end.
              if (piece.bottomRight.x < medianEndX*0.9 || i+1 == pieces.count){
                [a addObject:@"\n"];
              }else {
                [a addObject:@" "];
              }
            }
          }
        }
        NSString *all = [a componentsJoinedByString:@""];
        printf("%s", [all UTF8String]);
      }
    }
  }
  return 0;
}
