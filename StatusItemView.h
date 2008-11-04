//
//  StatusItemView.h
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

#import <Cocoa/Cocoa.h>


@interface StatusItemView : NSView {
 @private
  NSStatusItem *statusItem_;
  NSImage *image_;
  NSImage *alternateImage_;
  BOOL selected_;
  SEL action_;
  id target_;
  BOOL useAlternate_;
  NSTimer *animationTimer_;
  float animationOffset_;
  float animationLength_;
  float originalLength_;
  NSImage *animationImage_;
}
- (id)initWithStatusItem:(NSStatusItem*)item;
- (void)setImage:(NSImage*)image;
- (void)setAlternateImage:(NSImage*)image;
- (void)setAction:(SEL)action;
- (void)setTarget:(id)target;
- (void)setSelected:(BOOL)selected;
- (void)animateText:(NSString*)text;
- (void)stopAnimation:(id)sender;
@end
