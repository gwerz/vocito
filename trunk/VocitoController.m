//
//  VocitoController.m
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
#import "Vocito.h"
#import "VocitoPreferences.h"
#import "VocitoAppDelegate.h"
#import "StatusItemView.h"

@implementation VocitoController
- (id)initWithDelegate:(VocitoAppDelegate *)inDelegate {
  if ((self = [super init])) {
    delegate_ = inDelegate;
    diallingDone_ = NO;
    error_ = nil;
    waitingUntilDone_ = NO;
  }
  return self;
}

- (void)dealloc {
  [stopAnimationTimer_ invalidate];
  [stopAnimationTimer_ release];
  [super dealloc];
}

- (void)callPhone:(NSString*)toPhoneNumber 
        fromPhone:(NSString*)fromPhoneNumber
    waitUntilDone:(BOOL)waitUntilDone
            error:(NSError**)error {

  waitingUntilDone_ = waitUntilDone;
  NSString *username = [VocitoPreferences username];
  if (!username) return;
  
  Vocito *dialer = [[Vocito alloc] initWithDelegate:(id)self];
  if (!fromPhoneNumber) {
    fromPhoneNumber = [VocitoPreferences currentFromNumber];
  }
  NSString *statusText = [NSString stringWithFormat:@"Calling %@ from %@", 
                          toPhoneNumber, fromPhoneNumber];
  if (stopAnimationTimer_) {
    [stopAnimationTimer_ invalidate];
    [stopAnimationTimer_ release];
    stopAnimationTimer_ = nil;
    [(StatusItemView*)[[delegate_ statusItem] view] stopAnimation:nil];
  }
  [(StatusItemView*)[[delegate_ statusItem] view] animateText:statusText];
  [dialer callPhone:toPhoneNumber fromPhone:fromPhoneNumber forUser:username];  
  
  if (!error_ && waitingUntilDone_) {
    NSRunLoop *loop = [NSRunLoop currentRunLoop];
    diallingDone_ = NO;
    
    while (!error_ && !diallingDone_) {
      [loop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.2]];
    }
  }
  if (error) {
    *error = error_;
  }
  [error_ autorelease];
  error_ = nil;
}

- (void)stopAnimation:(NSTimer *)timer {
  [(StatusItemView*)[[delegate_ statusItem] view] stopAnimation:self];
  [stopAnimationTimer_ release];
  stopAnimationTimer_ = nil;
}
  
- (void)dialerDidLogin:(Vocito *)dialer {
}

- (void)dialerDidDial:(Vocito *)dialer {
  NSString *toValue = [dialer toPhoneNumber];
  NSString *fromValue = [dialer fromPhoneNumber];
  [VocitoPreferences updateRecentlyDialledNumbers:toValue];
  [VocitoPreferences updateRecentlyDialledFromNumbers:fromValue];
  [dialer autorelease];
  diallingDone_ = YES;
  stopAnimationTimer_ 
    = [[NSTimer scheduledTimerWithTimeInterval:6
                                        target:self
                                      selector:@selector(stopAnimation:) 
                                      userInfo:nil repeats:NO] retain];
}

- (void)dialer:(Vocito *)dialer didFailWithError:(NSError *)error {
  [dialer autorelease];
  diallingDone_ = YES;
  error_ = error;
  [error_ retain];
  [(StatusItemView*)[[delegate_ statusItem] view] stopAnimation:nil];
  if (!waitingUntilDone_) {
    NSString *message = NSLocalizedString(@"Vocito Unable To Complete Call", nil);
    NSAlert *alert = [NSAlert alertWithMessageText:message
                                     defaultButton:nil 
                                   alternateButton:nil 
                                       otherButton:nil 
                         informativeTextWithFormat:[error localizedDescription]];
    [NSApp activateIgnoringOtherApps:YES];
    [alert runModal];
  }
}

@end
