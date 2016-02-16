
//! \file   ColorTools.m
//! \brief  Color related helper functions.
//__________________________________________________________________________________________________

#import "Colors.h"
#import "Tools.h"
//__________________________________________________________________________________________________

static UIColor* SharedColors[] = {nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil};
//__________________________________________________________________________________________________

//! Build a predefined color.
static UIColor* BaseColor(T_Colors color)
{
  switch (color)
  {
    case E_Color_Red:
      return [UIColor colorWithRed:1.0  green:0.0  blue:0.0  alpha:1.0];
    case E_Color_Green:
      return [UIColor colorWithRed:0.0  green:1.0  blue:0.0  alpha:1.0];
    case E_Color_Blue:
      return [UIColor colorWithRed:0.0  green:0.0  blue:1.0  alpha:1.0];
    case E_Color_Black:
      return [UIColor colorWithRed:0.0  green:0.0  blue:0.0  alpha:1.0];
    case E_Color_DarkGrey:
      return [UIColor colorWithRed:0.25 green:0.25 blue:0.25 alpha:1.0];
    case E_Color_Grey:
      return [UIColor colorWithRed:0.5  green:0.5  blue:0.5  alpha:1.0];
    case E_Color_LightGrey:
      return [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1.0];
    case E_Color_VeryLightGrey:
      return [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0];
    case E_Color_White:
      return [UIColor colorWithRed:1.0  green:1.0  blue:1.0  alpha:1.0];
    case E_Color_Transparent:
      return [UIColor colorWithRed:0.0  green:0.0  blue:0.0  alpha:0.0];
    case E_Color_Pink:
      return [UIColor colorWithRed:1.0  green:0.5  blue:0.5  alpha:1.0];
    case E_Color_Orange:
      return [UIColor colorWithRed:1.0  green:0.5  blue:0.0  alpha:1.0];
    case E_Color_Brown:
      return [UIColor colorWithRed:0.6  green:0.4  blue:0.2  alpha:1.0];
    case E_Color_Yellow:
      return [UIColor colorWithRed:1.0  green:1.0  blue:0.0  alpha:1.0];
    case E_Color_Cyan:
      return [UIColor colorWithRed:0.0  green:1.0  blue:1.0  alpha:1.0];
    case E_Color_Magenta:
      return [UIColor colorWithRed:1.0  green:0.0  blue:1.0  alpha:1.0];
    case E_Color_Purple:
      return [UIColor colorWithRed:0.5  green:0.0  blue:0.5  alpha:1.0];
    case E_Color_SystemBlue:
      return [UIColor colorWithRed:0.0  green:0.48 blue:1.0  alpha:1.0];
    case E_Color_Violet:
      return [UIColor colorWithRed:0.68 green:0.48 blue:0.91 alpha:1.0];
    case E_Color_WarmGrey:
       return [UIColor colorWithRed:0.20 green:.18 blue:0.17 alpha:1.0];
    case E_Color_DarkLightGrey:
          return [UIColor colorWithRed:0.84 green:0.84 blue:0.84 alpha:1.0];
    case E_Color_TypePink:
          return [UIColor colorWithRed:1.00 green:0.28 blue:0.44 alpha:1.0];
    case E_Color_TypeTeal:
         return [UIColor colorWithRed:0.28 green:0.96 blue:0.84 alpha:1.0];
    case E_Color_TypeBlue:
          return [UIColor colorWithRed:0.0 green:0.48 blue:1.00 alpha:1.0];
    case E_Color_TypeTealDark:
          return [UIColor colorWithRed:0.03 green:0.61 blue:0.51 alpha:1.0];
      case E_Color_LightPink:
          return [UIColor colorWithRed:1.00 green:0.81 blue:0.85 alpha:1.0];
  }
}
//__________________________________________________________________________________________________

