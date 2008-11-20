//
//  StatusItemView.m
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

#import "StatusItemView.h"
#import <Carbon/Carbon.h>
#import "GTMNSBezierPath+RoundRect.h"

@implementation StatusItemView

- (id)initWithStatusItem:(NSStatusItem*)item {
  NSRect frame = NSMakeRect(0, 0, [item length], GetMBarHeight());
  if ((self = [super initWithFrame:frame])) {
    statusItem_ = item;
  }
  return self;
}

- (void)dealloc {
  [image_ release];
  [alternateImage_ release];
  [super dealloc];
}

- (void)drawRect:(NSRect)rect {
  NSRect bounds = [self bounds];
  [statusItem_ drawStatusBarBackgroundInRect:bounds withHighlight:selected_];
  if (isPulsing_) {
    NSColor *color = [[NSColor alternateSelectedControlColor] colorWithAlphaComponent:pulseAlpha_];
    [color setFill];
    bounds.origin.y += 1;
    NSBezierPath *path = [NSBezierPath gtm_bezierPathWithRoundRect:bounds cornerRadius:4];
    [path fill];
  }
  if (animationImage_) {
    NSSize animateSize = [animationImage_ size];
    
    NSPoint point = NSMakePoint(NSMaxX(bounds) - animationOffset_, 
                                bounds.origin.y + (NSHeight(bounds) / 2.0) 
                                - (animateSize.height / 2.0));
    [animationImage_ compositeToPoint:point operation:NSCompositeSourceOver];
  } else {
    NSImage *imageToUse = nil;
    if (selected_ && alternateImage_) {
      imageToUse = alternateImage_;
    } else {
      imageToUse = image_;
    }
    NSSize imageSize = [imageToUse size];
    NSRect imageRect = NSMakeRect(0, 0, imageSize.width, imageSize.height);
    
    bounds = NSInsetRect(bounds, 3, 3);
    [imageToUse drawInRect:bounds fromRect:imageRect operation:NSCompositeSourceOver fraction:1.0f];
  }
}

- (void)setImage:(NSImage*)image {
  if (image != image_) {
    [image_ release];
    image_ = [image retain];
    [self setNeedsDisplay:YES];
  }
}

- (void)setAlternateImage:(NSImage*)image {
  if (image != alternateImage_) {
    [alternateImage_ release];
    alternateImage_ = [image retain];
    [self setNeedsDisplay:YES];
  }
}

- (void)mouseDown:(NSEvent *)theEvent {
  if (isPulsing_) {
    isPulsing_ = NO;
    [animationTimer_ invalidate];
    [animationTimer_ release];
    animationTimer_ = nil;
    [self setNeedsDisplay:YES];
  }
  [target_ performSelector:action_ withObject:self];
}

- (void)setAction:(SEL)action {
  action_ = action;
}

- (void)setTarget:(id)target {
  target_ = target;
}

- (void)setSelected:(BOOL)selected {
  if (selected_ != selected) {
    selected_ = selected;
    [self setNeedsDisplay:YES];
  }
}
    
- (void)updateTextDrawing:(NSTimer*)timer {
  [self setNeedsDisplay:YES];
  float offset = 3;
  animationOffset_ += offset;
  
  if (animationLength_ < 100) {
    animationLength_ += offset;
    NSDisableScreenUpdates();
    [statusItem_ setLength:animationLength_];
    NSEnableScreenUpdates();
  }
}

- (void)animateText:(NSString*)text {
  originalLength_ = [statusItem_ length];
  animationLength_ = 1;
  animationTimer_ 
    = [[NSTimer scheduledTimerWithTimeInterval:1.0/24.0
                                        target:self 
                                      selector:@selector(updateTextDrawing:)
                                      userInfo:nil
                                       repeats:YES] retain];
  animationOffset_ = 0;
  
  NSFont *sysFont = [NSFont systemFontOfSize:[NSFont systemFontSize]];
  NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                              sysFont, NSFontAttributeName,
                              nil];
  NSAttributedString *animatedString 
    = [[[NSAttributedString alloc] initWithString:text 
                                       attributes:attributes] autorelease];  
  int options = NSStringDrawingUsesDeviceMetrics;
  NSRect frameRect = [animatedString boundingRectWithSize:NSZeroSize
                                                  options:options];
  float baseLine = 0 - frameRect.origin.y;
  frameRect = NSMakeRect(0, 0, NSWidth(frameRect) + 1, NSHeight(frameRect) + 1);
  NSBitmapImageRep *imageRep 
    = [[[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
                                               pixelsWide:NSWidth(frameRect)
                                               pixelsHigh:NSHeight(frameRect)
                                            bitsPerSample:8
                                          samplesPerPixel:4
                                                 hasAlpha:YES
                                                 isPlanar:NO
                                           colorSpaceName:NSCalibratedRGBColorSpace
                                             bitmapFormat:0
                                              bytesPerRow:0
                                             bitsPerPixel:0] autorelease];
  animationImage_ = [[NSImage alloc] initWithSize:frameRect.size];
  [animationImage_ addRepresentation:imageRep];
  [animationImage_ lockFocusOnRepresentation:imageRep];
  [[NSColor clearColor] set];
  NSRectFill(frameRect);
  frameRect.origin.y += baseLine;
  [animatedString drawWithRect:frameRect options:options];
  [animationImage_ unlockFocus];
}

- (void)stopAnimation:(id)sender {
  [animationImage_ autorelease];
  animationImage_ = nil;
  NSDisableScreenUpdates();
  [statusItem_ setLength:originalLength_];
  NSEnableScreenUpdates();
  [animationTimer_ invalidate];
  [animationTimer_ release];
  animationTimer_ = nil;
  [self setNeedsDisplay:YES];
}

- (void)updatePulse:(id)sender {
  float offset = 1.0/30.0;
  if (!pulseDarken_) {
    offset = -offset;
  }
  pulseAlpha_ += offset;
  if (pulseAlpha_ < 0 || pulseAlpha_ > 1.0) {
    pulseDarken_ = !pulseDarken_;
  }
  [self setNeedsDisplay:YES];
}

- (void)startPulsing {
  isPulsing_ = YES;
  pulseAlpha_ = 0.0;
  pulseDarken_ = YES;
  animationTimer_ = [[NSTimer scheduledTimerWithTimeInterval:1.0/60.0
                                                      target:self 
                                                    selector:@selector(updatePulse:)
                                                    userInfo:nil
                                                     repeats:YES] retain];
}
@end
