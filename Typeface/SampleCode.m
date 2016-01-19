
// The view has been loaded, start to make fun with the device inclination.
- (void)viewDidLoad
{
  [super viewDidLoad];

  // Prepare the parameter sets.
  ParameterSet0       = [[ParameterSet alloc] init];
  ParameterSet1       = [[ParameterSet alloc] init];
  ParameterSet2       = [[ParameterSet alloc] init];
  ParameterSet3       = [[ParameterSet alloc] init];
  ParameterSet4       = [[ParameterSet alloc] init];
  ParameterSet5       = [[ParameterSet alloc] init];
  ParameterSet6       = [[ParameterSet alloc] init];
  ParameterSet7       = [[ParameterSet alloc] init];
  InitialParameterSet = [[ParameterSet alloc] init];
  AnimationGroups.ParameterSet_0      = ParameterSet0;
  AnimationGroups.ParameterSet_1      = ParameterSet0;
  AnimationGroups.ParameterSet_2      = ParameterSet0;
  AnimationGroups.ParameterSet_3      = ParameterSet0;
  AnimationGroups.ParameterSet_4      = ParameterSet0;
  AnimationGroups.ParameterSet_5      = ParameterSet0;
  AnimationGroups.ParameterSet_6      = ParameterSet0;
  AnimationGroups.ParameterSet_7      = ParameterSet0;
  AnimationGroups.InitialParameterSet = InitialParameterSet;
  [self prepareParametersSet0];
  [self prepareParametersSet1];
  [self prepareParametersSet2];
  [self prepareParametersSet3];
  [self prepareParametersSet4];
  [self prepareParametersSet5];
  [self prepareParametersSet6];
  [self prepareParametersSet7];
  [self prepareInitialParametersSet];

  // Prepare the first animation group.
  NSTimeInterval referenceTime = 123456789.01234; // In this sample code, use arbitrary reference time.
  NSMutableArray* animGroup = [[NSMutableArray alloc] initWithCapacity:3];
  AnimationParameters* animation;
  animation = [[AnimationParameters alloc] init];
  [animation.texts addObject:@"Dot 1 Line 1"];
  [animation.texts addObject:@"Dot 1 Line 2"];
  [animation.texts addObject:@"Dot 1 Line 3"];
  [animation.texts addObject:@"Dot 1 Line 4"];
  [animation.texts addObject:@"Dot 2 Line 1"];
  [animation.texts addObject:@"Dot 2 Line 2"];
  [animation.texts addObject:@"Dot 2 Line 3"];
  [animation.texts addObject:@"Dot 2 Line 4"];
  [animation.texts addObject:@"Dot 3 Line 1"];
  animation.parameterSet = 1;
  animation.presshold    = YES;
  animation.time         = referenceTime + 1000;  // Some arbitrary time.
  [animGroup addObject:animation];

  animation = [[AnimationParameters alloc] init];
  [animation.texts addObject:@"Dot 1 Line 1"];
  animation.parameterSet = 6;
  animation.presshold    = YES;
  animation.time         = referenceTime + 2000;  // Some arbitrary time.
  [animGroup addObject:animation];

  animation = [[AnimationParameters alloc] init];
  [animation.texts addObject:@"Dot 1 Line 1"];
  animation.parameterSet = 3;
  animation.presshold    = NO;
  animation.time         = referenceTime + 12345;  // Some arbitrary time.
  [animGroup addObject:animation];

  [AnimationGroups.AnimationGroups addObject:animGroup];

  // Prepare more animation groups.
  //....

}
//__________________________________________________________________________________________________

- (void)CalculateSnapPointForText:(GroupTextParameters*)text
                      snapPosLeft:(CGFloat)snapPosLeft          //!< Horizontal position of texts 0 and 2 snap points (in fraction of view width).
                     snapPosRight:(CGFloat)snapPosRight         //!< Horizontal position of texts 1 and 3 snap points (in fraction of view width).
                       snapPosTop:(CGFloat)snapPosTop           //!< Vertical position of text 0 snap point (in fraction of view height).
              snapPosVerticalStep:(CGFloat)snapPosVerticalStep  //!< Vertical distance between text snap points (in fraction of view height).
                        textIndex:(int)index
{
  text.snapPoint = CGPointMake(AnimationGroups.frame.size.width  * ((index % 2)? snapPosRight: snapPosLeft),
                               AnimationGroups.frame.size.height * (snapPosTop + snapPosVerticalStep * index));
}
//__________________________________________________________________________________________________