//! Get a predefined UIColor object.
UIColor* Color(T_Colors color)
{
  if (SharedColors[color] == nil)
  {
    SharedColors[color] = BaseColor(color);
  }
  return SharedColors[color];
}
//__________________________________________________________________________________________________

//! Build a custom UIColor object.
UIColor* RgbColor(CGFloat red, CGFloat green, CGFloat blue)
{
  return RgbaColor(red, green, blue, 1.0);
}
//__________________________________________________________________________________________________

//! Build a custom UIColor object with alpha component.
UIColor* RgbaColor(CGFloat red, CGFloat green, CGFloat blue, CGFloat alpha)
{
  return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}
//__________________________________________________________________________________________________

//! Build a custom UIColor object.
UIColor* RgbIntColor(NSInteger red, NSInteger green, NSInteger blue)
{
  return RgbaColor(red / 255.0, green / 255.0, blue / 255.0, 1.0);
}
//__________________________________________________________________________________________________

//! Build a custom UIColor object with alpha component.
UIColor* RgbaIntColor(NSInteger red, NSInteger green, NSInteger blue, CGFloat alpha)
{
  return [UIColor colorWithRed:red / 255.0 green:green / 255.0 blue:blue / 255.0 alpha:alpha];
}
//__________________________________________________________________________________________________

//! Dim the color by the specified factor. The alpha component is not altered.
UIColor* DimColor(UIColor* color, CGFloat dimFactor)
{
  CGFloat red;
  CGFloat green;
  CGFloat blue;
  CGFloat alpha;
  [color getRed:&red green:&green blue:&blue alpha:&alpha];
  return [UIColor colorWithRed:(red * dimFactor) green:(green * dimFactor) blue:(blue * dimFactor) alpha:alpha];
}
//__________________________________________________________________________________________________

//! Shift the hue component of the color.
UIColor* ColorWithHue(const UIColor* color, CGFloat hue)
{
  CGFloat color_hue;
  CGFloat color_saturation;
  CGFloat color_brightness;
  CGFloat color_alpha;

  [color getHue:&color_hue saturation:&color_saturation brightness:&color_brightness alpha:&color_alpha];
  CGFloat new_hue = fmod(color_hue + hue, 1.0);
  UIColor* new_color = [UIColor colorWithHue:new_hue saturation:color_saturation brightness:color_brightness alpha:color_alpha];
  return new_color;
}
//__________________________________________________________________________________________________

//! Mutiply the saturation component of the color.
UIColor* ColorWithSaturation(const UIColor* color, CGFloat saturation)
{
  CGFloat color_hue;
  CGFloat color_saturation;
  CGFloat color_brightness;
  CGFloat color_alpha;

  [color getHue:&color_hue saturation:&color_saturation brightness:&color_brightness alpha:&color_alpha];
  CGFloat new_saturation = min(color_saturation * saturation, 1.0);
  UIColor* new_color = [UIColor colorWithHue:color_hue saturation:new_saturation brightness:color_brightness alpha:color_alpha];
  return new_color;
}
//__________________________________________________________________________________________________

//! Mutiply the brightness component of the color.
UIColor* ColorWithBrightness(const UIColor* color, CGFloat brightness)
{
  CGFloat color_hue;
  CGFloat color_saturation;
  CGFloat color_brightness;
  CGFloat color_alpha;

  [color getHue:&color_hue saturation:&color_saturation brightness:&color_brightness alpha:&color_alpha];
  CGFloat new_brightness = min(color_brightness * brightness, 1.0);
  UIColor* new_color = [UIColor colorWithHue:color_hue saturation:color_saturation brightness:new_brightness alpha:color_alpha];
  return new_color;
}
//__________________________________________________________________________________________________

