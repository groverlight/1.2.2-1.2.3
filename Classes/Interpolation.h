
//! \file   Interpolation.h
//! \brief  Various interpolation functions.
//__________________________________________________________________________________________________

#import <UIKit/UIKit.h>
//__________________________________________________________________________________________________

//! Enumration of the possible hue interpolation directions.
typedef enum
{
  E_InterpolateRgb,         //!< Interpolate using RGB color model.
  E_InterpolateHueUp,       //!< Interpolate toward higher hue values.
  E_InterpolateHueDown,     //!< Interpolate toward lower hue value.
  E_InterpolateHueShortest, //!< Interpolate using the shortest hue path.
  E_InterpolateHueLongest   //!< Interpolate using the longest hue path.
} InterpolationMode;
//__________________________________________________________________________________________________

//! \brief  Interpolate between two UIColor objects in RGB or HSV color model.
//! \return the interpolated UIColor object.
UIColor* InterpolateColor
(
  CGFloat           interpolator, //!< Interpolation value.
  InterpolationMode mode,         //!< Mode of interpolation.
  UIColor*          startColor,   //!< First color to interpolate.
  UIColor*          endColor      //!< Second color to interpolate.
);
//__________________________________________________________________________________________________

//! \brief  Interpolate between two CGFloat values.
//! \return the CGFLoat interpolated value.
CGFloat InterpolateFloat
(
  CGFloat interpolator, //!< Interpolation value.
  CGFloat startValue,   //!< First value to interpolate.
  CGFloat endValue      //!< Second value to interpolate.
);
//__________________________________________________________________________________________________

//! \brief  Interpolate between two CGPoint objects.
//! \return the interpolated CGPoint.
CGPoint InterpolatePoint
(
  CGFloat interpolator, //!< Interpolation value.
  CGPoint startPoint,   //!< First point to interpolate.
  CGPoint endPoint      //!< Second point to interpolate.
);
//__________________________________________________________________________________________________

//! \brief  Interpolate between two CGSize objects.
//! \return the interpolated CGSize.
CGSize InterpolateSize
(
  CGFloat interpolator, //!< Interpolation value.
  CGSize  startSize,    //!< First size to interpolate.
  CGSize  endSize       //!< Second size to interpolate.
);
//__________________________________________________________________________________________________
