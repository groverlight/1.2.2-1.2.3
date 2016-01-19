
//! \file   CardNavigationOverlayView.h
//! \brief  BaseView based class that manages the navigation between the main views.
//__________________________________________________________________________________________________

#import <UIKit/UIKit.h>
#import "BaseView.h"
#import "Blocks.h"
//__________________________________________________________________________________________________

@class UnreadMessages;
//__________________________________________________________________________________________________

//! \brief  BaseView based class that manages the navigation between the main views.
@interface NavigationView : BaseView
{
@public
  BlockAction           ScrolledToRecentActivityPage;
  BlockAction           ScrolledToTypingPage;
  BlockAction           ScrolledToFriendsPage;
  BlockAction           ScrolledToSendToPage;
  BlockFloatAction      PleaseBlurByThisFactorAction;
  BlockFloatBlockAction PleaseFlashForDuration;
}
//____________________

- (void)ScrollToPageAtIndex:(NSInteger)pageIndex animated:(BOOL)animated;
//____________________

- (void)ScrollToAzPageAnimated:(BOOL)animated;
//____________________

- (void)ScrollToSendToPageAnimated:(BOOL)animated;
//____________________

- (void)ScrollToTypingPageAnimated:(BOOL)animated;
//____________________

- (void)bounceLeftItemDot;
//____________________

- (void)hideLeftItemDot;
//____________________

- (void)showPlayerFromPoint:(CGPoint)point andRadius:(CGFloat)radius completion:(BlockAction)completion;
//____________________

- (void)showLoginFromStart:(BOOL)fromStart;
//____________________

- (void)hideLogin;
//____________________

- (void)updateFriendsLists;
//____________________

- (void)loadReceivedMessages:(BlockBoolAction)completion;
//____________________

@end
//__________________________________________________________________________________________________