//! Mutiply the alpha component of the color.
UIColor* ColorWithAlpha(const UIColor* color, CGFloat alpha)
{
  CGFloat color_hue;
  CGFloat color_saturation;
  CGFloat color_brightness;
  CGFloat color_alpha;

  [color getHue:&color_hue saturation:&color_saturation brightness:&color_brightness alpha:&color_alpha];
  CGFloat new_alpha = min(color_alpha * alpha, 1.0);
  UIColor* new_color = [UIColor colorWithHue:color_hue saturation:color_saturation brightness:color_brightness alpha:new_alpha];
  return new_color;
}
//__________________________________________________________________________________________________

//! Replace the hue component of the color.
UIColor* ReplaceColorHue(const UIColor* color, CGFloat hue)
{
  CGFloat color_hue;
  CGFloat color_saturation;
  CGFloat color_brightness;
  CGFloat color_alpha;

  [color getHue:&color_hue saturation:&color_saturation brightness:&color_brightness alpha:&color_alpha];
  UIColor* new_color = [UIColor colorWithHue:hue saturation:color_saturation brightness:color_brightness alpha:color_alpha];
  return new_color;
}
//__________________________________________________________________________________________________

//! Replace the saturation component of the color.
UIColor* ReplaceColorSaturation(const UIColor* color, CGFloat saturation)
{
  CGFloat color_hue;
  CGFloat color_saturation;
  CGFloat color_brightness;
  CGFloat color_alpha;

  [color getHue:&color_hue saturation:&color_saturation brightness:&color_brightness alpha:&color_alpha];
  UIColor* new_color = [UIColor colorWithHue:color_hue saturation:saturation brightness:color_brightness alpha:color_alpha];
  return new_color;
}
//__________________________________________________________________________________________________

//! Replace the brightness component of the color.
UIColor* ReplaceColorBrightness(const UIColor* color, CGFloat brightness)
{
  CGFloat color_hue;
  CGFloat color_saturation;
  CGFloat color_brightness;
  CGFloat color_alpha;

  [color getHue:&color_hue saturation:&color_saturation brightness:&color_brightness alpha:&color_alpha];
  UIColor* new_color = [UIColor colorWithHue:color_hue saturation:color_saturation brightness:brightness alpha:color_alpha];
  return new_color;
}
//__________________________________________________________________________________________________

//! Replace the alpha component of the color.
UIColor* ReplaceColorAlpha(const UIColor* color, CGFloat alpha)
{
  CGFloat color_hue;
  CGFloat color_saturation;
  CGFloat color_brightness;
  CGFloat color_alpha;

  [color getHue:&color_hue saturation:&color_saturation brightness:&color_brightness alpha:&color_alpha];
  UIColor* new_color = [UIColor colorWithHue:color_hue saturation:color_saturation brightness:color_brightness alpha:alpha];
  return new_color;
}
//__________________________________________________________________________________________________

UIColor* MixColors(const UIColor* color_1, const UIColor* color_2, CGFloat factor)
{
  CGFloat hue_1;
  CGFloat saturation_1;
  CGFloat value_1;
  CGFloat alpha_1;
  CGFloat hue_2;
  CGFloat saturation_2;
  CGFloat value_2;
  CGFloat alpha_2;

  [color_1 getHue:&hue_1 saturation:&saturation_1 brightness:&value_1 alpha:&alpha_1];
  [color_2 getHue:&hue_2 saturation:&saturation_2 brightness:&value_2 alpha:&alpha_2];

  CGFloat hue         = hue_2         * factor + hue_1        * (1.0 - factor);
  CGFloat saturation  = saturation_2  * factor + saturation_1 * (1.0 - factor);
  CGFloat value       = value_2       * factor + value_1      * (1.0 - factor);
  CGFloat alpha       = alpha_2       * factor + alpha_1      * (1.0 - factor);

  UIColor* color = [UIColor colorWithHue:hue saturation:saturation brightness:value alpha:alpha];
//  NSLog(@"%.2f, %.2f, %.2f, %.2f", hue, saturation, value, alpha);
  return color;
};
//__________________________________________________________________________________________________
