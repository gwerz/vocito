//
//  VocitoAppDelegate.h
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

@class VocitoWindowController;
@class VocitoController;
@class GTMSpeechRecognizer;

@interface VocitoAppDelegate : NSObject {
 @private
  NSStatusItem *statusItem_; 
  VocitoWindowController *dialerWindowController_;
  VocitoController *dialerController_;
  GTMSpeechRecognizer *speechRecognizer_;
}
- (NSPoint)rightOfStatusItem;
- (NSStatusItem*)statusItem;
- (IBAction)showPreferences:(id)sender;
- (VocitoController*)dialerController;
@end
