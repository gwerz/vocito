//
//  Vocito.h
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

extern NSString *const VocitoErrorDomain;
enum {
  VocitoErrorBadPassword = 10000,
  VocitoErrorBadToNumber,
  VocitoErrorBadFromNumber
};

@interface Vocito : NSObject {
 @private
  id delegate_;
  NSString *username_;
  NSString *toPhoneNumber_;
  NSString *fromPhoneNumber_;
}

+ (NSString*)serverName;
- (id)initWithUser:(NSString*)user
          delegate:(id)delegate;
- (void)callPhone:(NSString*)toPhoneNumber 
        fromPhone:(NSString*)fromPhoneNumber;
- (NSString*)toPhoneNumber;
- (NSString*)fromPhoneNumber;
@end

@interface NSObject (VocitoDelegate)
- (void)dialerDidLogin:(Vocito *)dialer;
- (void)dialerDidDial:(Vocito *)dialer;
- (void)dialer:(Vocito *)dialer didFailWithError:(NSError *)error;
@end
