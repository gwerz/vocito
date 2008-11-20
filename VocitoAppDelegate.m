//
//  VocitoAppDelegate.m
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

#import "VocitoAppDelegate.h"
#import "StatusItemView.h"
#import "VocitoWindowController.h"
#import <Carbon/Carbon.h>
#import <AddressBook/AddressBook.h>
#import <AddressBook/ABAddressBookC.h>
#import "VocitoPreferences.h"
#import "VocitoController.h"
#import "VocitoDialService.h"
#import "GTMDefines.h"
#import "GTMGarbageCollection.h"

@interface NSApplication (VocitoScriptExtensions)
- (NSString*)fromNumber;
- (void)setFromNumber:(NSString *)number;
@end

@interface VocitoAppDelegate (Private)
- (void)showStartUpScreenIfNecessary;
- (void)updateVersionString;
@end

@implementation VocitoAppDelegate
- (id)init {
  if ((self = [super init])) {
    dialerController_ = [[VocitoController alloc] initWithDelegate:self];
  }
  return self;
}

- (void)dealloc {
  [statusItem_ release];
  [dialerWindowController_ release];
  [dialerController_ release];
  [speechRecognizer_ release];
  [versionString_ release];
  [startUpWindowController_ release];
  [super dealloc];
}

- (void)applicationWillFinishLaunching:(NSNotification *)notification {
  [VocitoPreferences setUpPreferenceDefaults];
  NSStatusBar *statusBar = [NSStatusBar systemStatusBar];
  statusItem_ = [[statusBar statusItemWithLength:24] retain];
  StatusItemView *view 
    = [[[StatusItemView alloc] initWithStatusItem:statusItem_] autorelease];
  [view setImage:[NSImage imageNamed:@"Vocito.pdf"]];
  [view setAlternateImage:[NSImage imageNamed:@"VocitoInvert.pdf"]];
  [view setAction:@selector(showDialerWindow:)];
  [view setTarget:self];
  [statusItem_ setView:view];
  //[statusItem_ setLength:];
}

- (BOOL)createPath:(NSString*)path {
  NSArray *pathComponents = [path pathComponents];
  NSEnumerator *comps = [pathComponents objectEnumerator];
  NSString *currentPath = [NSString string];
  NSString *comp;
  BOOL isGood = YES;
  NSFileManager *fm = [NSFileManager defaultManager];
  while (isGood && (comp = [comps nextObject])) {
    currentPath = [currentPath stringByAppendingPathComponent:comp];
    if (![fm fileExistsAtPath:currentPath]) {
      isGood = [fm createDirectoryAtPath:currentPath attributes:nil];
    }
  }
  return isGood;
}

- (BOOL)updatePathInLibrary:(NSString*)oldPath 
                       with:(NSString*)newPath 
                displayName:(NSString*)displayName {
  BOOL goodCopy = NO;
  NSFileManager *fm = [NSFileManager defaultManager];
  NSArray *libraryArray 
    = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,
                                          NSUserDomainMask, 
                                          YES);
  NSString *path = nil;
  if ([libraryArray count]) {
    path 
      = [[libraryArray objectAtIndex:0] stringByAppendingPathComponent:oldPath];
    goodCopy = [self createPath:[path stringByDeletingLastPathComponent]];
    if (goodCopy && [fm fileExistsAtPath:path]) {
      goodCopy = [fm removeFileAtPath:path handler:nil];
    }
  }
  if(goodCopy) { 
    goodCopy = [fm copyPath:newPath toPath:path handler:nil];
  }
  if (!goodCopy) {
    NSString *format = NSLocalizedString(@"Unable to install %@", nil);
    NSString *alertString = [NSString stringWithFormat:format, displayName];
    NSString *infoString = NSLocalizedString(@"Unable to copy to %@", nil);
    NSAlert *failedCopy = [NSAlert alertWithMessageText:alertString
                                          defaultButton:nil
                                        alternateButton:nil
                                            otherButton:nil
                              informativeTextWithFormat:infoString,
                           path];
    [failedCopy runModal];
  }
  return goodCopy;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
  VocitoDialService *service = [[VocitoDialService alloc] init];
  [NSApp setServicesProvider:service];
  int installedVersion = [VocitoPreferences installedPluginVersion];
  int currentVersion = [VocitoPreferences currentPluginVersion];
  BOOL needUpdate = installedVersion < currentVersion ? YES : NO;
  NSBundle *mainBundle = [NSBundle mainBundle];
  if (needUpdate) {
    NSString *abScriptPath 
      = [mainBundle pathForResource:@"VocitoAddressBookAction"
                             ofType:@"scpt"
                        inDirectory:@"Scripts"];
    NSString *qsScriptPath 
      = [mainBundle pathForResource:@"Vocito Module" ofType:@"qsplugin"];
    if (!abScriptPath || !qsScriptPath) return;
    NSString *abString = @"Address Book Plug-Ins/VocitoAddressBookAction.scpt";
    BOOL goodCopy = [self updatePathInLibrary:abString
                                         with:abScriptPath
                                  displayName:@"Vocito Address Book Plug-In"];
    NSString *qsString 
      = @"Application Support/Quicksilver/PlugIns/Vocito Module.qsplugin";
    goodCopy |= [self updatePathInLibrary:qsString
                                     with:qsScriptPath
                              displayName:@"Vocito Quıcĸsıɩⅴεʀ Plug-In"];
    if (goodCopy) {
      NSString *message = NSLocalizedString(@"New versions of the Vocito Address"
                                            @" Book Plug-In and Quıcĸsıɩⅴεʀ "
                                            @" Plug-In have been installed.", 
                                            nil);
      NSString *info = NSLocalizedString(@"Please restart Address Book and "
                                         @"Quıcĸsıɩⅴεʀ for them to take "
                                         @"effect.", nil);
      [NSApp activateIgnoringOtherApps:YES];
      NSAlert *newInstalls = [NSAlert alertWithMessageText:message
                                             defaultButton:nil
                                           alternateButton:nil
                                               otherButton:nil
                                 informativeTextWithFormat:info];
      [newInstalls runModal];
      [VocitoPreferences updateInstalledPluginVersion];
    }
  }
  [self showStartUpScreenIfNecessary];
  [self updateVersionString];
}

