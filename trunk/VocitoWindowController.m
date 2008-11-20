//
//  VocitoWindowController.m
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

#import <AddressBook/AddressBook.h>
#import <Sparkle/Sparkle.h>

#import "VocitoWindowController.h"
#import "VocitoAppDelegate.h"
#import "VocitoController.h"
#import "VocitoPreferences.h"
#import "GTMSystemVersion.h"
#import "GTMNSAppleEventDescriptor+Foundation.h"

@interface VocitoWindowController (VocitoWindowControllerPrivate)
- (void)pickerSelectionChanged:(NSNotification*)notification;
- (void)updatePrimaryNumber:(NSString *)primaryNumber;
@end 

@implementation VocitoWindowController

- (id)initWithDelegate:(VocitoAppDelegate *)inDelegate  {
  if ((self = [super initWithWindowNibName:@"Dialer"])) {
    delegate_ = inDelegate;
    phoneNumberSet_
      = [NSCharacterSet characterSetWithCharactersInString:@"0123456789().- #*"];
    phoneNumberSet_ = [[phoneNumberSet_ invertedSet] retain];
  }
  return self;
}

- (void)dealloc {
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  [nc removeObserver:self];
  [selectedRecord_ release];
  [selectedIdentifier_ release];
  [phoneNumberSet_ release];
  [super dealloc];
}

- (void)windowDidLoad {
  [super windowDidLoad];
  NSWindow *window = [self window];
  [window setOpaque:NO];
  
  [window setBackgroundColor:[NSColor colorWithDeviceWhite:1.0f 
                                                     alpha:0.85f]];
  addressBookHiddenSize_ = [window frame].size;
  
  NSRect addressBookBounds = [addressBook_ bounds];
  float height = NSHeight(addressBookBounds);
  addressBookShownSize_ = addressBookHiddenSize_;
  addressBookShownSize_.height += height - 20;
  addressBookShownSize_.width += 160;
  
  [gearControl_ setMenu:gearMenu_ forSegment:0];
  if (![GTMSystemVersion isLeopardOrGreater]) {
    [gearControl_ setImage:[NSImage imageNamed:@"Action"]
                forSegment:0];
    // Red'q for bug in Tiger
    // http://developer.apple.com/documentation/Cocoa/Conceptual/SegmentedControl/Articles/SegmentedControlCode.html#//apple_ref/doc/uid/20002250-129646
    [gearControl_ setLabel:nil forSegment:0];
  } else {
    [gearControl_ setImage:[NSImage imageNamed:NSImageNameActionTemplate]
                forSegment:0];
  }
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  [nc addObserver:self
         selector:@selector(pickerSelectionChanged:) 
             name:ABPeoplePickerValueSelectionDidChangeNotification 
           object:addressBook_];
}

- (NSRect)updateWindowFrame {
  BOOL shown = ![addressBook_ isHidden];
  NSRect visibleScreenRect = [[NSScreen mainScreen] visibleFrame];
  NSPoint rightOfItem = [delegate_ rightOfStatusItem];
  NSSize size = shown ? addressBookShownSize_ : addressBookHiddenSize_;
  float screenX = NSMaxX(visibleScreenRect) - size.width - 10;
  float itemX = rightOfItem.x - addressBookHiddenSize_.width;
  float xOrigin = shown ? MIN(screenX, itemX) : itemX;
  NSRect frame;
  frame.origin = NSMakePoint(xOrigin, NSMaxY(visibleScreenRect) - size.height);  
  frame.size = size;
  return frame;
}

- (IBAction)showWindow:(id)sender {
  NSWindow *window = [self window];
  NSRect frame = [self updateWindowFrame];
  [window setFrameOrigin:frame.origin];
  [super showWindow:sender];
  [window setAlphaValue:1.0f];
}

- (void)windowDidResignKey:(NSNotification *)notification {
  [self close];  
}

- (IBAction)dial:(id)sender {
  NSString *toValue = [toNumber_ stringValue];
  NSString *fromValue = [fromNumber_ stringValue];
  [self updatePrimaryNumber:toValue];
  [[delegate_ dialerController] callPhone:toValue 
                                 fromPhone:fromValue 
                             waitUntilDone:NO 
                                     error:nil];
  [[self window] close];
}

