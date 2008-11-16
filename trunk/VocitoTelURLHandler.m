//
//  VocitoTelURLHandler.m
//
//  Copyright 2008 Google Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not
//  use this file except in compliance with the License.  You may obtain a copy
//  of the License at
// 
//  http://www.apache.org/licenses/LICENSE-2.0
// 
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
//  WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
//  License for the specific language governing permissions and limitations under
//  the License.
//

#import "VocitoAppDelegate.h"
#import "VocitoController.h"

static NSString *const kTelURLScheme = @"tel:";

@interface VocitoTelURLHandler : NSObject
@end

@implementation VocitoTelURLHandler
+ (BOOL)gtm_openURL:(NSURL*)url {
  BOOL isGood = NO;
  NSString *toNumber = [[url absoluteString] lowercaseString];
  if ([toNumber hasPrefix:kTelURLScheme]) {
    toNumber = [toNumber substringFromIndex:[kTelURLScheme length]];
    VocitoAppDelegate *delegate = [NSApp delegate];
    VocitoController *controller = [delegate dialerController];
    NSError *error = nil;
    [controller callPhone:toNumber
                fromPhone:nil 
            waitUntilDone:YES 
                    error:&error];
    isGood = error == nil;
  }
  return isGood;
}

@end
