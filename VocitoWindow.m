//
//  VocitoWindow.m
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

#import "VocitoWindow.h"

#define FADE_RADIUS 2.0f

@implementation VocitoWindow
- (id)initWithContentRect:(NSRect)contentRect styleMask:(unsigned int)aStyle 
                  backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag {
  NSPanel *window = [super initWithContentRect:contentRect 
                          styleMask:(NSBorderlessWindowMask | NSNonactivatingPanelMask)
                            backing:bufferingType 
                              defer:NO];
  [window setLevel:NSMainMenuWindowLevel-1];
  
  
  filter_ = [[QSWindowFilter alloc] initWithWindow:self];
  [filter_ setFilterName:@"CIGaussianBlur"];
  [filter_ setFilterValues:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:FADE_RADIUS], @"inputRadius",nil]];
  return window;
}

- (void) dealloc {
  [filter_ release];
  [super dealloc];
}

- (BOOL)canBecomeKeyWindow {
  return YES; 
}

const double kFadeDuration = 0.3;

- (void)orderOut:(id)sender {
  NSDate *date = [NSDate date];
  double elapsed;
  while (kFadeDuration > (elapsed = -[date timeIntervalSinceNow])) {
    float alphaFraction =  (float)(1.0 - (elapsed / kFadeDuration));
    [self setAlphaValue:alphaFraction];
    
    [filter_ setFilterValues:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:FADE_RADIUS * powf(fraction, 4.0f)], @"inputRadius",nil]];

  }
  [self setAlphaValue:0.0f];
  [super orderOut:sender];
  [filter_ setFilterValues:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:FADE_RADIUS], @"inputRadius",nil]];

}

@end
