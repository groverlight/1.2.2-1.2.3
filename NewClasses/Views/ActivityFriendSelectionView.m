
//! \file   ActivityFriendSelectionView.m
//! \brief  UIView based class that show a list of friends and some other objects.
//__________________________________________________________________________________________________

#import "ActivityFriendSelectionView.h"
#import "FriendRecord.h"
#import "NetworkActivityView.h"
#import "GlobalParameters.h"
//__________________________________________________________________________________________________

//! UIView based class that show a list of friends and some other objects.
@implementation ActivityFriendSelectionView
{
  NetworkActivityView* NetworkActivityIndicator;
}
//____________________

//! Initialize the object however it has been created.
-(void)Initialize
{
  [super Initialize];
  GlobalParameters* parameters  = GetGlobalParameters();
  ListName.text                 = parameters.friendsActivityLabelTitle;
  self.stateViewOnRight         = NO;
  self.useBlankState            = YES;
  NetworkActivityIndicator      = [NetworkActivityView new];
    [self addSubview:NetworkActivityIndicator];
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

- (void)updateFriendsLists
{
    //NSLog(@"timesorted: %@", GetTimeSortedFriendRecords());
    self.recentFriends  = GetTimeSortedFriendRecords();
    self.allFriends = @[];
    [self->FriendsList setRecentFriends:self.recentFriends];
    //NSLog(@"recentFriends: %@", [FriendsList recentFriends]);
   // NSLog(@"this updated%lu", [FriendsList maxNumRecentFriends]);
   //NSLog(@"INITIATING OTHER SORT");
    //self.allFriends     = GetNameSortedFriendRecords(); // this makes all of the friends in the alphabetized
  
  [self->FriendsList ReloadTableData];
}
//__________________________________________________________________________________________________

- (void)setBusy:(BOOL)busy
{
  dispatch_async(dispatch_get_main_queue(), ^
  {
    if (busy)
    {
      [NetworkActivityIndicator showWithAnimation];
    }
    else
    {
      [NetworkActivityIndicator hideWithAnimation];
    }
  });
}
//__________________________________________________________________________________________________

- (BOOL)busy
{
  return (NetworkActivityIndicator.alpha != 0.0);
}
//__________________________________________________________________________________________________

@end