- (IBAction)showDialerWindow:(id)sender { 
  [startUpWindowController_ autorelease];
  startUpWindowController_ = nil;
  if ([[dialerWindowController_ window] isKeyWindow]) {
    [dialerWindowController_ close];
  } else {
    if (!dialerWindowController_) {
      dialerWindowController_ 
        = [[VocitoWindowController alloc] initWithDelegate:self];
    }
    StatusItemView *view = (StatusItemView*)[statusItem_ view];
    [view setSelected:YES];
    [dialerWindowController_ showWindow:sender];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self 
           selector:@selector(windowDidResignKey:)
               name:NSWindowDidResignKeyNotification 
             object:[dialerWindowController_ window]];
  }
}

- (void)windowDidResignKey:(NSNotification*)notification {
  StatusItemView *view = (StatusItemView*)[statusItem_ view];
  [view setSelected:NO];
}

- (NSPoint)rightOfStatusItem {
  NSView *statusItemView = [statusItem_ view];
  NSRect frame = [statusItemView frame];
  NSPoint origin = [statusItemView convertPoint:frame.origin toView:nil];
  NSPoint windowOrigin = [[statusItemView window] frame].origin;
  windowOrigin.x += origin.x + frame.size.width;
  windowOrigin.y += origin.y;
  return windowOrigin;
}

- (NSStatusItem*)statusItem {
  return statusItem_;
}

- (IBAction)showPreferences:(id)sender {
  VocitoPreferences *prefs = [[VocitoPreferences alloc] init];
  [NSApp runModalForWindow:[prefs window]];
  [prefs release];
}

- (VocitoController*)dialerController {
  return dialerController_;
}

- (void)showStartUpScreenIfNecessary {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  BOOL launchedBefore = [defaults boolForKey:@"LaunchedBefore"];
  if (!launchedBefore) {
    [(StatusItemView *)[statusItem_ view] startPulsing];
    startUpWindowController_ 
      = [[NSWindowController alloc] initWithWindowNibName:@"StartupScreen"];
    [[startUpWindowController_ window] makeKeyAndOrderFront:self];
    [defaults setBool:YES forKey:@"LaunchedBefore"];
    [defaults synchronize];
  }
}

- (void)updateVersionString {
  NSBundle *mainBundle = [NSBundle mainBundle];
  [self willChangeValueForKey:@"versionString_"];
  NSString *key = @"CFBundleShortVersionString";
  versionString_ = [[mainBundle objectForInfoDictionaryKey:key] retain];
  [self didChangeValueForKey:@"versionString_"];
}

@end

@implementation NSApplication (VocitoScriptExtensions)
- (NSString*)fromNumber {
  return [VocitoPreferences currentFromNumber];
}

- (void)setFromNumber:(NSString *)number {
  [VocitoPreferences updateRecentlyDialledFromNumbers:number];
}
@end
