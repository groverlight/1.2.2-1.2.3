
//! \file   WhiteButton.h
//! \brief  Text button with a large white background with rounded corners.
//__________________________________________________________________________________________________

#import <UIKit/UIKit.h>
#import "PopParametricAnimationView.h"
//__________________________________________________________________________________________________

//! Button with with dot, underlined label and POP animation.
@interface WhiteButton : PopParametricAnimationView
{
}
//____________________

@property NSString*   title;
@property BOOL        enabled;
@property BlockAction highlightedAction;
@property BlockAction pressedAction;
//____________________

@end
//__________________________________________________________________________________________________
