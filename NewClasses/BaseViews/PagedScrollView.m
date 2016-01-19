
//! \file   PagedScrollView.m
//! \brief  UIView based class that manages navigation through a stack of card views.
//__________________________________________________________________________________________________

#import <CoreMotion/CMMotionManager.h>
#import "Blocks.h"
#import "PagedScrollView.h"
#import "Tools.h"
//__________________________________________________________________________________________________

#define ENABLE_LEFT_LATERAL_SCROLL_DOWN   1 //!< If 1, enable left lateral view to be scrolled down.
#define ENABLE_RIGHT_LATERAL_SCROLL_DOWN  0 //!< If 1, enable right lateral view to be scrolled down.
//__________________________________________________________________________________________________

//! \brief  UIView based class that manages navigation through a stack of card views.
@interface PagedScrollView() <UIScrollViewDelegate>
{
  UIScrollView*   ScrollView;

  CGPoint         StartPoint;             //!< Touch point at the start of the scroll.
  BOOL            Starting;               //!< YES when at the start of the scroll.
  BOOL            ScrollingVertically;    //!< YES during a vertical scroll.
  BOOL            ScrollEnabled;          //!< Scroll is disabled when set to NO;
  BOOL            InhibitScrolling;       //!< When yes, cancel any scroll that would attempt to start.
  BlockIntAction  InhibitParentScrolling; //!< Block to be called to inhibit or not the parent scrolling.
  NSInteger       CurrentPage;
}
//____________________

@end
//__________________________________________________________________________________________________

//! \brief  UIView based class that manages navigation through a stack of card views.
@implementation PagedScrollView

