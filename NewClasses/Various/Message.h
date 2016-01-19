
//! \file   Message.h
//! \brief  The class that contains a message's texts and its snapshots.
//__________________________________________________________________________________________________

#import <UIKit/UIKit.h>
#import "Blocks.h"
//__________________________________________________________________________________________________

@class ParseUser;
//__________________________________________________________________________________________________

//! The class that contains a message's texts and its snapshots.
@interface Message: NSObject <NSCoding>
{
@public
  NSMutableArray* Snapshots;        //!< The snapshot images linked to this message.
  NSArray*        Texts;            //!< The texts linked to this message.
  NSTimeInterval  Timestamp;        //!< The message's creation timestamp.
  NSString*       ParseObjectId;    //!< The object ID of this message. It is nil when sending message.
  NSString*       FromObjectId;     //!> The objectId of the sender user;
  NSString*       ToObjectId;       //!> The objectId of the receiver user;
  NSString*       placeHolder;
  ParseUser*      FromUser;         //!< The sender user.
  ParseUser*      ToUser;           //!< The receiver user.
}
//____________________

- (void)loadUsers:(BlockAction)completion;
//__________________________________________________________________________________________________

@end
//__________________________________________________________________________________________________
