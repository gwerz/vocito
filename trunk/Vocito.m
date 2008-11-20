//
//  Vocito.m
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

#import "Vocito.h"
#import "EMKeychainProxy.h"
#import "GTMNSString+URLArguments.h"
#import "NSString+PhoneNumber.h"

static NSString *const kServer = @"www.grandcentral.com";
static NSString *const kProtocol = @"https";
static NSString *const kLoginString 
  = @"%@://%@/account/login?account[username]=%@&account[password]=%@";
static NSString *const kDialString
  = @"%@://%@/calls/send_call_request?a_t=%@&calltype=call&destno=%@&ani=%@";
NSString *const VocitoErrorDomain = @"VocitoErrorDomain";

@interface Vocito (VocitoPrivate)
- (void)logError:(NSError *)error;
- (NSString *)passwordForName:(NSString *)name;
- (void)initiateLoginWithName:(NSString *)name password:(NSString*)password;
@end

@interface VocitoURLConnectionDelegate : NSObject {
  id delegate_;
  Vocito *dialer_;
  NSURL *url_;
  NSMutableString *source_;
}
- (id)initWithDialer:(Vocito *)dialer
                  url:(NSURL *)url
             delegate:(id)delegate;
- (void)logErrorWithCode:(int)code;
- (NSHTTPCookie*)loginCookie;
- (void)deleteLoginCookie;
@end
  
@interface VocitoLogin : VocitoURLConnectionDelegate
@end

@interface VocitoConnect : VocitoURLConnectionDelegate
@end

@implementation VocitoURLConnectionDelegate
- (id)initWithDialer:(Vocito *)dialer
                  url:(NSURL *)url
             delegate:(id)delegate {
  if ((self = [super init])) {
    delegate_ = delegate;
    dialer_ = [dialer retain];
    url_ = [url retain];
    source_ = [[NSMutableString alloc] init];
    if (!dialer_ || !url) {
      [self release];
      self = nil;
    }
  }
  return self;
}

- (void)dealloc {
  [url_ release];
  [dialer_ release];
  [source_ release];
  [super dealloc];
}

- (NSHTTPCookie*)loginCookie {
  NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
  NSString *serverString = [NSString stringWithFormat:@"%@://%@", 
                            kProtocol, kServer];
  NSArray *cookies = [storage cookiesForURL:[NSURL URLWithString:serverString]];
  NSEnumerator *cookieEnum = [cookies objectEnumerator];
  NSHTTPCookie *cookie = nil;
  while ((cookie = [cookieEnum nextObject])) {
    if ([[cookie name] isEqualToString:@"a_t"]) {
      break;
    }
  }
  return cookie;
}

- (void)deleteLoginCookie {
  NSHTTPCookie *cookie = [self loginCookie];
  if (cookie) {
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    [storage deleteCookie:cookie];
  }
}

- (void)logErrorWithCode:(int)code {
  NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
                        url_, NSErrorFailingURLStringKey,
                        nil];
  NSError *error = [NSError errorWithDomain:NSURLErrorDomain
                                       code:code 
                                   userInfo:info];
  [dialer_ logError:error];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
  NSString *dataString = [[[NSString alloc] initWithData:data
                                                encoding:NSUTF8StringEncoding]
                          autorelease];
  [source_ appendString:dataString];
}

- (void)connection:(NSURLConnection *)connection 
    didFailWithError:(NSError *)error {
  NSLog(@"Error: %@", source_);
  [self deleteLoginCookie];
  [dialer_ logError:error];
  [self autorelease];
}

-(NSURLRequest *)connection:(NSURLConnection *)connection
            willSendRequest:(NSURLRequest *)request
           redirectResponse:(NSURLResponse *)redirectResponse {
  NSMutableURLRequest *newRequest = [[request mutableCopy] autorelease];
  [newRequest setCachePolicy:NSURLRequestReloadIgnoringCacheData];
  return newRequest;
}

@end

@implementation VocitoLogin

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
  NSHTTPCookie *cookie = [self loginCookie];
  NSString *atValue = [cookie value];
  if (atValue) {
    if ([delegate_ respondsToSelector:@selector(dialerDidLogin:)]) {
      [delegate_ dialerDidLogin:dialer_];
    }
    if ([dialer_ toPhoneNumber] && [dialer_ fromPhoneNumber]) {
      NSString *urlString 
        = [NSString stringWithFormat:kDialString, kProtocol, kServer, atValue, 
           [dialer_ toPhoneNumber], [dialer_ fromPhoneNumber]];
      NSURL *url = [NSURL URLWithString:urlString];
      NSURLRequest *request 
        = [NSURLRequest requestWithURL:url
                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                       timeoutInterval:30];
      VocitoConnect *conn 
        = [[VocitoConnect alloc] initWithDialer:dialer_ 
                                                   url:url
                                              delegate:delegate_];
      [[NSURLConnection connectionWithRequest:request delegate:conn] retain];
    }
  } else {
    NSLog(@"Error: %@", source_);
    NSString *invalidPassword 
      = NSLocalizedString(@"Invalid Password. Please set your user name "
                          @"and password in the preferences.", nil);
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                              invalidPassword, NSLocalizedDescriptionKey,
                              nil];
    NSError *error = [NSError errorWithDomain:VocitoErrorDomain 
                                         code:VocitoErrorBadPassword 
                                     userInfo:userInfo];
    [dialer_ logError:error];
  }
  [self autorelease];
  [connection autorelease];
}

