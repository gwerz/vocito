//
//  QSWindowFilter.h
//
//  Created by Nicholas Jitkoff on 11/20/05.
//  Copyright 2005 Blacktree, All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef void *CGSWindowFilterRef;
typedef int CGSWindowID;

@interface QSWindowFilter : NSObject {
 @private
  CGSWindowID windowID_;
  CGSWindowFilterRef filterID_;
}
- (void)setFilterName:(NSString *)filter;
- (void)setFilterValues:(NSDictionary *)filterValues;

@end
