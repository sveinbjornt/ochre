/*
    ochre - macOS Optical Character Recognition via the command line

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

#include "Common.h"

#import <stdio.h>

// Print NSString to stdout
inline void NSPrint(NSString *format, ...) {
    va_list args;
    
    va_start(args, format);
    NSString *string  = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    fprintf(stdout, "%s\n", [string UTF8String]);
    fflush(stdout); // Flush stdout to prevent any line buffering issues
}

// Print NSString to stderr
inline void NSPrintErr(NSString *format, ...) {
    va_list args;
    
    va_start(args, format);
    NSString *string  = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    fprintf(stderr, "%s\n", [string UTF8String]);
    fflush(stderr); // Flush stderr to prevent any line buffering issues
}

// Print NSString to stdout without newline, flushing stdout in the process
// to ensure that the output is shown immediately without line buffering
inline void NSDump(NSString *format, ...) {
    va_list args;
    
    va_start(args, format);
    NSString *string  = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    fprintf(stdout, "%s", [string UTF8String]); // No newline appended
    fflush(stdout); // Flush stdout to prevent line buffering issues
}
