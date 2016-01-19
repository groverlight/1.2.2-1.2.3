
//! \file   HeaderButton.h
//! \brief  Button with dot and POP animation.
//__________________________________________________________________________________________________

#import <UIKit/UIKit.h>
#import "PopParametricAnimationView.h"
//__________________________________________________________________________________________________

//! Button with dot and POP animation.
@interface HeaderButton : PopParametricAnimationView
{
}
//____________________

@property             NSString*   title;
@property (readonly)  CGFloat     titleWidth;
@property             BOOL        enabled;
@property             BOOL        selected;
@property             BOOL        dotVisible;
@property             BlockAction highlightedAction;
@property             BlockAction pressedAction;
//____________________

- (CGSize)scaledSizeThatFits:(CGSize)size;
//____________________

- (void)bounceDot;
//____________________

@end
//__________________________________________________________________________________________________
