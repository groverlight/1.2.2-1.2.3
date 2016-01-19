
//! \file   SendToFriendSelectionView.m
//! \brief  UIView based class that show a list of friends and some other objects.
//__________________________________________________________________________________________________

#import "SendToFriendSelectionView.h"
#import "FriendRecord.h"
#import "GlobalParameters.h"
#import "ParseUser.h"
#import "FriendSelectionView.h"
#import "VideoViewController.h"
#import "BDKCollectionIndexView.h"
#import "Colors.h"
//__________________________________________________________________________________________________

//! UIView based class that show a list of friends and some other objects.

@implementation SendToFriendSelectionView

{
    NSInteger SelectedFriend;
    UITableView *tableView;
    NSMutableArray *sectionTitles;
    NSMutableArray *sectionPeople;
    NSMutableArray *person;
    BDKCollectionIndexView *indexView;
    NSArray * indexTitles;
}

//____________________

//! Initialize the object however it has been created.
-(void)Initialize
{
    [super Initialize];
    indexView.delegate = self;
  self.clipsToBounds = NO;
  GlobalParameters* parameters  = GetGlobalParameters();
  ListName.text                 = parameters.friendsSendToLabelTitle;
  self.showSectionHeaders       = YES;
  self.useBlankState            = NO;
  self.ignoreUnreadMessages     = YES;
  self.maxNumRecentFriends      = GetGlobalParameters().friendsMaxRecentFriends;

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


- (void)updateFriendsLists // this is where I edit the index list.
{
    NSLog(@"updated");
if ([indexTitles count] != 27)
{
    indexTitles = @[@"💛", @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z"];
    self->indexView = [BDKCollectionIndexView indexViewWithFrame:CGRectMake(self.window.width-28,self.window.height/6,28,self.window.height-self.window.height/6) indexTitles:nil]; // Roast Beef
    
    self->indexView = [self->indexView initWithFrame:CGRectMake(self.window.width-28,self.window.height,28,self.window.height) indexTitles: indexTitles];
   //NSLog(@"INDEX VIEW FRAME2: %@", NSStringFromCGRect(self->indexView.frame));
    self->indexView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:self->indexView];
    //[self bringSubviewToFront:self->indexView];
}
  self.recentFriends  = GetTimeSortedFriendRecords();
   // NSLog(@"contacts: %@", recentListUsers);
    [recentListUsers sortUsingComparator:^NSComparisonResult(id obj1, id obj2)
     {
         FriendRecord* record1 = (FriendRecord*)obj1;
         FriendRecord* record2 = (FriendRecord*)obj2;
         
         return ([record1.fullName caseInsensitiveCompare:record2.fullName]);
     }];
    NSMutableArray *uniqueArray = [NSMutableArray array];
    NSMutableSet *names = [NSMutableSet set];
    for (FriendRecord* record in recentListUsers) {
        NSString *destinationName = record.fullName;
        if (![names containsObject:destinationName]) {
            [uniqueArray addObject:record];
            [names addObject:destinationName];
        }
    }
    recentListUsers = uniqueArray;
    self.allFriends     = recentListUsers;
  self->FriendsList.contentOffset = CGPointMake(0, 0- FriendsList.contentInset.top);
dispatch_async(dispatch_get_main_queue(), ^{
  [self->FriendsList ReloadTableData];
});
  [indexView addTarget:self action:@selector(indexViewValueChanged:) forControlEvents:UIControlEventValueChanged];


}

//__________________________________________________________________________________________________
- (void)indexViewValueChanged:(BDKCollectionIndexView *)sender {
  // NSLog(@"indexView.currentIndex %lu", indexView.currentIndex);
   //NSLog(@"Array of Section Titles: %lu",[self->FriendsList->arrayOfSectionTitles indexOfObject:[indexTitles objectAtIndex:indexView.currentIndex]]);
    [self->FriendsList reloadData];
    [self->FriendsList layoutIfNeeded];
    if (self->FriendsList->arrayOfSectionTitles != nil)
    {
        NSInteger listIndex =[self->FriendsList->arrayOfSectionTitles indexOfObject:[indexTitles objectAtIndex:indexView.currentIndex]];
        NSLog(@"%lu", listIndex);
        NSIndexPath *path = [NSIndexPath indexPathForItem:0 inSection:listIndex];
        if (listIndex < 100)
                if (([self->FriendsList numberOfSectionsInTableView:self->FriendsList] > path.section) &&
                    ([self->FriendsList numberOfRowsInSection:listIndex] > path.row))
                {

                
       //self->FriendsList->indexForList = indexView.currentIndex;
            [self->FriendsList scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionNone animated:NO];
                }
    }

}

@end
