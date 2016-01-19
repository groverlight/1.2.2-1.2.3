
//! \file   HsvGradient.m
//! \brief  Implementation of a gradient whose colors are interpolated using the HSV color model.
//__________________________________________________________________________________________________

#import "Colors.h"
#import "HsvGradient.h"
#import "Interpolation.h"
//__________________________________________________________________________________________________

#define COMPONENT_COUNT 4   // The shading is using RGBA colors.
//__________________________________________________________________________________________________

static void HsvShadingFunction(void* info, const CGFloat* in, CGFloat* outValue)
{
  HsvGradient* gradient       = (__bridge HsvGradient*)info;
  CGFloat interpolator          = *in;
  UIColor* interpolatedColor    = InterpolateColor(interpolator, gradient->Mode, gradient->StartColor, gradient->EndColor);
#if 0
  khLog("-----interpolator: %7.5f, [%06.2f, %5.3f, %5.3f, %5.3f], [%06.2f, %5.3f, %5.3f, %5.3f] -> %d, %d -> [%06.2f, %5.3f, %5.3f, %5.3f]", interpolator,
        start_color.Hue, start_color.Saturation, start_color.Value, start_color.Alpha,
        end_color.Hue  , end_color.Saturation  , end_color.Value  , end_color.Alpha,
        start_color_index, end_color_index,
        interpolated_color.Hue, interpolated_color.Saturation, interpolated_color.Value, interpolated_color.Alpha);
#endif
  const CGFloat* components = CGColorGetComponents(interpolatedColor.CGColor);
  memcpy(outValue, components, sizeof(CGFloat) * COMPONENT_COUNT);
}
//__________________________________________________________________________________________________

static const CGFloat inputRange[]           = {0,1};
static const CGFloat outputRange[]          = {0,1, 0,1, 0,1, 0,1};
static const CGFunctionCallbacks callback = {0, &HsvShadingFunction, NULL};
//__________________________________________________________________________________________________

@interface HsvGradient()
{
  CGShadingRef    Shading;
  CGColorSpaceRef ColorSpace;
  GradientType    ColorModel;
}
@end
//__________________________________________________________________________________________________

@implementation HsvGradient

-(id)init
{
  self = [super init];
  if (self != nil)
  {
    ColorSpace  = CGColorSpaceCreateDeviceRGB();
    ColorModel  = E_GradientType_RGB;
  }
  return self;
}
//__________________________________________________________________________________________________

-(void)dealloc
{
  CGColorSpaceRelease(ColorSpace);
}
//__________________________________________________________________________________________________

//  \brief  Set the color model used for color interpolation. Defaults to E_khGradientType_RGB.
- (void)SetGradientColorModel:(GradientType)gradient_color_model
{
  ColorModel = gradient_color_model;
}
//__________________________________________________________________________________________________

//! \brief  Draw the gradient in linear mode.
//! \param  startPoint  Starting point of the gradient.
//! \param  endPoint    Ending point of the gradient.
//! \param  options     Option flags (kCGGradientDrawsBeforeStartLocation or kCGGradientDrawsAfterEndLocation).
-(void)DrawLinearGradientInContext:(CGContextRef)context
                                  :(CGPoint)startPoint
                                  :(CGPoint)endPoint
                                  :(CGGradientDrawingOptions)options
{
  CGFunctionRef func = CGFunctionCreate((__bridge void *)(self), 1, inputRange, 4, outputRange, &callback);
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  Shading = CGShadingCreateAxial(colorSpace, startPoint, endPoint, func, options & kCGGradientDrawsBeforeStartLocation, options & kCGGradientDrawsAfterEndLocation);
  if (Shading != NULL)
  {
    CGContextDrawShading(context, Shading);
  }
  CGShadingRelease(Shading);
  CGColorSpaceRelease(colorSpace);
}
//__________________________________________________________________________________________________

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
                                  :(CGGradientDrawingOptions)options
{
  CGFunctionRef func = CGFunctionCreate((__bridge void *)(self), 1, inputRange, 4, outputRange, &callback);
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  Shading = CGShadingCreateRadial(colorSpace, startCenter, startRadius, endCenter, endRadius, func, options & kCGGradientDrawsBeforeStartLocation, options & kCGGradientDrawsAfterEndLocation);
  if (Shading != NULL)
  {
    CGContextDrawShading(context, Shading);
  }
  CGShadingRelease(Shading);
  CGColorSpaceRelease(colorSpace);
}
//__________________________________________________________________________________________________
@end