- (void)prepareParametersSet0;
{
  const int numTimelines            = 6;
  const int numTexts[numTimelines]  = {6, 5, 4, 3, 2, 1};
  const CGFloat pushMagnitudes[6]   = {1, 2.5, 1, 1.5, 2, 0.5};
  UIColor* textColors[6]            = {[UIColor redColor], [UIColor yellowColor], [UIColor greenColor], [UIColor blueColor], [UIColor orangeColor], [UIColor purpleColor]};
  UIColor* textBackgroundColors[6]  = {[UIColor cyanColor], [UIColor blueColor], [UIColor magentaColor], [UIColor yellowColor], [UIColor greenColor], [UIColor brownColor]};

  int i;
  for (i = 0; i < numTimelines; i++)
  {
    int num_texts = numTexts[i];
    CGFloat snapPosLeft           = 1.0 / 3;
    CGFloat snapPosRight          = 2.0 / 3;
    CGFloat snapPosTop;
    CGFloat snapPosVerticalStep;
    if (Has4InchesScreen())
    {
      snapPosTop          = 2.0 / (num_texts + 2);
      snapPosVerticalStep = 1.0 / (num_texts + 2);
    }
    else
    {
      snapPosTop          = 1.0 / (num_texts + 1);
      snapPosVerticalStep = 1.0 / (num_texts + 1);
    }
    ParameterSet0.endOfStep1Time       = 1.0 * num_texts;
    ParameterSet0.endOfStep2Time       = ParameterSet0.endOfStep1Time + 3;
    ParameterSet0.endOfStep3Time       = ParameterSet0.endOfStep2Time + 3;
    ParameterSet0.endOfStep4Time       = ParameterSet0.endOfStep3Time + 3;
    int j;
    for (j = 0; j < numTexts[i]; j++)
    {
      GroupTextParameters* text = [[GroupTextParameters alloc] init];
      switch (j)
      {
      case 0:
        ParameterSet0.text_0 = text;
        break;
      case 1:
        ParameterSet0.text_1 = text;
        break;
      case 2:
        ParameterSet0.text_2 = text;
        break;
      case 3:
        ParameterSet0.text_3 = text;
        break;
      }
      [self CalculateSnapPointForText:text snapPosLeft:snapPosLeft snapPosRight:snapPosRight snapPosTop:snapPosTop snapPosVerticalStep:snapPosVerticalStep textIndex:j];
      text.fadingInStartTime  = j;
      text.fadingInDuration   = 2;
      text.fadingOutStartTime = 0 + 0.6 * (1 - (j + 1) / num_texts);
      text.fadingOutDuration  = 1 + 0.4 * (1 - (j + 1) / num_texts);
      text.collisionSnapDelay = 1.0;
      text.textInitialHorizontalOffset = (j % 2)? -20: 20;
      text.textInitialVerticalOffset = -50;
      text.textInitialAngle = (j % 2)? -0.1: 0.1;
      text.textAngularResistance = 0.05;
      text.textDensity = 1.0;
      text.textElasticity = 0.7;
      text.textFriction = 0.2;
      text.textResistance = 0.05;
      text.textSize = 20;
      text.textBackgroundMargin = 5;
      text.pushAngle = 0.5 + 0.1 * j;
      text.pushMagnitude = pushMagnitudes[j];
      text.pushDamping = 0.05;
      text.pushTargetOffset = UIOffsetMake((j % 2)? -100: 100, 0);
      text.textColor = ColorWithAlpha(textColors[j], 1.0);
      text.textBackgroundColor = ColorWithAlpha(textBackgroundColors[j], 0.25);
    }
  }

  ParameterSet0.gravityAmplitude          = 0.25;
  ParameterSet0.step4GravityAmplitude     = -0.25;
  ParameterSet0.gradientAnimationDelay    = 0;
  ParameterSet0.gradientAnimationDuration = 1.0;
  ParameterSet0.gradientTopColor          = [UIColor colorWithHue:(186 / 360.0) saturation:0.74 brightness:0.51 alpha:1];
  ParameterSet0.gradientBottomColor       = [UIColor colorWithHue:(179 / 360.0) saturation:0.50 brightness:0.73 alpha:1];
  ParameterSet0.gradientTimingFunction    = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
}
//__________________________________________________________________________________________________

- (void)prepareParametersSet1;
{
  ...
}
//__________________________________________________________________________________________________

- (void)prepareParametersSet2;
{
  ...
}
//__________________________________________________________________________________________________

- (void)prepareParametersSet3;
{
  ...
}
//__________________________________________________________________________________________________

- (void)prepareParametersSet4;
{
  ...
}
//__________________________________________________________________________________________________

- (void)prepareParametersSet5;
{
  ...
}
//__________________________________________________________________________________________________

- (void)prepareParametersSet6;
{
  ...
}
//__________________________________________________________________________________________________

- (void)prepareParametersSet7;
{
  ...
}
//__________________________________________________________________________________________________

- (void)prepareInitialParametersSet;
{ // In the initial parameter set, only the gradient colors will be used.
  ParameterSet0.gradientTopColor    = [UIColor colorWithHue:(186 / 360.0) saturation:0.74 brightness:0.51 alpha:1];
  ParameterSet0.gradientBottomColor = [UIColor colorWithHue:(179 / 360.0) saturation:0.50 brightness:0.73 alpha:1];
}
//__________________________________________________________________________________________________
