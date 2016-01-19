
//! \file   Keychain.mm
//! \brief  Secure storage of data into the system keychain.
//__________________________________________________________________________________________________

#import <Security/Security.h>

#import "Keychain.h"
//__________________________________________________________________________________________________

//! Secure storage of data into the system keychain.
@interface Keychain()
{
  NSString* Service;  //!< The service associated with this keychain.
}
@end
//__________________________________________________________________________________________________

//! Secure storage of data into the system keychain.
@implementation Keychain

- (id)initWithService:(NSString*)service
{
  self =[super init];
  if (self != nil)
  {
    Service = [NSString stringWithString:service];
  }
  return  self;
}
//__________________________________________________________________________________________________

- (NSMutableDictionary*)prepareDict:(NSString*)key
{

  NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
  [dict setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];

  NSData* encodedKey = [key dataUsingEncoding:NSUTF8StringEncoding];
  [dict setObject:encodedKey forKey:(__bridge id)kSecAttrGeneric];
  [dict setObject:encodedKey forKey:(__bridge id)kSecAttrAccount];
  [dict setObject:Service forKey:(__bridge id)kSecAttrService];
  [dict setObject:(__bridge id)kSecAttrAccessibleAlwaysThisDeviceOnly forKey:(__bridge id)kSecAttrAccessible];
  return  dict;
} 
//__________________________________________________________________________________________________

- (BOOL)insertKey:(NSString*)key withData:(NSData*)data
{
  NSMutableDictionary* dict = [self prepareDict:key];
  [dict setObject:data forKey:(__bridge id)kSecValueData];

  OSStatus status = SecItemAdd((__bridge CFDictionaryRef)dict, NULL);
  if (errSecSuccess != status)
  {
    NSLog(@"Unable add item with key =%@ error:%ld", key, (long)status);
  }
  return (errSecSuccess == status);
}
//__________________________________________________________________________________________________

- (NSData*)findKey:(NSString*)key
{
  NSMutableDictionary* dict = [self prepareDict:key];
  [dict setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
  [dict setObject:(id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
  CFTypeRef result = NULL;
  OSStatus  status = SecItemCopyMatching((__bridge CFDictionaryRef)dict,&result);

  if (status != errSecSuccess)
  {
    NSLog(@"Unable to fetch item for key %@ with error:%ld", key, (long)status);
    return nil;
  }
  return (__bridge NSData*)result;
}
//__________________________________________________________________________________________________

- (BOOL)updateKey:(NSString *)key withData:(NSData *)data
{
  NSMutableDictionary* dictKey    = [self prepareDict:key];
  NSMutableDictionary* dictUpdate = [[NSMutableDictionary alloc] init];
  [dictUpdate setObject:data forKey:(__bridge id)kSecValueData];

  OSStatus status = SecItemUpdate((__bridge CFDictionaryRef)dictKey, (__bridge CFDictionaryRef)dictUpdate);
  if (errSecSuccess != status)
  {
    NSLog(@"Unable add update with key =%@ error:%ld", key, (long)status);
  }
  return (errSecSuccess == status);
}
//__________________________________________________________________________________________________

- (BOOL)removeKey:(NSString *)key
{
  NSMutableDictionary*  dict    = [self prepareDict:key];
  OSStatus              status  = SecItemDelete((__bridge CFDictionaryRef)dict);
  if ( status != errSecSuccess)
  {
    NSLog(@"Unable to remove item for key %@ with error:%ld", key, (long)status);
  }
  return (errSecSuccess == status);
}
//__________________________________________________________________________________________________

@end
//__________________________________________________________________________________________________
