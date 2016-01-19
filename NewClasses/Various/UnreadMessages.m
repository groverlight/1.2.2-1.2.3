
//! \file   UnreadMessages.m
//! \brief  The class that contains all the currently unread messages.
//__________________________________________________________________________________________________

#import "UnreadMessages.h"
#import "Message.h"
#import "ParseUser.h"
//__________________________________________________________________________________________________

static UnreadMessages*  SharedUnreadMessages = nil;
static dispatch_queue_t Queue;
//__________________________________________________________________________________________________

//! Load the shared (singleton) unread messages list from a file.
static void LoadSharedUnreadMessagesFromFile(UnreadMessages* unread, BlockAction completion)
{
//  NSLog(@"1 LoadSharedUnreadMessagesFromFile");
  NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
  NSString* cacheDirectory = [paths objectAtIndex:0];
  NSString* fileName;
  [unread->Messages removeAllObjects];
  fileName = [cacheDirectory stringByAppendingPathComponent:@"unreadMessagesList.plist"];
//  NSLog(@"LoadSharedUnreadMessagesFromFile: '%@'", fileName);
  [unread->Messages addObjectsFromArray:[NSKeyedUnarchiver unarchiveObjectWithFile:fileName]];
  for (Message* msg in unread->Messages)
  {
    fileName = [cacheDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"unreadMessage_%@.plist", msg->ParseObjectId]];
//    NSLog(@"LoadSharedUnreadMessagesFromFile: snapshots: '%@'", fileName);
    msg->Snapshots = [NSKeyedUnarchiver unarchiveObjectWithFile:fileName];
  }
//  NSLog(@"2 LoadSharedUnreadMessagesFromFile %d", (int)unread->Messages.count);
  static NSInteger pendingCount = 0;
  for (Message* msg in unread->Messages)
  {
//    NSLog(@"3 LoadSharedUnreadMessagesFromFile");
    ++pendingCount;
    [msg loadUsers:^
    {
      --pendingCount;
      if (pendingCount == 0)
      {
//        NSLog(@"4 LoadSharedUnreadMessagesFromFile");
        completion();
      }
    }];
  }
  if (pendingCount == 0)
  {
    completion();
  }
//  NSLog(@"5 LoadSharedUnreadMessagesFromFile");
}
//__________________________________________________________________________________________________

//! Get the shared (singleton) UnreadMessages object.
UnreadMessages* GetSharedUnreadMessages(void)
{
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^
  {
    Queue = dispatch_queue_create("GetSharedUnreadMessages", DISPATCH_QUEUE_CONCURRENT);
    SharedUnreadMessages = [UnreadMessages new];
  });
  return SharedUnreadMessages;
}
//__________________________________________________________________________________________________

//! Get the shared (singleton) UnreadMessages object, wait until loaded.
void LoadUnreadMessages(BlockIdAction unreadMessages)
{
  UnreadMessages* unread = GetSharedUnreadMessages();
  [unread load:^
  {
//    NSLog(@"unread: %p", unread);
    for (int i = 0; i < unread->Messages.count; ++i)
    {
//      NSLog(@"  %2d: %p", i, [unread->Messages objectAtIndex:i]);
    }
    unreadMessages(unread);
  }];
}
//__________________________________________________________________________________________________

//! The messages array has changed. Save it and notify the player.
void LocallySaveMessageArray(void)
{
  UnreadMessages* messages = GetSharedUnreadMessages();
  NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
  NSString* cacheDirectory = [paths objectAtIndex:0];
  NSString* fileName;
//  NSLog(@"1 LocallySaveMessageArray");
  NSMutableArray* allMessages = [NSMutableArray arrayWithCapacity:messages->Messages.count];
  for (Message* msg in messages->Messages)
  {
    Message* message = [Message new];
    message->Texts            = msg->Texts;
    message->Timestamp        = msg->Timestamp;
    message->ParseObjectId    = msg->ParseObjectId;
    message->FromObjectId     = msg->FromObjectId;
    message->ToObjectId       = msg->ToObjectId;
    [allMessages addObject:message];
  }
  fileName = [cacheDirectory stringByAppendingPathComponent:@"unreadMessagesList.plist"];
//  NSLog(@"2 LocallySaveMessageArray: '%@'", fileName);
  [NSKeyedArchiver archiveRootObject:allMessages toFile:fileName];
//  NSLog(@"3 LocallySaveMessageArray");
  for (Message* msg in messages->Messages)
  {
    fileName = [cacheDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"unreadMessage_%@.plist", msg->ParseObjectId]];
//    NSLog(@"4 LocallySaveMessageArray: snapshots: '%@'", fileName);
    if (![[NSFileManager defaultManager] fileExistsAtPath:fileName])
    {
//      NSLog(@"5 LocallySaveMessageArray");
      [NSKeyedArchiver archiveRootObject:msg->Snapshots toFile:fileName];
//      NSLog(@"6 LocallySaveMessageArray");
    }
  }
//  NSLog(@"7 LocallySaveMessageArray");
}
//__________________________________________________________________________________________________

//! The class that contains all the currently unread messages.
@implementation UnreadMessages
{
}
//____________________

- (id)init
{
  self = [super init];
  if (self != nil)
  {
    Messages = [NSMutableArray arrayWithCapacity:10];
  }
  return self;
}
//__________________________________________________________________________________________________

- (void)clear
{
  [Messages removeAllObjects];
}
//__________________________________________________________________________________________________

- (void)load:(BlockAction)completion
{
  LoadSharedUnreadMessagesFromFile(self, ^
  {
    completion();
  });
}
//__________________________________________________________________________________________________

- (Message*)getFirstMessageFromUser:(ParseUser*)fromUser
{
//  NSLog(@"getFirstMessageFromUser: %@", fromUser.objectId);
  for (Message* msg in Messages)
  {
//    NSLog(@"%@", msg->FromUser.objectId);
    if ([msg->FromObjectId isEqualToString:fromUser.objectId])
    {
//      NSLog(@"Found!");
      return msg;
    }
  }
//  NSLog(@"Not found!");
  return nil;
}
//__________________________________________________________________________________________________

- (void)deleteMessage:(Message*)msg
{
  [Messages removeObject:msg];
  NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
  NSString* cacheDirectory = [paths objectAtIndex:0];
  NSString* fileName;
  fileName = [cacheDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"unreadMessage_%@.plist", msg->ParseObjectId]];
  NSError* error;
  [[NSFileManager defaultManager] removeItemAtPath:fileName error:&error];
  LocallySaveMessageArray();
}
//__________________________________________________________________________________________________

@end
//__________________________________________________________________________________________________