- (IBAction)toggleAddressBookView:(id)sender {
  NSWindow *window = [self window];
  if ([addressBook_ isHidden]) {
    [addressBook_ setHidden:NO];
    [window selectKeyViewFollowingView:fromNumber_];
    [self updateWindowFrame];
  } else {
    NSResponder *firstResponder = [window firstResponder];
    if ([firstResponder isKindOfClass:[NSView class]]) {
      NSView *firstResponderView = (NSView*)firstResponder;
      if ([firstResponderView isDescendantOf:addressBook_]) {
        [window makeFirstResponder:toNumber_];
      }
    }
    [addressBook_ setHidden:YES];
  } 
  [window setFrame:[self updateWindowFrame]
           display:YES 
           animate:YES];
}

- (void)pickerSelectionChanged:(NSNotification*)notification {
  if (![addressBook_ isHidden]) {
    NSArray *items = [addressBook_ selectedValues];
    [selectedIdentifier_ autorelease];
    [selectedRecord_ autorelease];
    selectedRecord_ = nil;
    selectedIdentifier_ = nil;
    if ([items count]) {
      [toNumber_ setStringValue:[items objectAtIndex:0]];
      NSArray *selectedRecords = [addressBook_ selectedRecords];
      if ([selectedRecords count]) {
        selectedRecord_ = [[selectedRecords objectAtIndex:0] retain];
        NSArray *selectedIdentifiers 
          = [addressBook_ selectedIdentifiersForPerson:selectedRecord_];
        if ([selectedIdentifiers count]) {
          selectedIdentifier_ = [[selectedIdentifiers objectAtIndex:0] retain];
        }
      }
    } else {
      [toNumber_ setStringValue:@""];
    }
  }
}

- (void)updatePrimaryNumber:(NSString *)primaryNumber {
  if (!selectedRecord_ || !selectedIdentifier_ || !primaryNumber) return;
  ABMultiValue *phoneNumbers
    = [selectedRecord_ valueForProperty:kABPhoneProperty];
  unsigned int index = [phoneNumbers indexForIdentifier:selectedIdentifier_];
  NSString *phoneNumber = [phoneNumbers valueAtIndex:index];
  NSString *primaryIdentifier = [phoneNumbers primaryIdentifier];
  if ([phoneNumber isEqualToString:primaryNumber] 
      && ![primaryIdentifier isEqualToString:selectedIdentifier_]) {
    ABMutableMultiValue *newNumbers = [phoneNumbers mutableCopy];
    [newNumbers setPrimaryIdentifier:selectedIdentifier_];
    [selectedRecord_ setValue:newNumbers forProperty:kABPhoneProperty];
    ABAddressBook *book = [ABAddressBook sharedAddressBook];
    [book save];
  }
}

- (IBAction)goToGrandCentral:(id)sender {
  NSURL *gcURL = [NSURL URLWithString:@"http://www.grandcentral.com"];
  [[NSWorkspace sharedWorkspace] openURL:gcURL];
}