@end

@implementation VocitoConnect
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
  if ([delegate_ respondsToSelector:@selector(dialerDidDial:)]) {
    [delegate_ dialerDidDial:dialer_];
  }
  [self deleteLoginCookie];
  [self autorelease];
  [connection autorelease];
}
@end

@implementation Vocito : NSObject
- (id)initWithDelegate:(id)delegate { 
  if ((self = [super init])) {
    delegate_ = delegate;
  }
  return self;
}

- (void)dealloc {
  [toPhoneNumber_ release];
  [fromPhoneNumber_ release];
  [super dealloc];
}

+ (NSString*)serverName {
  return kServer;
}

- (void)verifyName:(NSString *)name password:(NSString*)password {
  [self initiateLoginWithName:name
                     password:password];
}

- (void)callPhone:(NSString *)toPhoneNumber 
        fromPhone:(NSString *)fromPhoneNumber
          forUser:(NSString *)username {
  NSString *password = [self passwordForName:username];
  if (!password) {
    NSString *invalidPassword = NSLocalizedString(@"Invalid Password. Please set"
                                                  @" your user name and password"
                                                  @" in the preferences.", nil);
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                              invalidPassword, NSLocalizedDescriptionKey,
                              nil];
    [self logError:[NSError errorWithDomain:VocitoErrorDomain 
                                       code:VocitoErrorBadPassword 
                                   userInfo:userInfo]];
    return;
  }

  toPhoneNumber_ = [[toPhoneNumber vocito_cleanPhoneNumber] retain];
  if (!toPhoneNumber_) {
    NSString *errorFormat = NSLocalizedString(@"The number you are calling (%@) "
                                              @"is not a valid number. Please "
                                              @"make sure that you have a three "
                                              @"digit area code and a seven "
                                              @"digit phone number "
                                              @"(222-222-2222)", nil);
    NSString *errorString = [NSString stringWithFormat:errorFormat, 
                             toPhoneNumber];
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                              errorString, NSLocalizedDescriptionKey,
                              nil];
    [self logError:[NSError errorWithDomain:VocitoErrorDomain 
                                       code:VocitoErrorBadToNumber 
                                   userInfo:userInfo]];
    return;
  }
  
  fromPhoneNumber_ = [[fromPhoneNumber vocito_cleanPhoneNumber] retain];
  if (!fromPhoneNumber_) {
    NSString *errorFormat 
      = NSLocalizedString(@"The number you are calling from (%@) is not a valid "
                          @"number. Please make sure that you have a three "
                          @"digit area code and a seven digit phone number "
                          @"(222-222-2222)", nil);
    NSString *errorString = [NSString stringWithFormat:errorFormat, 
                             fromPhoneNumber];
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                              errorString, NSLocalizedDescriptionKey,
                              nil];
    [self logError:[NSError errorWithDomain:VocitoErrorDomain 
                                       code:VocitoErrorBadFromNumber 
                                   userInfo:userInfo]];
    return;
  }
  [self initiateLoginWithName:username password:password];
}

- (NSString*)toPhoneNumber {
  return toPhoneNumber_;
}

- (NSString*)fromPhoneNumber {
  return fromPhoneNumber_;
}

@end

@implementation Vocito (VocitoPrivate)
- (void)logError:(NSError *)error {
  if ([delegate_ respondsToSelector:@selector(dialer:didFailWithError:)]) {
    [delegate_ dialer:self didFailWithError:error];
  }  
}

- (NSString *)passwordForName:(NSString *)name {
  NSString *password = nil;
  EMKeychainProxy *keychain = [EMKeychainProxy sharedProxy];
  EMInternetKeychainItem *keychainItem 
    = [keychain internetKeychainItemForServer:kServer
                                 withUsername:name
                                       path:@""
                                         port:0
                                     protocol:kSecProtocolTypeHTTPS];
  
  if (keychainItem) {
    password = [keychainItem password];
  }
  return password;
}

- (void)initiateLoginWithName:(NSString *)name
                     password:(NSString*)password {
  NSString *cleanUserName = [name gtm_stringByEscapingForURLArgument];
  NSString *cleanPassword = [password gtm_stringByEscapingForURLArgument];
  
  NSString *urlString = [NSString stringWithFormat:kLoginString, kProtocol, 
                         kServer, cleanUserName, cleanPassword];
  NSURL *url = [NSURL URLWithString:urlString];
  NSMutableURLRequest *loginRequest 
  = [NSMutableURLRequest requestWithURL:url
                            cachePolicy:NSURLRequestReloadIgnoringCacheData
                        timeoutInterval:30];
  [loginRequest setHTTPMethod:@"POST"];
  VocitoLogin *conn = [[VocitoLogin alloc] initWithDialer:self
                                                      url:url
                                                 delegate:delegate_];
  [[NSURLConnection connectionWithRequest:loginRequest delegate:conn] retain];
}

@end