//! Initialize the object however it has been created.
-(void)Initialize
{
  CurrentPage                               = -1;
  Scrolling                                 = NO;
  Starting                                  = NO;
  InhibitScrolling                          = NO;
  ScrollEnabled                             = YES;
  ScrollView                                = [UIScrollView new];
  ScrollView.delegate                       = self;
  ScrollView.pagingEnabled                  = YES;
  ScrollView.showsHorizontalScrollIndicator = NO;
  ScrollView.showsVerticalScrollIndicator   = NO;

  [self addSubview:ScrollView];
  InhibitParentScrolling = ^(NSInteger inhibit)
  { // Default action: do nothing!
  };
  ScrolledToPageAction = ^(NSInteger page)
  { // Default action: do nothing!
  };
  ScrollingTouchUp = ^(NSInteger page)
  { // Default action: do nothing!
  };
  ScrollingWithPageFractionAction = ^(CGFloat page)
  { // Default action: do nothing!
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

- (void)setFrame:(CGRect)frame
{
//  NSLog(@"setFrame");
  super.frame = frame;
}
//__________________________________________________________________________________________________

//! Recalculate view layout independently of the system layout process.
- (void)layout
{
  UIView* view;
  CGRect frame = self.bounds;
  ScrollView.frame = frame;
  for (int i = 0; i < ScrollView.subviews.count; i++)
  {
    frame.origin.x  = i * frame.size.width;
    view = [ScrollView.subviews objectAtIndex:i];
    view.frame      = frame;
  }
  frame.origin.x            = CurrentPage * frame.size.width;
  frame.size.width          = frame.size.width * ScrollView.subviews.count;
  ScrollView.contentSize    = frame.size;
  ScrollView.contentOffset  = frame.origin;
}
//__________________________________________________________________________________________________

- (void)layoutSubviews
{
  if (!Scrolling)
  {
//    NSLog(@"CardNavigationOverlayView layoutSubviews");
    [super layoutSubviews];
  }
}
//__________________________________________________________________________________________________

- (void) setBounces:(BOOL)bounces
{
  ScrollView.bounces = bounces;
}
//__________________________________________________________________________________________________

- (BOOL)bounces
{
  return ScrollView.bounces;
}
//__________________________________________________________________________________________________

- (UIScrollView*)scrollView
{
  return ScrollView;
}
//__________________________________________________________________________________________________

- (void)addPageView:(BaseView*)pageView
{
  [ScrollView addSubview:pageView];
}
//__________________________________________________________________________________________________

- (void)removePageView:(BaseView*)pageView
{
  [pageView removeFromSuperview];
}
//__________________________________________________________________________________________________

- (void)removePageViewAtIndex:(NSInteger)pageIndex
{
  [((UIView*)[ScrollView.subviews objectAtIndex:pageIndex]) removeFromSuperview];
}
//__________________________________________________________________________________________________

- (void)ScrollToPage:(BaseView*)pageView animated:(BOOL)animated
{
//  NSLog(@"frame: %f, %f, %f, %f", pageView.frame.origin.x, pageView.frame.origin.y, pageView.frame.size.width, pageView.frame.size.height);
  if (animated)
  {
    CGRect rect = CGRectMake(pageView.frame.origin.x, pageView.frame.origin.y, pageView.frame.size.width, pageView.frame.size.height);
    [ScrollView scrollRectToVisible:rect animated:YES];
  }
  else
  {
    ScrollView.contentOffset = pageView.frame.origin;
    if (ScrollView.bounds.size.width > 0)
    {
      CurrentPage = ScrollView.contentOffset.x / ScrollView.bounds.size.width;
    }
    ScrolledToPageAction(CurrentPage);
  }
}
//__________________________________________________________________________________________________

- (void)ScrollToPageAtIndex:(NSInteger)pageIndex animated:(BOOL)animated
{
  CurrentPage = pageIndex;
  [self ScrollToPage:[ScrollView.subviews objectAtIndex:pageIndex] animated:animated];
}
//__________________________________________________________________________________________________

//================================== UIScrollViewDelegate methods ==================================

- (BOOL)DidScrollSucceed
{
  return !((ScrollView.contentOffset.x == StartPoint.x) && (ScrollView.contentOffset.y == StartPoint.y));
}
//__________________________________________________________________________________________________

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
  if (Scrolling)
  {
//    NSLog(@"scrollViewWillBeginDragging called while already scrolling!");
    [self scrollViewDidEndDecelerating:scrollView];
  }
//  NSLog(@"scrollViewWillBeginDragging: %f, %f", scrollView.contentOffset.x, scrollView.contentOffset.y);
  StartPoint  = scrollView.contentOffset;
  Starting    = YES;
  Scrolling   = YES;
}
//__________________________________________________________________________________________________

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//  NSLog(@"Scrolling: %f, %f, (%f)", scrollView.contentOffset.x, scrollView.contentOffset.y, scrollView.contentOffset.x / scrollView.bounds.size.width);
  if (Scrolling)
  {
    if (Starting)
    {
      InhibitParentScrolling(YES);
//      NSLog(@"Starting: %f, %f", scrollView.contentOffset.x, scrollView.contentOffset.y);
      Starting = NO;
      ScrollingVertically = fabs(StartPoint.x - ScrollView.contentOffset.x) < fabs(StartPoint.y - ScrollView.contentOffset.y);
      if (ScrollingVertically)
      { // This is the start of a vertical scroll.
      }
      else
      { // This is the start of an horizontal scroll.
      }
    }
    else
    {
    }
    if ((StartPoint.x == scrollView.contentOffset.x) && (StartPoint.y == scrollView.contentOffset.y))
    {
//      NSLog(@"Scrolling to start position!");
    }
    if ((StartPoint.x != scrollView.contentOffset.x) && (StartPoint.y != scrollView.contentOffset.y))
    {
      if (ScrollingVertically)
      {
//        NSLog(@"Scrolling vertically: %f (%f), %f", StartPoint.x, scrollView.contentOffset.x, scrollView.contentOffset.y);
        ScrollView.contentOffset = CGPointMake(StartPoint.x, scrollView.contentOffset.y);
      }
      else
      {
//        NSLog(@"Scrolling horizontally %f, %f (%f)", scrollView.contentOffset.x, StartPoint.y, scrollView.contentOffset.y);
        ScrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, StartPoint.y);
      }
    }
//    NSLog(@"Scrolling (end): %f, %f", scrollView.contentOffset.x, scrollView.contentOffset.y);
    ScrollingWithPageFractionAction(ScrollView.contentOffset.x / ScrollView.bounds.size.width);
  }
  else
  {
//    NSLog(@"scrollViewDidScroll called while not scrolling!");
    ScrollingWithPageFractionAction(ScrollView.contentOffset.x / ScrollView.bounds.size.width);
  }
}
//__________________________________________________________________________________________________

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
  Scrolling = NO;
  InhibitParentScrolling(NO);
  NSInteger newPage = scrollView.contentOffset.x / scrollView.bounds.size.width;
  if (newPage != CurrentPage)
  {
    CurrentPage = newPage;
    dispatch_async(dispatch_get_main_queue(), ^
    {
      ScrolledToPageAction(CurrentPage);
    });
  }
//  NSLog(@"scrollViewDidEndDecelerating: %f, %f, page: %d\n\n\n", scrollView.contentOffset.x, scrollView.contentOffset.y, (int)CurrentPage);
}
//__________________________________________________________________________________________________

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
//  NSLog(@"scrollViewDidEndDragging");
}
//__________________________________________________________________________________________________

- (void)scrollViewWillEndDragging:(UIScrollView*)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint*)targetContentOffset
{
  NSInteger page = targetContentOffset->x / scrollView.bounds.size.width;
  ScrollingTouchUp(page);
//  NSLog(@"scrollViewWillEndDragging: %f, %f, page: %d", scrollView.contentOffset.x, scrollView.contentOffset.y, (int)page);
}
//__________________________________________________________________________________________________

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
  CurrentPage = scrollView.contentOffset.x / scrollView.bounds.size.width;
  ScrolledToPageAction(CurrentPage);
//  NSLog(@"scrollViewDidEndScrollingAnimation");
}
//__________________________________________________________________________________________________

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
//  NSLog(@"scrollViewDidScrollToTop");
}
//__________________________________________________________________________________________________

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
//  NSLog(@"scrollViewWillBeginDecelerating");
}
//__________________________________________________________________________________________________

@end
