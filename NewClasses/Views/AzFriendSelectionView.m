
//! \file   AzFriendSelectionView.m
//! \brief  UIView based class that show a list of friends and some other objects.
//__________________________________________________________________________________________________

#import "AzFriendSelectionView.h"
#import <MessageUI/MessageUI.h>
#import "FriendRecord.h"
#import "GlobalParameters.h"
#import "Menu.h"
#import "NetworkActivityView.h"
#import "Parse.h"
#import "ParseBlocked.h"
#import "ParseUser.h"
#import "RollDownView.h"
#import "Tools.h"
#import "Mixpanel.h"
#import <AudioToolbox/AudioToolbox.h>
#import "Colors.h"
#import "FriendSelectionView.h"
//__________________________________________________________________________________________________

#define USE_AUTOSEARCH 1
//__________________________________________________________________________________________________

//! UIView based class that show a list of friends and some other objects.
@interface AzFriendSelectionView () <MFMessageComposeViewControllerDelegate>
{
}
@end
//__________________________________________________________________________________________________

//! UIView based class that show a list of friends and some other objects.
@implementation AzFriendSelectionView
{
  NetworkActivityView*  InviteBusyIndicator;
  NSMutableArray*       PotentialFriends;
  NSMutableArray*       PendingFriends;
  NSInteger             PendingCount;
  NSString*             EditedString;
  NSArray*              BlockedUsers;
  NSArray*              BlockingUsers;
  RollDownView*         RollDownErrorView;      //!< The roll down error message view.
  SystemSoundID           soundEffect;
  NSString *soundPath;
  NSURL *soundURL;



}
//____________________

//! Initialize the object however it has been created.
-(void)Initialize
{
  [super Initialize];
    //initialize sound path

  GlobalParameters* parameters  = GetGlobalParameters();
  ListName.text                 = parameters.friendsA_ZLabelTitle;
  self.stateViewOnRight         = YES;
  self.useBlankState            = NO;
  self.editorIsVisible          = YES;
  self.buttonsAreVisible        = YES;
  self.useDotsVsState           = YES;
  self.simulateButton           = YES;
  self.addButtonEnabled         = NO;
  self.ignoreUnreadMessages     = YES;
  PendingFriends                = [NSMutableArray arrayWithCapacity:10];
  RollDownErrorView             = [RollDownView        new];
  InviteBusyIndicator           = [NetworkActivityView new];
  [self addSubview:RollDownErrorView];
  [self addSubview:InviteBusyIndicator];


  AddFriendStarted = ^
  { // DefaultAction: do nothing!
  };

  FriendsAdded = ^
  { // DefaultAction: do nothing!
  };

  PleaseUpdateFriendLists = ^
  { // DefaultAction: do nothing!
  };

  set_myself;
  EditionStarted = ^
  {
    get_myself;
    myself->AddFriendStarted();
    [ParseBlocked loadBlockedUserList:GetCurrentParseUser() completion:^(NSArray* array, NSError* error)
    {
      BlockedUsers = array;
    }];
    [ParseBlocked loadBlockingUserList:GetCurrentParseUser() completion:^(NSArray* array, NSError* error)
    {
      BlockingUsers = array;
    }];
  };

  InviteButtonPressed = ^
  {
    get_myself;
    [myself inviteButtonPressed];
  };

  AddButtonPressed = ^
  {
    get_myself;
    [myself addButtonPressed];
  };

  EditedStringChanged = ^(NSString* editedString)
  {
    get_myself;
    [myself editedStringChanged:editedString];
  };

  EditionEnded = ^
  {
    get_myself;
    [myself->RollDownErrorView hide];
    myself->PendingCount = myself->PendingFriends.count;
    if (myself->PendingCount == 0)
    {
      myself->FriendsAdded();
    }
    else
    {
      for (FriendRecord* record in myself->PendingFriends)
      {
        UpdateFriendRecordListForUser(record.user, [NSDate date].timeIntervalSince1970);
        [GetCurrentParseUser() addFriend:record.user completion:^(BOOL value, NSError* error)
        {
          --myself->PendingCount;
          if (myself->PendingCount == 0)
          {
            RefreshAllFriends(^
            {
              [myself->PendingFriends removeAllObjects];
              myself->PotentialFriends = nil;
              myself->FriendsAdded();
              [myself updateFriendsLists];
            });
          }
        }];
      }
    }
  };
}
//__________________________________________________________________________________________________

- (void)dealloc
{
  [self cleanup];
}
//__________________________________________________________________________________________________

- (void)cleanup
{
}
//__________________________________________________________________________________________________

