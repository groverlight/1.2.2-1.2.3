
//! \file   Interpolation.m
//! \brief  Various interpolation functions.
//__________________________________________________________________________________________________

#import "Interpolation.h"
//__________________________________________________________________________________________________

#ifndef mix
//! Mix the a and b values according to the factor value.
#define mix(a, b, factor) (a * factor + b * (1.0 - factor))
#endif
//__________________________________________________________________________________________________

//! \brief  Interpolate between two UIColor objects in RGB or HSV color model.
//! \return the interpolated UIColor object.
UIColor* InterpolateColor
(
  CGFloat           interpolator, //!< Interpolation value.
  InterpolationMode mode,         //!< Mode of interpolation.
  UIColor*          start_color,  //!< First color to interpolate.
  UIColor*          end_color     //!< Second color to interpolate.
)
{
  if (mode == E_InterpolateRgb)
  {
    CGFloat start_red;
    CGFloat start_green;
    CGFloat start_blue;
    CGFloat start_alpha;
    CGFloat end_red;
    CGFloat end_green;
    CGFloat end_blue;
    CGFloat end_alpha;
    [start_color  getRed:&start_red green:&start_green  blue:&start_blue alpha:&start_alpha];
    [end_color    getRed:&end_red   green:&end_green    blue:&end_blue   alpha:&end_alpha];
    CGFloat red   = start_red   * ( 1 - interpolator) + end_red   * interpolator;
    CGFloat green = start_green * ( 1 - interpolator) + end_green * interpolator;
    CGFloat blue  = start_blue  * ( 1 - interpolator) + end_blue  * interpolator;
    CGFloat alpha = start_alpha * ( 1 - interpolator) + end_alpha * interpolator;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
  }
  else
  {
    CGFloat hue;
    CGFloat start_hue;
    CGFloat start_saturation;
    CGFloat start_value;
    CGFloat start_alpha;
    CGFloat end_hue;
    CGFloat end_saturation;
    CGFloat end_value;
    CGFloat end_alpha;

    [start_color  getHue:&start_hue saturation:&start_saturation  brightness:&start_value alpha:&start_alpha];
    [end_color    getHue:&end_hue   saturation:&end_saturation    brightness:&end_value   alpha:&end_alpha];

    if (start_saturation < 0.001)
    { // Start color is totally unsaturated. Hue has no meaning. Therefore, use end color hue.
      hue = end_hue;
    }
    else if (end_saturation < 0.001)
    { // End color is totally unsaturated. Hue has no meaning. Therefore, use start color hue.
      hue = start_hue;
    }
    else
    { // Both hue values are valid. Interpolate between them by the specified direction.
      switch (mode)
      {
      case E_InterpolateHueUp:
        if (start_hue > end_hue)
        {
          end_hue += 1.0;
        }
        break;
      case E_InterpolateHueDown:
        if (start_hue < end_hue)
        {
          start_hue += 1.0;
        }
        break;
      case E_InterpolateHueShortest:
        if (fabs(start_hue - end_hue) > 0.5)
        {
          if (start_hue < 0.5)
          {
            start_hue += 1.0;
          }
          else
          {
            start_hue -= 1.0;
          }
        }
        break;
      case E_InterpolateHueLongest:
        if (fabs(start_hue - end_hue) < 0.5)
        {
          if (start_hue < 0.5)
          {
            start_hue += 1.0;
          }
          else
          {
            start_hue -= 1.0;
          }
        }
        break;
      default:
        break;
      }
      hue = mix(end_hue, start_hue, interpolator);
      if (hue >= 1.0)
      {
        hue -= 1.0;
      }
      if (hue < 0.0)
      {
        hue += 1.0;
      }
    }
    CGFloat saturation  = mix(end_saturation, start_saturation, interpolator);
    CGFloat brightness  = mix(end_value     , start_value     , interpolator);
    CGFloat alpha       = mix(end_alpha     , start_alpha     , interpolator);
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:alpha];
  }
}
//__________________________________________________________________________________________________

//! \brief  Interpolate between two CGFloat values.
//! \return the khFLoat interpolated value.
CGFloat InterpolateFloat
(
  CGFloat interpolator, //!< Interpolation value.
  CGFloat start_value,  //!< First value to interpolate.
  CGFloat end_value     //!< Second value to interpolate.
)
{
  return start_value * (1 - interpolator) + end_value * interpolator;
}
//__________________________________________________________________________________________________

//! \brief  Interpolate between two CGPoint objects.
//! \return the interpolated CGPoint.
CGPoint InterpolatePoint
(
  CGFloat interpolator, //!< Interpolation value.
  CGPoint start_point,  //!< First point to interpolate.
  CGPoint end_point     //!< Second point to interpolate.
)
{
  CGFloat x = start_point.x * (1 - interpolator) + end_point.x * interpolator;
  CGFloat y = start_point.y * (1 - interpolator) + end_point.y * interpolator;
  return CGPointMake(x, y);
}
//__________________________________________________________________________________________________

//! \brief  Interpolate between two CGSize objects.
//! \return the interpolated CGSize.
CGSize InterpolateSize
(
  CGFloat interpolator, //!< Interpolation value.
  CGSize  startSize,    //!< First size to interpolate.
  CGSize  endSize       //!< Second size to interpolate.
)
{
  CGFloat width   = startSize.width   * (1 - interpolator) + endSize.width   * interpolator;
  CGFloat height  = startSize.height  * (1 - interpolator) + endSize.height  * interpolator;
  return CGSizeMake(width, height);
}
//__________________________________________________________________________________________________
