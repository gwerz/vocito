//
//  VocitoPreferences.h
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

@interface VocitoPreferences : NSWindowController {
 @private
  IBOutlet NSTextField *username_;
  IBOutlet NSTextField *password_;
  BOOL loginCheckDone_;
}

+ (void)setUpPreferenceDefaults;
+ (void)updateRecentlyDialledNumbers:(NSString*)number;
+ (void)updateRecentlyDialledFromNumbers:(NSString*)number;
+ (NSString*)currentFromNumber;
+ (NSString*)username;
+ (int)installedPluginVersion;
+ (void)updateInstalledPluginVersion;
+ (int)currentPluginVersion;
- (IBAction)ok:(id)sender;
- (IBAction)cancel:(id)sender;
@end
