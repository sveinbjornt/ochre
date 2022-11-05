/*
    ochre - macOS Optical Character Recognition via the command line

    Copyright (c) 2022 Sveinbjorn Thordarson <sveinbjorn@sveinbjorn.org>
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
