//
//  VocitoCallAction.m
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

#import <Foundation/Foundation.h>
#import <QSCore/QSCore.h>
#import <AddressBook/AddressBook.h>
#import "NSString+PhoneNumber.h"

@interface VocitoCallAction : NSObject
- (NSString*)phoneNumberFromQSObject:(QSObject *)qsObject;
- (void)call:(QSObject *)inObject;
- (NSString*)actionName;
@end

@interface VocitoCallContactAction : VocitoCallAction
@end

@interface VocitoCallNumberAction : VocitoCallAction
@end

@implementation VocitoCallAction
- (NSString*)phoneNumberFromQSObject:(QSObject *)qsObject {
  return nil;
}

- (void)call:(QSObject *)inObject {
  NSString *number = [self phoneNumberFromQSObject:inObject];
  if (number) {
    NSString *scriptSource
      = [NSString stringWithFormat:@"tell application \"Vocito\" to dial \"%@\"", 
         number];
    NSDictionary *error = nil;
    NSAppleScript *script 
      = [[[NSAppleScript alloc] initWithSource:scriptSource] autorelease];
    [script executeAndReturnError:&error];
    if (error) {
      NSLog(@"Vocito QS Plugin Error: %@", error);
    }
  }
}

- (NSArray *)validActionsForDirectObject:(QSObject *)dObject 
                          indirectObject:(QSObject *)iObject {
  NSString *number = [self phoneNumberFromQSObject:dObject];
  return number ? [NSArray arrayWithObject:[self actionName]] : nil;
}

- (NSArray *)validIndirectObjectsForAction:(NSString *)action 
                              directObject:(QSObject *)dObject {
  return nil;
}

- (NSString*)actionName {
  return NSStringFromClass([self class]);
}

@end

@implementation VocitoCallContactAction

- (NSString*)phoneNumberFromQSObject:(QSObject *)qsObject {
  NSString *number = nil;
  NSString *abPersonUID = [qsObject objectForType:@"ABPeopleUIDsPboardType"];
  if (abPersonUID) {
    ABAddressBook *book = [ABAddressBook sharedAddressBook];
    ABRecord *record = [book recordForUniqueId:abPersonUID];
    ABMultiValue *multiValue = [record valueForProperty:kABPhoneProperty];
    if (multiValue) {
      NSString *identifier = [multiValue primaryIdentifier];
      unsigned int index = identifier ? [multiValue indexForIdentifier:identifier] : 0;
      number = [multiValue valueAtIndex:index];
    }
  }
  if (!number) {
    number = [NSString string];
  }
  return number;
}
@end

@implementation VocitoCallNumberAction

- (NSString*)phoneNumberFromQSObject:(QSObject *)qsObject {
  NSString *number = nil;
  NSString *string = [qsObject objectForType:@"NSStringPboardType"];
  if (string) {
    number = [string vocito_cleanPhoneNumber];
  }
  if (!number) {
    number = [NSString string];
  }  
  return number;
}
@end

