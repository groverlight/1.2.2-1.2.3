
//! \file   HeaderBarView.h
//! \brief  Pop View that implements the labels on the top of the screen.
//__________________________________________________________________________________________________

#import <UIKit/UIKit.h>
#import "PopParametricAnimationView.h"
#import "Blocks.h"
//__________________________________________________________________________________________________

//! Pop View that implements the labels on the top of the screen.
@interface HeaderBarView : PopParametricAnimationView
{
@public
  BlockIntAction ItemSelectedAction;
}
//____________________

- (void)SelectItemAtIndex:(NSInteger)index;
//____________________

- (void)bounceLeftItemDot;
//____________________

- (void)hideLeftItemDot;
//____________________

- (void)scrollUnderlineByFactor:(CGFloat)factor;
//____________________

- (void)showAnimated:(BOOL)animated;  //!< Show the header bar view.
- (void)hideAnimated:(BOOL)animated;  //!< Hide the header bar view.
//____________________

@end
//__________________________________________________________________________________________________
