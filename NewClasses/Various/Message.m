
//! \file   Message.m
//! \brief  The class that contains a message's texts and its snapshots.
//__________________________________________________________________________________________________

#import "Message.h"
#import "ParseUser.h"
//__________________________________________________________________________________________________

//! The class that contains a message's texts and its snapshots.
@implementation Message
{
//  NSString* FromObjectId;
//  NSString* ToObjectId;
}

- (id)init
{
  self = [super init];
  if (self != nil)
  {
    Snapshots = [NSMutableArray arrayWithCapacity:10];
  }
  return self;
}
//__________________________________________________________________________________________________

- (void)encodeWithCoder:(NSCoder*)coder
{
  [coder encodeObject:Snapshots     forKey:@"snapshots"     ];
  [coder encodeObject:Texts         forKey:@"texts"         ];
  [coder encodeDouble:Timestamp     forKey:@"timestamp"     ];
  [coder encodeObject:ParseObjectId forKey:@"parseObjectId" ];
  [coder encodeObject:FromObjectId  forKey:@"fromUser"      ];
  [coder encodeObject:ToObjectId    forKey:@"toUser"        ];
  [coder encodeObject:placeHolder   forKey:@"placeholder"   ];
  
}
//__________________________________________________________________________________________________

- (id)initWithCoder:(NSCoder*)coder
{
  self = [super init];
  if (self != nil)
  {
    Snapshots     = [coder decodeObjectForKey:@"snapshots"    ];
    Texts         = [coder decodeObjectForKey:@"texts"        ];
    Timestamp     = [coder decodeDoubleForKey:@"timestamp"    ];
    ParseObjectId = [coder decodeObjectForKey:@"parseObjectId"];
    FromObjectId  = [coder decodeObjectForKey:@"fromUser"     ];
    ToObjectId    = [coder decodeObjectForKey:@"toUser"       ];
    placeHolder   = [coder decodeObjectForKey:@"placeholder"  ];
    
  }
  return self;
}
//__________________________________________________________________________________________________

- (void)loadUsers:(BlockAction)completion
{
  [ParseUser findUserWithObjectId:FromObjectId completion:^(ParseUser* fromUser, NSError* fromError)
  {
    FromUser = fromUser;
    [ParseUser findUserWithObjectId:ToObjectId completion:^(ParseUser* toUser, NSError* toError)
    {
      ToUser = toUser;
//      NSLog(@"loadUsers FromUser: %@, ToUser: %@", FromUser.objectId, ToUser.objectId);
      completion();
    }];
  }];
}
//__________________________________________________________________________________________________

@end
//__________________________________________________________________________________________________
