
//! \file   HsvGradient.h
//! \brief  Implementation of a gradient whose colors are interpolated using the HSV color model.
//__________________________________________________________________________________________________

#import <UIKit/UIKit.h>
#import "Interpolation.h"
//__________________________________________________________________________________________________

// Gradient color model types.
typedef enum
{
  E_GradientType_RGB,
  E_GradientType_HSV
} GradientType;
//__________________________________________________________________________________________________

@interface HsvGradient : NSObject
{
@public
  UIColor*          StartColor;
  UIColor*          EndColor;
  InterpolationMode Mode; //!< Array of interpolation direction values.
}

//  \brief  Set the color model used for color interpolation. Defaults to E_khGradientType_RGB.
- (void)SetGradientColorModel:(GradientType)gradient_color_model;
//____________________

//! \brief  Draw the gradient in linear mode.
//! \param  startPoint  Starting point of the gradient.
//! \param  endPoint    Ending point of the gradient.
//! \param  options     Option flags (kCGGradientDrawsBeforeStartLocation or kCGGradientDrawsAfterEndLocation).
-(void)DrawLinearGradientInContext:(CGContextRef)context
                                  :(CGPoint)startPoint
                                  :(CGPoint)endPoint
                                  :(CGGradientDrawingOptions)options;
//____________________

//! \brief  Draw the gradient in radial mode.
//! \param  startCenter Center of the starting circle.
//! \param  startRadius Radius of the startint circle.
//! \param  endCenter   Center of the ending circle.
//! \param  endRadius   Radius of the ending circle.
//! \param  options     Option flags (kCGGradientDrawsBeforeStartLocation or kCGGradientDrawsAfterEndLocation).
-(void)DrawRadialGradientInContext:(CGContextRef)context
                                  :(CGPoint)startCenter
                                  :(CGFloat)startRadius
                                  :(CGPoint)endCenter
                                  :(CGFloat)endRadius
                                  :(CGGradientDrawingOptions)options;
//____________________

@end

