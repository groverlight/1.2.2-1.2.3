
//! \file   PagedScrollView.h
//! \brief  View derived from BaseView that handle paged scroll content.
//__________________________________________________________________________________________________

#import <UIKit/UIKit.h>
#import "BaseView.h"
#import "Blocks.h"
//__________________________________________________________________________________________________

//! \brief  UIView based class that manages navigation through a stack of card views.
@interface PagedScrollView : BaseView
{
@public
  BOOL              Scrolling;                        //!< YES during scroll.
  BlockIntAction    ScrolledToPageAction;
  BlockIntAction    ScrollingTouchUp;
  BlockFloatAction  ScrollingWithPageFractionAction;
}
//____________________

@property             BOOL          bounces;
@property (readonly)  UIScrollView* scrollView;
//____________________

- (void)addPageView:(BaseView*)pageView;
//____________________

- (void)removePageView:(BaseView*)pageView;
//____________________

- (void)removePageViewAtIndex:(NSInteger)pageIndex;
//____________________

- (void)ScrollToPage:(BaseView*)pageView animated:(BOOL)animated;
//____________________

- (void)ScrollToPageAtIndex:(NSInteger)pageIndex animated:(BOOL)animated;
//____________________

@end
//__________________________________________________________________________________________________
