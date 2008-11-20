//
//  VocitoWindowController.h
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
#import <AddressBook/ABPeoplePickerView.h>

@class VocitoAppDelegate;

@interface VocitoWindowController : NSWindowController {
 @private
  IBOutlet NSSegmentedControl *gearControl_;
  IBOutlet NSMenu *gearMenu_;
  IBOutlet NSComboBox *fromNumber_;
  IBOutlet NSComboBox *toNumber_;
  IBOutlet ABPeoplePickerView *addressBook_;
  ABPerson *selectedRecord_;
  NSString *selectedIdentifier_;
  VocitoAppDelegate *delegate_;
  NSSize addressBookShownSize_;
  NSSize addressBookHiddenSize_;
  NSCharacterSet *phoneNumberSet_;
}
- (id)initWithDelegate:(VocitoAppDelegate*)delegate;
- (IBAction)dial:(id)sender;
- (IBAction)toggleAddressBookView:(id)sender;
- (IBAction)goToGrandCentral:(id)sender;
- (IBAction)saveAsApplication:(id)sender;
- (IBAction)checkForUpdates:(id)sender;
@end