- (void)layoutSubviews
{
    
  [super layoutSubviews];
  RollDownErrorView.frame = CGRectMake(0, -self.topOffset, self.frame.size.width, [RollDownErrorView sizeThatFits:self.frame.size].height);
}
//__________________________________________________________________________________________________

- (void)updateFriendsLists
{
  if (self.editorIsOnTop)
  {
    NSMutableArray* array = [NSMutableArray arrayWithArray:PotentialFriends];
    [array addObjectsFromArray:PendingFriends];
    self.allFriends = array;
  }
  else
  {
      //NSLog(@"INITIATING SORT");
           // self.recentFriends  = @[];
      
      //NSLog(@"friends: %@", [[PFUser currentUser] objectForKey:@"friends"]);
      
            self.allFriends     =  GetNameSortedFriendRecords();
         //  NSLog(@"%@", GetNameSortedFriendRecords());
           // NSLog(@"current User:%@", [PFUser currentUser]);
           // NSLog(@"this is all friends: %@",self.allFriends);
      
     
   #if 0
    for (FriendRecord* record in self.allFriends)
    {
      NSLog(@"AzFriendSelectionView updateFriendsLists: username: %@, fullName: '%@', (%@)", record.user.username, record.fullName, record.user.fullName);
    }
#endif
  }
  [FriendsList ReloadTableData];
}
//__________________________________________________________________________________________________

// Action when the Invite button is pressed.
-(void)inviteButtonPressed
{

    NSLog(@"invitebuttonPressed");

    Mixpanel *mixpanel = [Mixpanel sharedInstance];

    [mixpanel track: @"invites"];

    [mixpanel identify:mixpanel.distinctId];

    [mixpanel.people increment:@"invites" by:[NSNumber numberWithInt:1]];

    soundPath = [[NSBundle mainBundle] pathForResource:@"button20"ofType:@"aiff"];
    soundURL = [NSURL fileURLWithPath:soundPath];
    AudioServicesCreateSystemSoundID(CFBridgingRetain(soundURL), &soundEffect);

    AudioServicesPlaySystemSound(soundEffect);


  GlobalParameters* parameters = GetGlobalParameters();
  if(![MFMessageComposeViewController canSendText])
  {
    parameters.findUserMessagingNotSupportedAction();

  }
  else
  {
      

    [InviteBusyIndicator showAnimated:YES];
    NSArray*  recipents = @[];
    NSString* message   = [NSString stringWithFormat:parameters.findUserMessagingSampleText, GetCurrentParseUser().username];

    MFMessageComposeViewController* messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    [messageController setRecipients:recipents];
    [messageController setBody:message];

    // Present message view controller on screen.
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:messageController animated:YES completion:^

     {
      [InviteBusyIndicator hideAnimated:YES];


    }];
  }
}
//__________________________________________________________________________________________________

// Action when the Add button is pressed.

