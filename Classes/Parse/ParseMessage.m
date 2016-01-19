
//! \file   ParseMessage.m
//! \brief  Parse class containing data about a message object.
//__________________________________________________________________________________________________

#import <Parse/PFObject+Subclass.h>

#import "ParseMessage.h"
//__________________________________________________________________________________________________

//! Parse class containing data about an animation object.
@implementation ParseMessage
{
}
@dynamic time;
@dynamic texts;
@dynamic snapshots;
@dynamic fromUser;
@dynamic toUser;
@dynamic action;
@dynamic placeHolder;
//____________________

+ (void)load
{
  [self registerSubclass];
}
//__________________________________________________________________________________________________

//! Get the Parse class name.
+ (NSString *)parseClassName
{
  return @"ParseMessage";
}
//__________________________________________________________________________________________________

- (void)dealloc
{
}
//__________________________________________________________________________________________________

+ (void)QueryUnplayedMessagesWithCompletion:(BlockArrayErrorAction)completion
{
  ParseUser* user = GetCurrentParseUser();
  if (user != nil)
  {
    PFQuery* query = [ParseMessage query];
    [query whereKey:@"toUser" equalTo:user];
    [query findObjectsInBackgroundWithBlock:^(NSArray* messages, NSError* error)
    {
#if 0
      NSLog(@"Num unplayed messages: %d", (int)messages.count);
      for (PFObject* obj in messages)
      {
        NSLog(@"Obj: %@", obj);
      }
#endif
      completion(messages, error);
    }];
  }
  else
  {
    completion(nil, [NSError errorWithDomain:@"Typeface" code:-10 userInfo:nil]);
  }
}
//__________________________________________________________________________________________________

@end
//__________________________________________________________________________________________________
