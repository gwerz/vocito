//
//  VocitoPreferences.m
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

#import "VocitoPreferences.h"
#import "EMKeychainProxy.h"
#import "Vocito.h"
#import <AddressBook/AddressBook.h>

NSString *const UserNamePreferenceKey = @"UserName";
NSString *const RecentlyDialledNumbersKey = @"RecentlyDialledNumbers";
NSString *const RecentlyDialledFromNumbersKey = @"RecentlyDialledFromNumbers";
NSString *const LastDialledNumberKey = @"LastDialledNumber";
NSString *const LastDialledFromNumberKey = @"LastDialledFromNumber";
NSString *const InstalledPlugInsVersionKey = @"InstalledPlugInsVersionKey";
\
@implementation VocitoPreferences
- (id)init {
  return [super initWithWindowNibName:@"VocitoPreferences"];
}

- (void)setWindow:(NSWindow *)window {
  [super setWindow:window];
  [window center];
}

- (void)windowDidLoad {
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  NSString *username  = [ud stringForKey:UserNamePreferenceKey];
  if (username) {
    [username_ setStringValue:username];
    EMKeychainProxy *keychain = [EMKeychainProxy sharedProxy];
    NSString *server = [Vocito serverName];
    EMInternetKeychainItem *keychainItem 
      = [keychain internetKeychainItemForServer:server
                                   withUsername:username
                                           path:@""
                                           port:0
                                       protocol:kSecProtocolTypeHTTPS];
    if (keychainItem) {
      [password_ setStringValue:[keychainItem password]];
    }
  }
  [[self window] makeKeyAndOrderFront:self];
  [NSApp activateIgnoringOtherApps:YES];
}

- (IBAction)ok:(id)sender {
  NSString *username = [username_ stringValue];
  NSString *password = [password_ stringValue];
  
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  [ud setObject:username forKey:UserNamePreferenceKey];
  
  if (username && password) {
    EMKeychainProxy *keychain = [EMKeychainProxy sharedProxy];
    NSString *server = [Vocito serverName];
    EMInternetKeychainItem *keychainItem 
      = [keychain internetKeychainItemForServer:server
                                   withUsername:username
                                           path:@""
                                           port:0
                                       protocol:kSecProtocolTypeHTTPS];
    if (!keychainItem) {
      [keychain addInternetKeychainItemForServer:server
                                    withUsername:username
                                        password:password
                                            path:@""
                                            port:0
                                        protocol:kSecProtocolTypeHTTPS];
    } else {
      [keychainItem setUsername:username];
      [keychainItem setPassword:password];
    }
  }
  [NSApp stopModal];
}

- (IBAction)cancel:(id)sender {
  [NSApp abortModal];
}

+ (NSString*)username {
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  NSString *username = [ud stringForKey:UserNamePreferenceKey];
  if ([username length] == 0) {
    [NSApp activateIgnoringOtherApps:YES];
    VocitoPreferences *prefs = [[VocitoPreferences alloc] init];
    if ([NSApp runModalForWindow:[prefs window]] == NSRunStoppedResponse) {
      username = [ud stringForKey:UserNamePreferenceKey];
    }
    [prefs release];
  }
  if ([username length] == 0) {
    username = nil;
  }
  return username;
}

+ (void)setUpPreferenceDefaults {
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  ABAddressBook *addressBook = [ABAddressBook sharedAddressBook];
  ABPerson *me = [addressBook me];
  NSMutableArray *array = [NSMutableArray array];
  if (me) {
    ABMultiValue *phones = [me valueForProperty:kABPhoneProperty];
    unsigned count = [phones count];
    for (unsigned i = 0; i < count; ++i) {
      id value = [phones valueAtIndex:i];
      [array removeObject:value];
      [array addObject:value];
    }
    NSString *identifier = [phones primaryIdentifier];
    if (identifier) {
      unsigned idx = [phones indexForIdentifier:identifier];
      if (idx != NSNotFound) {
        id value = [phones valueAtIndex:idx];
        if (value) {
          [array removeObject:value];
          [array addObject:value];
        }
      }
    }
  }

  NSDictionary *registrationDictionary 
    = [NSDictionary dictionaryWithObjectsAndKeys:
       array, RecentlyDialledFromNumbersKey,
       nil];
  [ud registerDefaults:registrationDictionary];
}

+ (void)updateNumbers:(NSString*)number 
            recentKey:(NSString*)recentKey 
              lastKey:(NSString*)lastKey {
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  NSMutableArray *newRecents 
    = [[[ud objectForKey:recentKey] mutableCopy] autorelease];
  if ([newRecents containsObject:number]) {
    [newRecents removeObject:number];
  }
  [newRecents insertObject:number atIndex:0];
  if ([newRecents count] > 5) {
    [newRecents removeLastObject];
  }
  [ud setObject:newRecents forKey:recentKey];
  [ud setObject:number forKey:lastKey];
}  

+ (void)updateRecentlyDialledNumbers:(NSString*)number {
  [self updateNumbers:number 
            recentKey:RecentlyDialledNumbersKey 
              lastKey:LastDialledNumberKey];
}

+ (void)updateRecentlyDialledFromNumbers:(NSString*)number {
  [self updateNumbers:number 
            recentKey:RecentlyDialledFromNumbersKey 
              lastKey:LastDialledFromNumberKey];
}  

+ (NSString*)currentFromNumber {
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  return [ud stringForKey:LastDialledFromNumberKey];
}

+ (int)installedPluginVersion {
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  return [ud integerForKey:InstalledPlugInsVersionKey];
}

+ (void)updateInstalledPluginVersion {
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  [ud setInteger:[self currentPluginVersion]
          forKey:InstalledPlugInsVersionKey];
}

+ (int)currentPluginVersion {
  NSString *versionString 
    = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
  NSArray *values = [versionString componentsSeparatedByString:@"."];
  NSEnumerator *valueEnum = [values objectEnumerator];
  NSString *value;
  int multiplier = 1000000;
  int finalVersion = 0;
  while ((value = [valueEnum nextObject])) {
    finalVersion += [value intValue] * multiplier;
    multiplier /= 100;
  }
  return finalVersion;
}
@end
