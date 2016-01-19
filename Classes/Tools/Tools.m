
//! \file   Tools.m
//! \brief  Definitions and functions that could be useful almost everywhere.
//__________________________________________________________________________________________________

#import <CoreText/CoreText.h>

#import "Tools.h"
//__________________________________________________________________________________________________

CGFloat GetFloatOsVersion(void)
{
  return [[[UIDevice currentDevice] systemVersion] floatValue];
}
//__________________________________________________________________________________________________

//! Check if this app is running in the simulator.
bool IsSimulator(void)
{
  return TARGET_IPHONE_SIMULATOR;
}
//__________________________________________________________________________________________________

//! Check if this device runs over iOS 8 or higher.
bool IsIOS_8(void)
{
  return (GetFloatOsVersion() >= 8.0);
}
//__________________________________________________________________________________________________

//! check if this device is an iPad.
bool IsIpad(void)
{
  return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
}
//__________________________________________________________________________________________________

//! Return YES if the device is curently in portrait orientation.
bool IsPortraitOrientation(void)
{
  return UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]);
}
//__________________________________________________________________________________________________

//! Return YES if the device is curently in landscape orientation.
bool IsLandscapeOrientation(void)
{
  return UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]);
}
//__________________________________________________________________________________________________

bool IsPortraitDirectOrientation(void)
{
  return ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait);
}
//__________________________________________________________________________________________________

bool IsPortraitUpsideDownOrientation(void)
{
  return ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortraitUpsideDown);
}
//__________________________________________________________________________________________________

bool IsLandscapeLeftOrientation(void)
{
  return ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeLeft);
}
//__________________________________________________________________________________________________

bool IsLandscapeRightOrientation(void)
{
  return ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeRight);
}
//__________________________________________________________________________________________________

static CGFloat CachedScreenScale  = 0;
static CGFloat CachedScreenWidth  = 0;
static CGFloat CachedScreenHeight = 0;
//__________________________________________________________________________________________________

CGFloat GetScreenScale(void)
{
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^
  {
    CachedScreenScale = [[UIScreen mainScreen] scale];
  });
  return CachedScreenScale;
}
//__________________________________________________________________________________________________

CGFloat GetScreenWidth(void)
{
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^
  {
    if (IsIOS_8())
    {
      CachedScreenWidth = [UIScreen mainScreen].nativeBounds.size.width / GetScreenScale();
    }
    else
    {
      CGSize size = [UIScreen mainScreen].bounds.size;
      if (size.width < size.height)
      {
        CachedScreenWidth = [UIScreen mainScreen].bounds.size.width;
      }
      else
      {
        CachedScreenWidth = [UIScreen mainScreen].bounds.size.height;
      }
    }
  });
  return CachedScreenWidth;
}
//__________________________________________________________________________________________________

CGFloat GetScreenHeight(void)
{
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^
  {
    if (IsIOS_8())
    {
      CachedScreenHeight = [UIScreen mainScreen].nativeBounds.size.height / GetScreenScale();
    }
    else
    {
      CGSize size = [UIScreen mainScreen].bounds.size;
      if (size.width < size.height)
      {
        CachedScreenHeight = [UIScreen mainScreen].bounds.size.height;
      }
      else
      {
        CachedScreenHeight = [UIScreen mainScreen].bounds.size.width;
      }
    }
  });
  return CachedScreenHeight;
}
//__________________________________________________________________________________________________

CGFloat GetStatusBarHeight(void)
{
  CGSize statusBarSize = [[UIApplication sharedApplication] statusBarFrame].size;
  return MIN(statusBarSize.width, statusBarSize.height);
}
//__________________________________________________________________________________________________

//! Rename a file.
bool RenameUrlFile(NSURL* oldUrl, NSURL* newUrl)
{
  NSError* error;
  NSFileManager* manager = [NSFileManager defaultManager];
  return [manager moveItemAtURL:oldUrl toURL:newUrl error:&error];
}
//__________________________________________________________________________________________________

//! Delete a file.
bool DeleteUrlFile(NSURL* url)
{
  NSError* error;
  NSFileManager* manager = [NSFileManager defaultManager];
  return [manager removeItemAtURL:url error:&error];
}
//__________________________________________________________________________________________________

//! Get the Url of a file in the documents folder.
NSURL* UrlOfFileInDocumentsFolder(NSString* fileName, NSString* extension)
{
  NSString* docsDir     = ((NSURL*)[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject]).path;
  NSString* recordPath  = [[docsDir stringByAppendingPathComponent:fileName] stringByAppendingPathExtension:extension];
  return [NSURL fileURLWithPath:recordPath];
}
//__________________________________________________________________________________________________

CGSize CalculateTextSize
(
        NSString* text,
  const CGSize    constraintToSize,
        UIFont*   font
)
{
  CGSize textSize = [text boundingRectWithSize:constraintToSize
                                       options:NSStringDrawingUsesLineFragmentOrigin
                                    attributes:@{NSFontAttributeName:font}
                                       context:nil].size;
  textSize.width  = ceil(textSize.width);
  textSize.height = ceil(textSize.height);
  return textSize;
}
//__________________________________________________________________________________________________

CGSize CalculateAttributedTextSize
(
        NSAttributedString* attrString,
  const CGSize              constraintToSize
)
{
  CGSize textSize = [attrString boundingRectWithSize:constraintToSize options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
  textSize.width  = ceil(textSize.width);
  textSize.height = ceil(textSize.height);
//  NSLog(@"CalculateAttributedTextSize: %f, %f, (%f, %f), %@", textSize.width, textSize.height, constraintToSize.width, constraintToSize.height, attrString);
  return textSize;
}
//__________________________________________________________________________________________________