- (IBAction)saveAsApplication:(id)sender {
  NSString *nameFormat = NSLocalizedString(@"Call %@ from %@", nil);
  NSString *name = [NSString stringWithFormat:nameFormat, 
                    [toNumber_ stringValue], 
                    [fromNumber_ stringValue]];
  NSSavePanel *panel = [NSSavePanel savePanel];
  [panel setRequiredFileType:@"app"];
  [NSApp activateIgnoringOtherApps:YES];
  if ([panel runModalForDirectory:nil 
                             file:name] != NSFileHandlingPanelOKButton) {
    return;
  }
  NSFileManager *fm = [NSFileManager defaultManager];
  NSString *errorString = nil;
  NSString *scriptString = [NSString stringWithFormat:
                            @"tell application \"Vocito\""
                            @"to dial \"%@\" from \"%@\"",
                            [toNumber_ stringValue], [fromNumber_ stringValue]];
  NSAppleScript *script 
    = [[[NSAppleScript alloc] initWithSource:scriptString] autorelease];
  NSDictionary *errorDict = nil;
  if (![script compileAndReturnError:&errorDict]) {
    errorString = [errorDict objectForKey:NSAppleScriptErrorMessage];
    goto errorOccurred;
  } 
  NSData *data = [[script gtm_appleEventDescriptor] data];
  if (!data) {
    errorString = NSLocalizedString(@"Unable to create script.", nil);
    goto errorOccurred;
  }
  
  NSString *bundle = [[NSBundle mainBundle] pathForResource:@"ScriptTemplate" 
                                                     ofType:@"app"];
  NSString *filename = [panel filename];
  if ([fm fileExistsAtPath:filename]) {
    if (![fm removeFileAtPath:filename handler:nil]) {
      NSString *format = NSLocalizedString(@"Unable to remove %@.", nil);
      errorString = [NSString stringWithFormat:format, filename];
      goto errorOccurred;
    }
  }
  if (![fm copyPath:bundle toPath:filename handler:nil]) {
    NSString *format = NSLocalizedString(@"Unable to copy %@ to %@.", nil);
    errorString = [NSString stringWithFormat:format, bundle, filename];
    goto errorOccurred;
  }
  NSString *dictPath 
    = [filename stringByAppendingPathComponent:@"Contents/Info.plist"];    
  NSMutableDictionary *infoDict 
    = [NSMutableDictionary dictionaryWithContentsOfFile:dictPath];
  if (!infoDict) {
    NSString *format = NSLocalizedString(@"Unable to open %@.", nil);
    errorString = [NSString stringWithFormat:format, dictPath];
    goto errorOccurred;
  }
  name = [[filename lastPathComponent] stringByDeletingPathExtension];
  [infoDict setObject:name forKey:@"Bundle name"];
  if (![fm removeFileAtPath:dictPath handler:nil]) {
    NSString *format = NSLocalizedString(@"Unable to remove %@.", nil);
    errorString = [NSString stringWithFormat:format, dictPath];
    goto errorOccurred;
  }
  if (![infoDict writeToFile:dictPath atomically:YES]) {
    NSString *format = NSLocalizedString(@"Unable to write file to %@.", nil);
    errorString = [NSString stringWithFormat:format, dictPath];
    goto errorOccurred;
  }
  NSBundle *scriptBundle = [NSBundle bundleWithPath:filename];
  NSString *scriptPath = [scriptBundle pathForResource:@"main" 
                                                ofType:@"scpt" 
                                           inDirectory:@"Scripts"];
  if (![fm removeFileAtPath:scriptPath handler:nil]) {
    NSString *format = NSLocalizedString(@"Unable to remove file %@.", nil);
    errorString = [NSString stringWithFormat:format, scriptPath];
    goto errorOccurred;
  }
  if (![data writeToFile:scriptPath atomically:YES]) {
    NSString *format = NSLocalizedString(@"Unable to write file to %@.", nil);
    errorString = [NSString stringWithFormat:format, scriptPath];
    goto errorOccurred;
  }
  [[NSWorkspace sharedWorkspace] noteFileSystemChanged:filename];
  return;
  
  errorOccurred: 
  [fm removeFileAtPath:filename handler:nil];
  NSString *message = NSLocalizedString(@"Unable to create application.", nil);
  NSAlert *alert = [NSAlert alertWithMessageText:message
                                   defaultButton:nil
                                 alternateButton:nil
                                     otherButton:nil
                       informativeTextWithFormat:errorString];
  [NSApp activateIgnoringOtherApps:YES];
  [alert runModal];
}

- (IBAction)checkForUpdates:(id)sender {
  [[SUUpdater sharedUpdater] checkForUpdates:sender];
}

- (void)controlTextDidChange:(NSNotification *)notification {
  if ([[notification object] isEqual:toNumber_]) {
    NSString *number = [toNumber_ stringValue];
    NSWindow *window = [self window];
    NSRange badCharRange = [number rangeOfCharacterFromSet:phoneNumberSet_];
    if (badCharRange.location != NSNotFound) {
      if ([addressBook_ isHidden]) {
        [self toggleAddressBookView:self];
      } else {
        [window selectKeyViewFollowingView:fromNumber_];
      }
      NSSearchField *view = (NSSearchField*)[fromNumber_ nextValidKeyView];
      [view setStringValue:number];
      NSText *text = [window fieldEditor:YES forObject:view];
      [text setSelectedRange:NSMakeRange([number length], 0)];
      [toNumber_ setStringValue:@""];
      [[view target] performSelector:[view action] withObject:self];
    }
  }
}
@end
