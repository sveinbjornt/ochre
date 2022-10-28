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

#import <Foundation/Foundation.h>

#define PROGRAM_NAME        @"ocr"
#define PROGRAM_VERSION     @"0.1"
#define PROGRAM_AUTHOR      @"Sveinbjorn Thordarson"

#define DEFAULT_LOCALE      @"en-US"

// Logging in debug mode only
#ifdef DEBUG
    #define DLog(...) NSLog(__VA_ARGS__)
#else
    #define DLog(...)
#endif

void NSPrint(NSString *format, ...);
void NSPrintErr(NSString *format, ...);
void NSDump(NSString *format, ...);
