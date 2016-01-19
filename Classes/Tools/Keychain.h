
//! \file   Keychain.h
//! \brief  Secure storage of data into the system keychain.
//__________________________________________________________________________________________________

#import <Foundation/Foundation.h>
//__________________________________________________________________________________________________

//! Secure storage of data into the system keychain.
@interface Keychain : NSObject
{
}
//____________________

- (id)initWithService:(NSString*)service;                 //!< Initialize the object with a service.

- (BOOL)insertKey:(NSString*)key withData:(NSData*)data;  //!< Insert a key in the keychain.
- (BOOL)updateKey:(NSString*)key withData:(NSData*)data;  //!< Update the content of a key.
- (BOOL)removeKey:(NSString*)key;                         //!< Remove a key from the keychain.
- (NSData*)findKey:(NSString*)key;                        //!< Find a key in the keychain.
@end
//__________________________________________________________________________________________________

