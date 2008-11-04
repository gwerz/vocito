//
//  VocitoDialService.m
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

#import "VocitoDialService.h"
#import "VocitoController.h"
#import "VocitoAppDelegate.h"

@implementation VocitoDialService
- (void)call:(NSPasteboard *)pboard
    userData:(NSString *)userData
       error:(NSString **)error {
  
  NSArray *types = [pboard types];
  if (![types containsObject:NSStringPboardType]) {
    *error = NSLocalizedString(@"Vocito couldn't get phone number to dial",
                               nil);
    return;
  }
  NSString * pboardString = [pboard stringForType:NSStringPboardType];
  if (!pboardString) {
    *error = NSLocalizedString(@"Vocito couldn't get phone number to dial",
                               nil);
    return;
  }
  VocitoAppDelegate *delegate = [NSApp delegate];
  VocitoController *controller = [delegate dialerController];
  NSError *localError = nil;
  [controller callPhone:pboardString
              fromPhone:nil 
          waitUntilDone:YES error:&localError];
  if (localError && error) {
    *error = [localError localizedDescription];
  }
}
@end
