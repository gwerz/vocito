//
//  VocitoDialCommand.m
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

#import "VocitoController.h"
#import "VocitoAppDelegate.h"

@interface VocitoDialCommand : NSScriptCommand
@end

@implementation VocitoDialCommand
- (id)performDefaultImplementation {
  NSDictionary *args = [self evaluatedArguments];
  NSString *toNumber = [self directParameter];
  NSString *fromNumber = [args objectForKey:@"From"];
  VocitoAppDelegate *delegate = [NSApp delegate];
  VocitoController *controller = [delegate dialerController];
  NSError *error = nil;
  [controller callPhone:toNumber
              fromPhone:fromNumber 
          waitUntilDone:YES error:&error];
  if (error) {
    [self setScriptErrorNumber:[error code]];
    [self setScriptErrorString:[error localizedDescription]];
  }
  return nil;
}

@end
