
//! \file   TopBarView.h
//! \brief  UIView based class that implements the labels on the top of the screen.
//__________________________________________________________________________________________________

#import <UIKit/UIKit.h>
#import "BaseView.h"
#import "Blocks.h"
//__________________________________________________________________________________________________

//! UIView based class that implements the labels on the top of the screen.
@interface TopBarView : BaseView
{
}
//____________________

// The view components.
@property UIView* leftItem;
@property UIView* centerItem;
@property UIView* rightItem;

// The components offset from the default position.
@property CGPoint leftItemOffset;
@property CGPoint centerItemOffset;
@property CGPoint rightItemOffset;

@property CGFloat barHeight;    //!< Height of the bar.
@property CGFloat borderOffset; //!< Distance from the lateral border for the center of the left and right item.

@end
//__________________________________________________________________________________________________
