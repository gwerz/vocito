//
//  NSString+PhoneNumber.m
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

#import "NSString+PhoneNumber.h"


@implementation NSString (VocitoPhoneNumberExtension)
- (NSString*)vocito_cleanPhoneNumber {
  unsigned length = [self length];
  unichar *newNumber = calloc(sizeof(unichar), length);
  if (!newNumber) return nil;
  NSCharacterSet *decSet = [NSCharacterSet decimalDigitCharacterSet];
  unsigned i,j;
  for (i = 0, j = 0; i < length; ++i) {
    unichar uchar = [self characterAtIndex:i];
    if ([decSet characterIsMember:uchar]) {
      if (j == 0 && uchar == '1') {
        continue;
      }
      newNumber[j] = uchar;
      ++j;
    }
  }
  
  NSString *value = nil;
  if (j == 10) {
    value = [NSString stringWithCharacters:newNumber length:10];
  }
  free(newNumber);
  return value;
}
@end
