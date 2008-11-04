//
//  QSWindowFilter.m
//
//  Created by Nicholas Jitkoff on 11/20/05.
//  Copyright 2005 Blacktree, All rights reserved.
//

#import "QSWindowFilter.h"

typedef int CGSConnectionID;
extern CGSConnectionID _CGSDefaultConnection(void);
extern CGError CGSNewCIFilterByName(CGSConnectionID cid, CFStringRef filterName, CGSWindowFilterRef *outFilter);
extern CGError CGSAddWindowFilter(CGSConnectionID cid, CGSWindowID wid, CGSWindowFilterRef filter, int flags);
extern CGError CGSRemoveWindowFilter(CGSConnectionID cid, CGSWindowID wid, CGSWindowFilterRef filter);
extern CGError CGSReleaseCIFilter(CGSConnectionID cid, CGSWindowFilterRef filter);
extern CGError CGSSetCIFilterValuesFromDictionary(CGSConnectionID cid, CGSWindowFilterRef filter, CFDictionaryRef filterValues);

@implementation QSWindowFilter

- (id)initWithWindow:(NSWindow *)window {
  if ((self = [super init])) {
    SInt32 systemVersion = 0;
    OSStatus err = Gestalt(gestaltSystemVersion, &systemVersion);
    if (err != noErr || systemVersion < 0x1050) {
      [self release];
      return nil;
    }
    windowID_ = [window windowNumber];
  }
  return self;
}

- (void)dealloc {
  [self setFilterName:nil];
  [super dealloc];
}

- (void)setFilterName:(NSString *)filterName {
  CGSConnectionID connID = _CGSDefaultConnection();
  CGError error = kCGErrorSuccess;
  if (filterID_) {
    error = CGSRemoveWindowFilter(connID, windowID_, filterID_);
    error = CGSReleaseCIFilter(connID, filterID_);
  }
  if (filterName) {
    error = CGSNewCIFilterByName(connID, (CFStringRef)filterName, &filterID_);
    if (kCGErrorSuccess == error) {
      error = CGSAddWindowFilter(connID, windowID_, filterID_, 0x00003001);
    }
  }
}

- (void)setFilterValues:(NSDictionary *)filterValues {
  if (!filterID_) return;
  CGSConnectionID connID = _CGSDefaultConnection();
  CGSSetCIFilterValuesFromDictionary(connID, 
                                     filterID_, 
                                     (CFDictionaryRef)filterValues);
}

@end
