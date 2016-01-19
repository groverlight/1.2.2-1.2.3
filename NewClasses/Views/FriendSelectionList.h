
//! \file   FriendSelectionList.h
//! \brief  UIView based class that let select a friend in a list.
//__________________________________________________________________________________________________

#import <UIKit/UIKit.h>
#import "Blocks.h"
#import "TableView.h"
//__________________________________________________________________________________________________

//! UIView based class that let select a friend in a list.
@interface FriendSelectionList : TableView <UITableViewDelegate>
{
@public
  BlockAction         RefreshRequest;
  BlockIntAction      TouchTapped;
  BlockPointIntAction TouchStarted;
  BlockPointIntAction TouchEnded;
  BlockPointIntAction ProgressCancelled;
  BlockPointIntAction ProgressCompleted;
  BOOL                StateViewHidden;
  BOOL                StateViewOnRight;
  BOOL                ShowSectionHeaders;
  BOOL                UseBlankState;
  BOOL                UseDotsVsState;
  BOOL                SimulateButton;
  BOOL                IgnoreUnreadMessages;
NSMutableArray* arrayOfPeopleInSection;
NSMutableArray* arrayOfSectionTitles;
  NSArray* indexTitles;
  NSInteger indexForList;
}
//____________________

@property NSArray*  recentFriends;
@property NSArray*  allFriends;
@property NSInteger maxNumRecentFriends;
//____________________

- (void)clearSelection;
-(NSInteger) getIndex:(NSInteger)tableSection and:(NSInteger)tableRow;
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
//____________________

@end
//__________________________________________________________________________________________________
