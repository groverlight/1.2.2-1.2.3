
//! \file   AzFriendSelectionView.h
//! \brief  UIView based class that show a list of friends and some other objects.
//__________________________________________________________________________________________________

#import <UIKit/UIKit.h>
#import "BaseView.h"
#import "Blocks.h"
#import "FriendSelectionView.h"
//__________________________________________________________________________________________________

//! UIView based class that show a list of friends and some other objects.
@interface AzFriendSelectionView : FriendSelectionView
{
@public
  BlockAction AddFriendStarted;
  BlockAction FriendsAdded;
  BlockAction PleaseUpdateFriendLists;
}
//____________________

- (void)showMenuForFriendIndex:(NSInteger)friendIndex completion:(BlockAction)completion;
//____________________

- (void)clearPendingFriendsList;
//____________________

@end
//__________________________________________________________________________________________________