-(void)addButtonPressed
{
    soundPath = [[NSBundle mainBundle] pathForResource:@"button20" ofType:@"aiff"];
    soundURL = [NSURL fileURLWithPath:soundPath];
    AudioServicesCreateSystemSoundID(CFBridgingRetain(soundURL), &soundEffect);

    AudioServicesPlaySystemSound(soundEffect);


  GlobalParameters* parameters = GetGlobalParameters();
  if (parameters.addFriendAutoSearch)
  {
    for (FriendRecord* potentialFriend in PotentialFriends)
    {
      BOOL found = NO;
      for (FriendRecord* pendingFriend in PendingFriends)
      {
  //      if ([potentialFriend.username isEqualToString:pendingFriend.username])
        if ([potentialFriend.user.objectId isEqualToString:pendingFriend.user.objectId])
        {
          found = YES;
          break;
        }
      }
      if (!found)
      {
          [recentListUsers addObject:potentialFriend];
        [PendingFriends addObject:potentialFriend];
      }
    }
    self.addButtonEnabled = NO;
  }
  else
  {
    [ParseUser findUsersWithUsername:EditedString completion:^(NSArray* users, NSError *error)
    {
      if ((error == nil) && (users.count > 0))
      {
        ParseUser* user = users.firstObject;
        if ([GetCurrentParseUser() isFriend:user])
        {
          [RollDownErrorView showWithTitle:parameters.addFriendRollDownViewTitle andMessage:parameters.AddFriendRollDownAlreadyFriendErrorMessage];
            soundPath = [[NSBundle mainBundle] pathForResource:@"rolldown10"ofType:@"aiff"];
            soundURL = [NSURL fileURLWithPath:soundPath];
            AudioServicesCreateSystemSoundID(CFBridgingRetain(soundURL), &soundEffect);
            AudioServicesPlaySystemSound(soundEffect);
            
        }
        else if (IsUserBlocked(user, BlockedUsers))
        {
          [RollDownErrorView showWithTitle:parameters.addFriendRollDownViewTitle andMessage:parameters.AddFriendRollDownBlockedFriendErrorMessage];
            soundPath = [[NSBundle mainBundle] pathForResource:@"rolldown10"ofType:@"aiff"];
            soundURL = [NSURL fileURLWithPath:soundPath];
            AudioServicesCreateSystemSoundID(CFBridgingRetain(soundURL), &soundEffect);
            AudioServicesPlaySystemSound(soundEffect);
        }
        else if (IsUserBlocking(user, BlockingUsers))
        {
          [RollDownErrorView showWithTitle:parameters.addFriendRollDownViewTitle andMessage:parameters.AddFriendRollDownBlockingUserErrorMessage];
            soundPath = [[NSBundle mainBundle] pathForResource:@"rolldown10"ofType:@"aiff"];
            soundURL = [NSURL fileURLWithPath:soundPath];
            AudioServicesCreateSystemSoundID(CFBridgingRetain(soundURL), &soundEffect);
            AudioServicesPlaySystemSound(soundEffect);

        }
        else if ([PendingFriends indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL* stop)
                 {
                   FriendRecord* friend = obj;
                   return [friend.user.objectId isEqualToString:user.objectId];
                 }] != NSNotFound)
        {
          [RollDownErrorView showWithTitle:parameters.addFriendRollDownViewTitle andMessage:parameters.AddFriendRollDownAlreadyPendingFriendErrorMessage];
            soundPath = [[NSBundle mainBundle] pathForResource:@"rolldown10"ofType:@"aiff"];
            soundURL = [NSURL fileURLWithPath:soundPath];
            AudioServicesCreateSystemSoundID(CFBridgingRetain(soundURL), &soundEffect);
            AudioServicesPlaySystemSound(soundEffect);
        }
        else
        {
          FriendRecord* record    = [FriendRecord new];
          record.user             = user;
          record.objectId         = user.objectId;
          record.fullName         = user.fullName;
          record.lastActivityTime = 0;
          [PendingFriends addObject:record];
          [self clearEditor];
          [self updateFriendsLists];
        }
      }
      else
      {
        [RollDownErrorView showWithTitle:parameters.addFriendRollDownViewTitle andMessage:parameters.AddFriendRollDownUnknownUsernameErrorMessage];
          soundPath = [[NSBundle mainBundle] pathForResource:@"rolldown10"ofType:@"aiff"];
          soundURL = [NSURL fileURLWithPath:soundPath];
          AudioServicesCreateSystemSoundID(CFBridgingRetain(soundURL), &soundEffect);
          AudioServicesPlaySystemSound(soundEffect);

          NSLog(@"WRONG USERNAME");
          Mixpanel *mixpanel = [Mixpanel sharedInstance];

          [mixpanel track:@"wrong username"];

          [mixpanel identify:mixpanel.distinctId];

          [mixpanel.people increment:@"wrong username" by:[NSNumber numberWithInt:1]];
      }
    }];
  }
}
//__________________________________________________________________________________________________

// Action when the edited text is changing.
-(void)editedStringChanged:(NSString*)editedString
{
   
  if (GetGlobalParameters().addFriendAutoSearch)
  {
    if ([editedString isEqualToString:@""])
    {
      PotentialFriends = nil;
      [self updateFriendsLists];
    }
    else
    {
      [ParseUser findUsersWithUsernameStartingWith:editedString completion:^(NSArray *array, NSError *error)
      {
        if (error == nil)
        {
          PotentialFriends = [NSMutableArray arrayWithCapacity:array.count];
          for (ParseUser* user in array)
          {
            if (![GetCurrentParseUser() isFriend:user] &&
                ([PendingFriends indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL* stop)
                 {
                   FriendRecord* friend = obj;
                   return [friend.user.objectId isEqualToString:user.objectId];
                 }] != NSNotFound))
            {
               
              FriendRecord* record    = [FriendRecord new];
              record.user             = user;
              record.objectId         = user.objectId;
              record.fullName         = user.fullName;
              record.lastActivityTime = 0;
              [PotentialFriends addObject:record];
            }
          }
          self.addButtonEnabled = (PotentialFriends.count > 0);
          [self updateFriendsLists];
        }
      }];
    }
  }
  else
  {
    EditedString          = editedString;
    PotentialFriends      = nil;
    self.addButtonEnabled = ![editedString isEqualToString:@""];
    [self updateFriendsLists];
    [RollDownErrorView hide];
  }
}
//__________________________________________________________________________________________________

