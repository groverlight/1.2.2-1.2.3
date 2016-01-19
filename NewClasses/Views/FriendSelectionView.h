
//! \file   FriendSelectionView.h
//! \brief  UIView based class that show a list of friends and some other objects.
//__________________________________________________________________________________________________

#import <UIKit/UIKit.h>
#import "BaseView.h"
#import "Blocks.h"
#import "FriendSelectionList.h"
#import "FriendRecord.h"
#import "Parse.h"
#import "BDKCollectionIndexView.h"
//__________________________________________________________________________________________________

@class ParseUser;
extern NSMutableArray* recentListUsers;

//__________________________________________________________________________________________________

//! UIView based class that show a list of friends and some other objects.
@interface FriendSelectionView : BaseView
{
@public
   UILabel*              ListName;
  BlockAction           RefreshRequest;
 // BlockAction          AddFriendStarted;
  BlockIntAction        TouchTapped;
  BlockPointIntAction   TouchStarted;
  BlockPointIntAction   TouchEnded;
  BlockPointIntAction   ProgressCompleted;
  BlockPointIntAction   ProgressCancelled;
  BlockFloatBlockAction MoveParentByVerticalOffset;
  BlockAction           InviteButtonPressed;
  BlockAction           AddButtonPressed;
  BlockAction           EditionStarted;
  BlockAction           EditionEnded;
  BlockStringAction     EditedStringChanged;
  FriendSelectionList*  FriendsList;
}
//____________________

@property NSArray*  recentFriends;
@property NSArray*  allFriends;
@property BOOL      stateViewOnRight;
@property BOOL      showSectionHeaders;
@property BOOL      useBlankState;
@property BOOL      buttonsAreVisible;
@property BOOL      editorIsVisible;
@property BOOL      editorIsOnTop;
@property BOOL      useDotsVsState;
@property BOOL      simulateButton;
@property BOOL      addButtonEnabled;
@property CGFloat   topOffset;
@property BOOL      ignoreUnreadMessages;
@property NSInteger maxNumRecentFriends;

//____________________

- (void)updateFriendsLists;
//____________________

- (ParseUser*)getFriendAtIndex:(NSInteger)friendIndex;
//____________________
- (FriendRecord*)getRecordAtIndex:(NSInteger)friendIndex;
//____________________
- (void)clearSelection;
//____________________

- (void)clearEditor;
//____________________

@end
//__________________________________________________________________________________________________



