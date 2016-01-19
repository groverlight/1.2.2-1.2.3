
//! \file   ColorTools.h
//! \brief  Color related helper functions.
//__________________________________________________________________________________________________

#import <UIKit/UIKit.h>
//__________________________________________________________________________________________________

#define Red             Color(E_Color_Red)              //!< Red color.
#define Green           Color(E_Color_Green)            //!< Green color.
#define Blue            Color(E_Color_Blue)             //!< Blue color.
#define Black           Color(E_Color_Black)            //!< Black color.
#define DarkGrey        Color(E_Color_DarkGrey)         //!< Dark grey color.
#define Grey            Color(E_Color_Grey)             //!< Grey color.
#define DarkLightGrey   Color(E_Color_DarkLightGrey)
#define LightGrey       Color(E_Color_LightGrey)        //!< Light grey color.
#define VeryLightGrey   Color(E_Color_VeryLightGrey)    //!< Very light grey color.
#define White           Color(E_Color_White)            //!< White color.
#define Transparent     Color(E_Color_Transparent)      //!< Transparent color.
#define Pink            Color(E_Color_Pink)             //!< Pink color.
#define Orange          Color(E_Color_Orange)           //!< Orange color.
#define Brown           Color(E_Color_Brown)            //!< Brown color.
#define Yellow          Color(E_Color_Yellow)           //!< Yellow color.
#define Cyan            Color(E_Color_Cyan)             //!< Cyan color.
#define Magenta         Color(E_Color_Magenta)          //!< Magenta color.
#define Purple          Color(E_Color_Purple)           //!< Purple color.
#define SystemBlue      Color(E_Color_SystemBlue)       //!< The default iOS blue label color.
#define Violet          Color(E_Color_Violet)           //!< Violet color.
#define WarmGrey        Color(E_Color_WarmGrey)
#define TypePink        Color(E_Color_TypePink)
#define TypeTeal        Color(E_Color_TypeTeal)
#define TypeBlue        Color(E_Color_TypeBlue)
#define TypeTealDark    Color(E_Color_TypeTealDark)
#define LightPink        Color(E_Color_LightPink)

//__________________________________________________________________________________________________

//! All the colors defined for this App.
typedef enum
{
  E_Color_Red,            //!< Red color.
  E_Color_Green,          //!< Green color.
  E_Color_Blue,           //!< Blue color.
  E_Color_Black,          //!< Black color.
  E_Color_DarkGrey,       //!< Dark grey color.
  E_Color_DarkLightGrey,
  E_Color_Grey,           //!< Grey color.
  E_Color_LightGrey,      //!< Light grey color.
  E_Color_VeryLightGrey,  //!< Light grey color.
  E_Color_White,          //!< White color.
  E_Color_Transparent,    //!< Transparent color.
  E_Color_Pink,           //!< Pink color.
  E_Color_Orange,         //!< Orange color.
  E_Color_Brown,          //!< Brown color.
  E_Color_Yellow,         //!< Yellow color.
  E_Color_Cyan,           //!< Cyan color.
  E_Color_Magenta,        //!< Magenta color.
  E_Color_Purple,         //!< Purple color.
  E_Color_SystemBlue,     //!< The default iOS blue label color.
  E_Color_Violet,         //!< Violet color.
  E_Color_WarmGrey,
  E_Color_TypePink,
  E_Color_TypeTeal,
  E_Color_TypeBlue,
  E_Color_TypeTealDark,
  E_Color_LightPink,
} T_Colors;
//__________________________________________________________________________________________________

//! Get a predefined UIColor object.
UIColor* Color(T_Colors color);
//__________________________________________________________________________________________________

//! Build a custom UIColor object.
UIColor* RgbColor(CGFloat red, CGFloat green, CGFloat blue);
//__________________________________________________________________________________________________

//! Build a custom UIColor object with alpha component.
UIColor* RgbaColor(CGFloat red, CGFloat green, CGFloat blue, CGFloat alpha);
//__________________________________________________________________________________________________

//! Build a custom UIColor object.
UIColor* RgbIntColor(NSInteger red, NSInteger green, NSInteger blue);
//__________________________________________________________________________________________________

//! Build a custom UIColor object with alpha component.
UIColor* RgbaIntColor(NSInteger red, NSInteger green, NSInteger blue, CGFloat alpha);
//__________________________________________________________________________________________________

//! Dim the specified color.
UIColor* DimColor(UIColor* color, CGFloat dimFactor);
//__________________________________________________________________________________________________

//! Shift the hue component of the color.
UIColor* ColorWithHue(const UIColor* color, CGFloat hue);
//__________________________________________________________________________________________________

//! Mutiply the saturation component of the color.
UIColor* ColorWithSaturation(const UIColor* color, CGFloat saturation);
//__________________________________________________________________________________________________

//! Mutiply the brightness component of the color.
UIColor* ColorWithBrightness(const UIColor* color, CGFloat brightness);
//__________________________________________________________________________________________________

//! Mutiply the alpha component of the color.
UIColor* ColorWithAlpha(const UIColor* color, CGFloat alpha);
//__________________________________________________________________________________________________

//! Replace the hue component of the color.
UIColor* ReplaceColorHue(const UIColor* color, CGFloat hue);
//__________________________________________________________________________________________________

//! Replace the saturation component of the color.
UIColor* ReplaceColorSaturation(const UIColor* color, CGFloat saturation);
//__________________________________________________________________________________________________

//! Replace the brightness component of the color.
UIColor* ReplaceColorBrightness(const UIColor* color, CGFloat brightness);
//__________________________________________________________________________________________________

//! Replace the alpha component of the color.
UIColor* ReplaceColorAlpha(const UIColor* color, CGFloat alpha);
//__________________________________________________________________________________________________

UIColor* MixColors(const UIColor* color_1, const UIColor* color_2, CGFloat factor);
//__________________________________________________________________________________________________