- (void)messageComposeViewController:(MFMessageComposeViewController*)controller didFinishWithResult:(MessageComposeResult)result
{
  GlobalParameters* parameters = GetGlobalParameters();
  switch (result)
  {
  case MessageComposeResultCancelled:
    break;
  case MessageComposeResultSent:
    break;
  case MessageComposeResultFailed:
    parameters.findUserFailedToSendMessageAction();
    break;
  }
  [controller dismissViewControllerAnimated:YES completion:nil];
}
//__________________________________________________________________________________________________

- (void)removeFriend:(ParseUser*)friend
{
   
  [GetCurrentParseUser() removeFriend:friend completion:^(BOOL result, NSError *error)
  {
    LoadUnreadMessages(^(UnreadMessages* unreadMsgs)
    {
      ParseDeleteMessagesFromNoFriend(unreadMsgs);
    });
    ParseRemoveFriend(friend, ^(BOOL friendSuccess, NSError* friendError)
    {
      if (friendSuccess)
      {
          NSLog(@"REMOVED");
        ParseSendSilentPushNotificationToUser(friend.objectId);
      }
      RefreshAllFriends(^
      {
        PleaseUpdateFriendLists();
      });
    });
  }];
    NSMutableArray * contactsTemp = [[NSMutableArray alloc] init];
    NSString *fullName = friend.fullName;
    for (int i = 0; i < [recentListUsers count]; i++)
    {
        FriendRecord* contact = recentListUsers[i];
    
        if (![contact.fullName isEqualToString:fullName])
        {
            [contactsTemp addObject:contact];
        }
    }
   // NSLog(@"contactsTemp: ", contactsTemp);
    recentListUsers = contactsTemp;
}
//__________________________________________________________________________________________________

- (void)showMenuForFriendIndex:(NSInteger)friendIndex completion:(BlockAction)completion
{
  GlobalParameters* parameters = GetGlobalParameters();



    NSLog(@" this is where we get stuck %lu", friendIndex);
  ParseUser* friend = [self getFriendAtIndex:friendIndex];
    NSLog(@"%@", friend.fullName);
    NSLog(@" this is where we get stuck %lu", friendIndex);

    soundPath = [[NSBundle mainBundle] pathForResource:@"chime_blip_on"ofType:@"aif"];
    soundURL = [NSURL fileURLWithPath:soundPath];
    AudioServicesCreateSystemSoundID(CFBridgingRetain(soundURL), &soundEffect);

    AudioServicesPlaySystemSound(soundEffect);

  Menu* menu = [Menu menuWithTitle:friend.username andMessage:nil];
  NSInteger removeIndex = [menu addMenuButtonWithTitle:parameters.friendMenuRemoveFriendTitle];
  NSInteger blockIndex = [menu addMenuButtonWithTitle:parameters.friendMenuBlockFriendTitle];

  NSInteger cancelIndex = [menu addCancelMenuButton:parameters.friendMenuCancelTitle];
  [menu showWithCompletion:^(NSInteger actionIndex)
  {
    if (actionIndex == removeIndex)
    {
      NSLog(@"Friend menu returned 'Remove'");
      [self removeFriend:friend];
    }
    else if (actionIndex == blockIndex)
    {
      NSLog(@"Friend menu returned 'Block'");
      [ParseBlocked blockAFriend:friend forReason:parameters.blockedUserReasonMessage completion:^(BOOL result, NSError *error)
      {
        NSLog(@"User: '%@' has been blocked with error: %@", friend.fullName, error);

          Mixpanel *mixpanel = [Mixpanel sharedInstance];

          [mixpanel track:@"friends blocked"];

          [mixpanel identify:mixpanel.distinctId];

          [mixpanel.people increment:@"friends blocked" by:[NSNumber numberWithInt:1]];

      }];
      [self removeFriend:friend];
    }
    else if (actionIndex == cancelIndex)
    {
      NSLog(@"Friend menu returned 'Cancel'");

    }
    else
    {
      NSLog(@"Friend menu returned unsupported action index: %d!", (int)actionIndex);
    }
    completion();
  }];
}
//__________________________________________________________________________________________________

- (void)clearPendingFriendsList
{
  [PendingFriends removeAllObjects];
  PotentialFriends = nil;
}
//__________________________________________________________________________________________________

@end
