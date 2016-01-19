
//! \file   PopLabel.h
//! \brief  Class that implements an animated label using the POP library.
//__________________________________________________________________________________________________

#import <UIKit/UIKit.h>

#import "Blocks.h"
#import "PopBaseView.h"
//__________________________________________________________________________________________________

#define kPopLabelFontSizeAnimation  @"PopLabelFontSizeAnimation"  //!< Font size animation id.
#define kPopLabelTextColorAnimation @"PopLabelTextColorAnimation" //!< Text color animation id.
//__________________________________________________________________________________________________

//! Class that implements an animated label using the POP library.
@interface PopLabel : PopBaseView
{
}
//____________________

@property NSString*       text;           //!< The label text.
@property UIColor*        textColor;      //!< The label text color.
@property NSTextAlignment textAlignment;  //!< The text alignement mode.
@property NSInteger       numberOfLines;  //!< The maximum number of lines or 0 if unlimited.
@property UIFont*         font;           //!< The font to use for rendering the label text.
@property BOOL            outline;        //!< When YES, draw the text as outlines.
//____________________

//! Set the label text color color. If duration == 0, no animation. Duration used only for basic animation style.
- (void)setTextColor:(UIColor*)textColor
      animationStyle:(PopAnimationStyle)style
       animateDuring:(CGFloat)seconds;
//____________________

//! Set the label text color color using the specified animation parameters.
- (void)setTextColor:(UIColor*)textColor
          parameters:(PopAnimParameters*)parameters
          completion:(BlockAction)completion;
//____________________

//! Set the label font size using the specified animation parameters.
- (void)setFontSize:(CGFloat)fontSize
         parameters:(PopAnimParameters*)parameters
         completion:(BlockAction)completion;
//____________________

//! Set the label font size using basic animation. If duration == 0, no animation.
- (void)setFontSize:(CGFloat)fontSize basicAnimateDuring:(CGFloat)seconds;
//____________________

//! Set the label font size using spring animation. If velocity == 0, no animation.
- (void)setFontSize:(CGFloat)fontSize springAnimateWithBounciness:(CGFloat)bounciness andVelocity:(CGFloat)velocity;
//____________________

//! Set the label font size using decay animation. If velocity == 0, no animation.
- (void)setFontSize:(CGFloat)fontSize decayAnimateWithDeceleration:(CGFloat)deceleration andVelocity:(CGFloat)velocity;
//____________________

//! Stop the text color animation.
- (void)stopTextColorAnimation;
//____________________

//! Stop the font size animation.
- (void)stopFontSizeAnimation;
//____________________

@end
//__________________________________________________________________________________________________

