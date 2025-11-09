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
#import <getopt.h>

#import "Common.h"
#import "BKSTextPiece.h"
#import "BKSOCRBoss.h"

static BOOL hasInitialLowercase(NSString *s) {
    if (s.length) {
        unichar c = [s characterAtIndex:0];
        return islower(c);
    }
    return NO;
}

static NSComparisonResult byEndX(id _Nonnull obj1, id _Nonnull obj2, void *unused) {
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

static NSComparisonResult byStartX(id _Nonnull obj1, id _Nonnull obj2, void *unused) {
    BKSTextPiece *p1 = (BKSTextPiece *)obj1;
    BKSTextPiece *p2 = (BKSTextPiece *)obj2;
    if (p1.bottomLeft.x < p2.bottomLeft.x) {
        return NSOrderedAscending;
    } else if (p1.bottomLeft.x > p2.bottomLeft.x) {
        return NSOrderedDescending;
    }
    return NSOrderedSame;
}

static BOOL IsRightOSVersion(void);
static void PrintVersion(void);
static void PrintHelp(void);
static void ocr(NSString *path);

static const char optstring[] = "l:jhv";

static struct option long_options[] = {
    
    // Specify language (locale) for OCR
    {"language",                  required_argument,  0, 'l'},
    // JSON output
    {"json",                      no_argument,        0, 'j'},
    
    {"help",                      no_argument,        0, 'h'},
    {"version",                   no_argument,        0, 'v'},
    
    {0,                           0,                  0,  0 }
};



// A command line tool that given the path to an image file
// writes the array of text pieces to the standard output as a plist.

int main(int argc, const char * argv[]) {
    // Make sure we're running on a macOS version that supports speech recognition
    if (IsRightOSVersion() == NO) {
        NSPrintErr(@"This program requires macOS 10.15 or later.");
        exit(EXIT_FAILURE);
    }
    
    NSString *language = DEFAULT_LOCALE;
    BOOL jsonOutput = NO;
    
    // Parse arguments
    int optch;
    int long_index = 0;
    
    while ((optch = getopt_long(argc, (char *const *)argv, optstring, long_options, &long_index)) != -1) {
        switch (optch) {
            
            // Set language (i.e. locale) for speech recognition
            case 'l':
                language = @(optarg);
                break;
            
            case 'j':
                jsonOutput = YES;
                break;
            
            // Print version
            case 'v':
                PrintVersion();
                exit(EXIT_SUCCESS);
                break;
            
            // Print help text with list of option flags
            case 'h':
            default:
                PrintHelp();
                exit(EXIT_SUCCESS);
                break;
        }
    }
    
    // We always need one or more additional arguments, which should be paths to images
    if (argc - optind < 1) {
        NSPrintErr(@"Error: Missing argument.");
        PrintHelp();
        exit(EXIT_FAILURE);
    }
    
    // Read remaining args as paths
    NSMutableArray *imageFiles = [NSMutableArray array];
    NSFileManager *fm = [NSFileManager defaultManager];
    while (optind < argc) {
        NSString *path = [fm stringWithFileSystemRepresentation:argv[optind]
                                                         length:strlen(argv[optind])];
        if (path == nil) {
            NSPrintErr(@"Unable to process file: %s", argv[optind]);
            continue;
        }
        [imageFiles addObject:path];
        optind += 1;
    }
    
    for (NSString *imgFilePath in imageFiles) {
        NSPrint(@"%@:", imgFilePath);
        ocr(imgFilePath);
    }
    return EXIT_SUCCESS;
}
    
void ocr(NSString *path) {
    NSURL *url = [NSURL fileURLWithPath:path];
    if (url == nil) {
        NSPrintErr(@"Not found: %@", path);
        return;
    }
    
    NSImage *image = [[NSImage alloc] initWithContentsOfURL:url];
    if (nil == image) {
        NSPrintErr(@"Not a supported image format: %@", path);
        return;
    }
    
    BKSOCRBoss *boss = [[BKSOCRBoss alloc] init];

    NSError *error = nil;
    NSArray<BKSTextPiece *> *pieces = [boss recognizeImageURL:url error:&error];

    if ([pieces count]) {
        NSMutableArray<BKSTextPiece *> *sortPieces = [pieces mutableCopy];
        // Sort by bottomRight.x to find the median.
        [sortPieces sortUsingFunction:byEndX context:NULL];
        CGFloat medianEndX = sortPieces[sortPieces.count / 2].bottomRight.x;
        [sortPieces sortUsingFunction:byStartX context:NULL];
        CGFloat medianStartX = sortPieces[sortPieces.count / 2].bottomLeft.x;
        // Concatenate the page into an array of strings. If a previous line is short,
        // the current one starts a new paragraph.
        NSMutableArray *a = [NSMutableArray array];
        for (NSUInteger i = 0; i < pieces.count; ++i) {
            BKSTextPiece *piece = pieces[i];
            if (piece.text == nil) {
                continue;
            }
            // If the current line is indented, adjust the previous separator to be a paragaph separator.
            if (2 < a.count && medianStartX * 1.1 < piece.bottomLeft.x && !hasInitialLowercase(piece.text)) {
                a[a.count - 1] = @"\n";
                [a addObject:piece.text];
                // Insert a paragraph separator if this is a short line, or at the end.
                if (piece.bottomRight.x < medianEndX * 0.9 || i + 1 == pieces.count) {
                    [a addObject:@"\n"];
                } else {
                    [a addObject:@" "];
                }
            } else if (2 < a.count && [@" " isEqual:a.lastObject] && [a[a.count - 2] hasSuffix:@"-"]) {
                // If this isn't the first line of a paragraph, and the previous line ends in '-' assume
                // it is hypenated, and delete the hyphen and join.
                NSString *lastLine = a[a.count - 2];
                a[a.count - 2] = [[lastLine substringToIndex:lastLine.length - 1] stringByAppendingString:piece.text];
            } else {
                [a addObject:piece.text];
                // Insert a paragraph separator if this is a short line, or at the end.
                if (piece.bottomRight.x < medianEndX * 0.9 || i + 1 == pieces.count) {
                    [a addObject:@"\n"];
                } else {
                    [a addObject:@" "];
                }
            }
        }
        NSString *all = [a componentsJoinedByString:@""];
        NSPrint(all);
    }
}


#pragma mark -

static BOOL IsRightOSVersion(void) {
    // The OCR API wasn't introduced until macOS 10.15
    NSOperatingSystemVersion osVersion = {0};
    osVersion.majorVersion = 10;
    osVersion.minorVersion = 15;
    return [[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:osVersion];
}

static void PrintVersion(void) {
    NSPrint(@"%@ version %@ by %@", PROGRAM_NAME, PROGRAM_VERSION, PROGRAM_AUTHOR);
}

static void PrintHelp(void) {
    PrintVersion();
    NSPrint(@"\n\
%@ [-l lang] file ...\n\
\n\
Options:\n\
\n\
    -l --language           Specify speech recognition language\n\
    -j --json               Output JSON\n\
\n\
    -h --help               Prints help\n\
    -v --version            Prints program name and version\n\
\n\
For further details, see 'man %@'.", PROGRAM_NAME, PROGRAM_NAME);
}

