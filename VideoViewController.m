//
//  ViewController.m
//  VideoCover


#import "VideoViewController.h"
#import "AppViewController.h"
#import "NavigationView.h"
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import <POP/POP.h>
#import "Parse.h"
#import "Alert.h"
#import <Contacts/Contacts.h>
#import <addressbook/addressbook.h>
#import "Mixpanel.h"
#import "FriendSelectionView.h"

@interface VideoViewController ()

@property (nonatomic, strong) AVPlayer *avplayer;
@property (strong, nonatomic) IBOutlet UIView *movieView;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;

- (IBAction)button:(id)sender;
- (IBAction)button2:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet UIButton *button2;

@property (strong, nonatomic) IBOutlet UIImageView *logo;
@property (strong, nonatomic) IBOutlet UILabel *firstLabel;
@property (weak, nonatomic) IBOutlet UILabel *label2;

@end


@implementation VideoViewController
{

    UIAlertController * alertController;
    UIAlertController * alertController2;
    BOOL didLogin;
    BOOL contactBOOL;
    BOOL notificationBOOL;

}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    _label2.hidden = YES;
    didLogin = NO;
    contactBOOL = NO;
    notificationBOOL = NO;
    self.view.frame = [[UIScreen mainScreen] bounds];
    /*-----------------------------------------------------------------------------------------*/
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeLeft];
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRight];
    


    
    
    _button.hidden = YES;
    _button.layer.borderWidth = 4.0f;
    _button.layer.borderColor = [UIColor grayColor].CGColor;
    _button.layer.cornerRadius = 20.0f;
    
    _button2.hidden = YES;
    _button2.layer.borderWidth = 4.0f;
    _button2.layer.borderColor = [UIColor grayColor].CGColor;
    _button2.layer.cornerRadius = 20.0f;
    

    
    

 

    

    NSError *sessionError = nil;
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:&sessionError];
    [[AVAudioSession sharedInstance] setActive:YES error:&sessionError];
    
    //Set up player
    [self setUpVideo:@"typeface.m4v" :@"mov"];

    
    //Config player
    [self.avplayer seekToTime:kCMTimeZero];
    [self.avplayer setVolume:0.0f];
    [self.avplayer setActionAtItemEnd:AVPlayerActionAtItemEndNone];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[self.avplayer currentItem]];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerStartPlaying)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
 

    
    alertController =[ UIAlertController
                      alertControllerWithTitle:@"Camera access is required"
                      message:@" To continue, you must enable camera access in the Settings app."
                      preferredStyle:UIAlertControllerStyleAlert];
    
    alertController2 =[ UIAlertController
                      alertControllerWithTitle:@"Please enable notifications"
                      message:@"To be alerted when friends message you, please enable notifications in the Settings app."
                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"Cancel action");
                                       _label2.text = @" Sorry but we cannot continue";
                                   }];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:@"Launch Settings"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {

                                       NSURL *appSettings = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                       [[UIApplication sharedApplication] openURL:appSettings];
                                   
                                   _label2.text = @" Ready to continue?";
                               }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [alertController2 addAction:cancelAction];
    [alertController2 addAction:okAction];
    
    
}



- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!didLogin)
    {
    self.pageControl.currentPage = 0;
    }
    else
    {
        _logo.hidden = NO;
        _firstLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:20];
        _firstLabel.text = @" We need these allowed";
        
        _firstLabel.hidden = NO;
        _label2.hidden = YES;
        _button.hidden = NO;
        [_button setTitle:@"Find Friends >" forState:UIControlStateNormal];
        _button2.hidden = NO;
        NSString *string = @"This is how you practice safe text";
        NSString *string2 = @"Ready to typeface?";
        _label2.text = [NSString stringWithFormat:@"%@\r%@", string,string2];
        self.pageControl.currentPage = 5;
    }
    [self.avplayer play];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero];
}

- (void)playerStartPlaying
{
    [self.avplayer play];
}



-(void)cameraPermission
{
    
    //[camera pop_addAnimation:spring forKey:@"springAnimation"];
    
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        // Will get here on both iOS 7 & 8 even though camera permissions weren't required
        // until iOS 8. So for iOS 7 permission will always be granted.
        if (granted) {
            // Permission has been granted. Use dispatch_async for any UI updating
            // code because this block may be executed in a thread.
            dispatch_async(dispatch_get_main_queue(), ^{
            didLogin = YES;
            [self dismissViewControllerAnimated:YES completion:nil];
            });
        } else {
            // Permission has been denied.
            dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:alertController animated:YES completion:nil];
            });
        }
        _button.backgroundColor = [UIColor colorWithRed:1.00 green:0.28 blue:0.44 alpha:1.0];
        [_button setTitleColor:[UIColor darkGrayColor] forState: UIControlStateNormal];
    }];
    
    
}

-(void)contactPermission
{
    
    CNContactStore* addressBook = [[CNContactStore alloc]init];
    CNAuthorizationStatus permissions = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    if(permissions == CNAuthorizationStatusNotDetermined) {
        
        [addressBook requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable contactError) {
            
            if (granted)
            {
                [self contactsync];

            }
            else
            {}
        }];
    }

    _button.backgroundColor = [UIColor colorWithRed:1.00 green:0.28 blue:0.44 alpha:1.0];
    [_button setTitleColor:[UIColor darkGrayColor] forState: UIControlStateNormal];
    
}

-(void) contactsync
{

    NSMutableArray *fullName = [[NSMutableArray alloc]init];
    NSMutableArray *phoneNumber = [[NSMutableArray alloc]init];
    if ([recentListUsers count] == 0)
    {
        NSLog(@"INITIATING CONTACT SYNC"); // IMPORTANT
        
        // NSMutableArray *contacts = [[NSMutableArray alloc]init];
        
        if([CNContactStore class]) // this is where you say yes or noiOS 9 or later
        {
            
            
            CNContactStore* addressBook = [[CNContactStore alloc]init];
            CNAuthorizationStatus permissions = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
            if(permissions == CNAuthorizationStatusNotDetermined || permissions == CNAuthorizationStatusAuthorized) {
                
                [addressBook requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable contactError) {
                    
                    if (granted)
                    {
                        NSLog(@"Said YES to Contacts Sync");
                        
                        Mixpanel *mixpanel = [Mixpanel sharedInstance];
                        
                        [mixpanel track:@"Said YES to Contacts Sync"];
                        
                        [mixpanel identify:mixpanel.distinctId];
                        
                        [mixpanel.people increment:@"Said YES to Contacts Sync" by:[NSNumber numberWithInt:1]];
                        
                        
                        [addressBook containersMatchingPredicate:[CNContainer predicateForContainersWithIdentifiers: @[addressBook.defaultContainerIdentifier]] error:&contactError];
                        
                        
                        NSArray * keysToFetch =@[CNContactEmailAddressesKey, CNContactPhoneNumbersKey, CNContactFamilyNameKey, CNContactGivenNameKey, CNContactPostalAddressesKey];
                        CNContactFetchRequest * request = [[CNContactFetchRequest alloc]initWithKeysToFetch:keysToFetch];
                        
                        
                        [addressBook enumerateContactsWithFetchRequest:request error:&contactError usingBlock:^(CNContact * __nonnull contact, BOOL * __nonnull stop){
                            
                            NSString *name = [NSString stringWithFormat:@"%@ %@",contact.givenName,contact.familyName];
                            NSString *phone = [NSString string];
                            
                            for (CNLabeledValue *value in contact.phoneNumbers) {
                                
                                if ([value.label isEqualToString:@"_$!<Mobile>!$_"])
                                {
                                    CNPhoneNumber *phoneNum = value.value;
                                    phone = phoneNum.stringValue;
                                }
                                
                                if ([phone isEqualToString:@""])
                                {
                                    if ([value.label isEqualToString:@"_$!<Home>!$_"])
                                    {
                                        CNPhoneNumber *phoneNum = value.value;
                                        phone = phoneNum.stringValue;
                                    }
                                }
                                if ([phone isEqualToString:@""])
                                {
                                    if ([value.label isEqualToString:@"_$!<Work>!$_"])
                                    {
                                        CNPhoneNumber *phoneNum = value.value;
                                        phone = phoneNum.stringValue;
                                    }
                                }
                                
                            }
                            
                            [fullName addObject:name];
                            [phoneNumber addObject:[self formatNumber:phone]];
                            
                            
                            
                        }];
                        
                        [self updateTable:fullName phone:phoneNumber];
                        
                        
                    }
                    
                    else
                        
                    {
                        
                        NSLog(@"You said NO to Contacts");
                        
                        Mixpanel *mixpanel = [Mixpanel sharedInstance];
                        
                        [mixpanel track:@"Said NO to Contacts Sync"];
                        
                        [mixpanel identify:mixpanel.distinctId];
                        
                        [mixpanel.people increment:@"Said NO to Contacts Sync" by:[NSNumber numberWithInt:1]];
                        
                        
                    }
                    
                    
                    
                }];
                
            }
            
            else
            {
                NSLog(@"did not ask permissions");
            }
        }
        
        
        else
        {
            
            __block NSString *firstName;
            __block NSString *lastName;
            ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
            if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized)
            {
                
                CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBookRef);
                CFIndex numberOfPeople = CFArrayGetCount(allPeople);
                NSLog(@"%lu", numberOfPeople);
                for(int  i = 0; i < numberOfPeople; i++) {
                    
                    ABRecordRef person = CFArrayGetValueAtIndex( allPeople, i );
                    // Use a general Core Foundation object.
                    CFTypeRef generalCFObject = ABRecordCopyValue(person, kABPersonFirstNameProperty);
                    
                    // Get the first name.
                    if (generalCFObject) {
                        firstName =(__bridge NSString *)generalCFObject;
                        CFRelease(generalCFObject);
                    }
                    
                    // Get the last name.
                    generalCFObject = ABRecordCopyValue(person, kABPersonLastNameProperty);
                    if (generalCFObject) {
                        lastName =(__bridge NSString *)generalCFObject;
                        CFRelease(generalCFObject);
                    }
                    [fullName addObject: [NSString stringWithFormat:@"%@ %@", firstName, lastName]];
                    NSLog(@"%@", [fullName objectAtIndex:i]);
                    ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
                    
                    for (CFIndex j = 0; j < ABMultiValueGetCount(phoneNumbers); j++) {
                        CFStringRef currentPhoneLabel = ABMultiValueCopyLabelAtIndex(phoneNumbers, j);
                        CFStringRef currentPhoneValue = ABMultiValueCopyValueAtIndex(phoneNumbers, j);
                        
                        if (CFStringCompare(currentPhoneLabel, kABPersonPhoneMobileLabel, 0) == kCFCompareEqualTo) {
                            [phoneNumber addObject:[self formatNumber:(__bridge NSString *)currentPhoneValue]];
                        }
                        
                        else if (CFStringCompare(currentPhoneLabel, kABHomeLabel, 0) == kCFCompareEqualTo) {
                            [phoneNumber addObject:[self formatNumber:(__bridge NSString *)currentPhoneValue]];                 }
                        else if (CFStringCompare(currentPhoneLabel, kABWorkLabel, 0) == kCFCompareEqualTo) {
                            [phoneNumber addObject:[self formatNumber:(__bridge NSString *)currentPhoneValue]];
                        }
                        
                        CFRelease(currentPhoneLabel);
                        CFRelease(currentPhoneValue);
                    }
                    CFRelease(phoneNumbers);
                    
                }
                
                
            }
            
            
            [self updateTable:fullName phone:phoneNumber];
            
            
            
            
        }
        
        [[PFUser currentUser] setObject:@YES forKey:@"didContactSync"];
        [[PFUser currentUser]saveInBackground];
    }
    
}
-(void)updateTable:(NSArray*)fullName phone:(NSArray*)phoneNumber
{
    NSMutableArray *contacts = [[NSMutableArray alloc] init];
    
    PFQuery *query = [PFUser query];
    
    [query whereKey:@"phoneNumber" containedIn:phoneNumber];
    // NSLog(@" this %@ ", [query findObjects]);
    //NSLog(@"%@, %@",fullName, phoneNumber);
    NSInteger index = 0;
    if(recentListUsers == nil)
    {
        recentListUsers = [[NSMutableArray alloc]init];
    }
    
    for (NSString* name in fullName)
    {
        BOOL containsLetter = NSNotFound != [name rangeOfCharacterFromSet:NSCharacterSet.letterCharacterSet].location;
        if(containsLetter)
        {
            // if (![name isEqualToString:@""];
            //NSLog( @"timestampstring:%@ timestampdouble:%f",timeStamp, [[NSDate date] timeIntervalSince1970]);
            FriendRecord * newUser = [FriendRecord new];
            newUser.fullName = name;
            newUser.phoneNumber = [phoneNumber objectAtIndex:index];
            newUser.lastActivityTime = [[NSDate date] timeIntervalSince1970];
            
            
            index++;
            
            [recentListUsers addObject:newUser];
        }
    }
    
    
    
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if (!error) {
            if(objects != nil)
            {NSLog(@"The find succeeded");
                // NSLog(@"%@", objects);
            }
            
            
            for (PFUser* object in objects)
            {
                NSLog(@"%@", object.username);
                PFQuery *pushQuery = [PFInstallation query];
                [pushQuery whereKey:@"user" equalTo:object];
                NSString * Name = [[PFUser currentUser] objectForKey:@"fullName"];
                NSString * Username = [[PFUser currentUser] objectForKey:@"username"];
                
                // Send push notification to query
                NSDictionary *data = @{
                                       
                                       @"content-available": @"1",
                                       @"alert" : [NSString stringWithFormat:@"Uh-oh! %@ (%@) is now on Typeface! 🙈" ,Name, Username],
                                       @"sound" : @"digi_blip_hi_2x.aif",
                                       @"p" :[PFUser currentUser].objectId,
                                       @"t" :[PFUser currentUser][@"phoneNumber"]
                                       };
                
                PFPush *push = [[PFPush alloc] init];
                [push setQuery:pushQuery];
                [push setMessage:@"this works"];
                [push setData:data];
                [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *sendError)
                 {
                     NSLog(@"Sending Push");
                 }];
                
                [[PFUser currentUser] addUniqueObject:object.objectId forKey:@"friends"];
                [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *saveerror) {
                }];
                
            }
            
            [GetCurrentParseUser() loadFriendsListWithCompletion:^(NSArray* friends, NSError* loadError)
             {
                 
                 PFObject* localDatastore = [PFObject objectWithClassName:@"localDatastore"];
                 
                 UpdateFriendRecordListForFriends(friends);
                 
                 
                 for (NSInteger i=0; i < [recentListUsers count]; i++)
                 {
                     
                     FriendRecord *temprecord = [recentListUsers objectAtIndex:i];
                     for (FriendRecord *record in GetNameSortedFriendRecords())
                     {
                         
                         if ([temprecord.phoneNumber isEqualToString: record.phoneNumber] )
                         {
                             recentListUsers[i] = record;
                             break;
                         }
                         
                     }
                     
                     FriendRecord *anothertemprecord = recentListUsers[i];
                     NSMutableDictionary *contact;
                     if (anothertemprecord.user == nil)
                     {
                         contact = [[NSMutableDictionary alloc] initWithObjects:@[anothertemprecord.fullName, anothertemprecord.phoneNumber, [NSString stringWithFormat:@"%f",anothertemprecord.lastActivityTime], ] forKeys:@[@"fullName", @"phoneNumber", @"lastActivityTime"]];
                     }
                     else
                     {
                         contact = [[NSMutableDictionary alloc] initWithObjects:@[anothertemprecord.fullName, anothertemprecord.phoneNumber, [NSString stringWithFormat:@"%f",anothertemprecord.lastActivityTime], anothertemprecord.user] forKeys:@[@"fullName", @"phoneNumber", @"lastActivityTime", @"user"]];
                     }
                     
                     
                     NSLog(@"contact:%@", contact);
                     
                     
                     [contacts addObject:contact];
                 }
                 [recentListUsers sortUsingComparator:^NSComparisonResult(id obj1, id obj2)
                  {
                      FriendRecord* record1 = (FriendRecord*)obj1;
                      FriendRecord* record2 = (FriendRecord*)obj2;
                      
                      return ([record1.fullName caseInsensitiveCompare:record2.fullName]);
                  }];
                 
                 [localDatastore addUniqueObjectsFromArray:contacts forKey:@"FriendsList"];
                 
                 [localDatastore pinInBackgroundWithBlock:^(BOOL succeeded, NSError *pinError) {
                     NSLog(@"pinned");
                 }];
                 [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *saveerror2) {
                 }];
                 NSLog(@"contacts");
                 
                 
                 // NSLog(@"contacts: %@", contacts);
                 
             }];
        }
        
        
        
        else {
            NSLog(@"Did not find anyone");
            
        }
        
    }];

    if (contactBOOL && notificationBOOL)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:YES completion:nil];
        });
    }
    
    
    
}

-(NSString*)formatNumber:(NSString*)mobileNumber
{
    
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"\u00a0" withString:@""];
    
    
    
    
    NSInteger length = [mobileNumber length];
    if(length > 10)
    {
        mobileNumber = [mobileNumber substringFromIndex: length-10];
        
    }
    
    
    return mobileNumber;
}


-(void)notificationPermission
{
 
    if (!ParseCheckPermissionForRemoteNotifications())
    {

                  ParseRegisterForRemoteNotifications(^(BOOL notificationsAreEnabled)
                                                      {
                                                          if (notificationsAreEnabled)
                                                          {
                                                              if (contactBOOL && notificationBOOL)
                                                              {
                                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                                      [self dismissViewControllerAnimated:YES completion:nil];
                                                                  });
                                                              }
                                                          }
                                                          else
                                                          {
                                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                                  [self presentViewController:alertController2 animated:YES completion:nil];
                                                              });
                                                          }

                                                      });
        
    }
    

    _button2.backgroundColor = [UIColor colorWithRed:1.00 green:0.28 blue:0.44 alpha:1.0];
    [_button2 setTitleColor:[UIColor darkGrayColor] forState: UIControlStateNormal];
}

-(void)setUpVideo:(NSString*)fileName :(NSString*)extension
{
    if (self.movieView.window != nil)
    {
        [self.movieView.window removeFromSuperview];
    }
    NSURL *movieURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:fileName ofType:extension]];
    AVAsset *avAsset = [AVAsset assetWithURL:movieURL];
    AVPlayerItem *avPlayerItem =[[AVPlayerItem alloc]initWithAsset:avAsset];
    self.avplayer = [[AVPlayer alloc]initWithPlayerItem:avPlayerItem];
    AVPlayerLayer *avPlayerLayer =[AVPlayerLayer playerLayerWithPlayer:self.avplayer];
    [avPlayerLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];

    [avPlayerLayer setFrame:self.view.frame];
    
    self.movieView.alpha = 0.7;
    [self.movieView.layer insertSublayer:avPlayerLayer atIndex:0]; // this sets up Video
    
}

- (void)swipe:(UISwipeGestureRecognizer *)swipeRecogniser
{
    POPBasicAnimation *disappear;
    disappear = [POPBasicAnimation animation];
    disappear.property = [POPAnimatableProperty propertyWithName:kPOPViewAlpha];
    disappear.toValue = @(0);
    
    if ([swipeRecogniser direction] == UISwipeGestureRecognizerDirectionLeft)
    {
        if (!(self.pageControl.currentPage == 0))
        {
            
            [disappear setCompletionBlock:^(POPAnimation *anim, BOOL finished) {
                if (finished)
                {
                    POPSpringAnimation *appear = [POPSpringAnimation animationWithPropertyNamed:kPOPViewAlpha];
                    appear.toValue = @(0.4);
                    [self.movieView pop_addAnimation:appear forKey:@"appear"];
                }
            }];
            
            [self.movieView pop_addAnimation:disappear forKey:@"disappear"];
            
            
            
            
            
        }
    }
        else if ([swipeRecogniser direction] == UISwipeGestureRecognizerDirectionRight)
        {
            if (!(self.pageControl.currentPage == 4))
            {
                
                [disappear setCompletionBlock:^(POPAnimation *anim, BOOL finished) {
                    if (finished)
                    {
                        POPBasicAnimation *appear = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
                        appear.toValue = @(0.4);
                        [self.movieView pop_addAnimation:appear forKey:@"appear"];
                    }
                }];
                [self.movieView pop_addAnimation:disappear forKey:@"disappear"];
                
                
            }
            
        }
    
    if (self.pageControl.currentPage != 5)
    {
        if ([swipeRecogniser direction] == UISwipeGestureRecognizerDirectionLeft)
        {
     
            self.pageControl.currentPage -=1;
            

        }
        else if  ([swipeRecogniser direction] == UISwipeGestureRecognizerDirectionRight)
        {
         if (self.pageControl.currentPage != 4)
             {
                self.pageControl.currentPage +=1;
             }

        }
    }

    
    NSLog(@" page Control : %lu", (long)self.pageControl.currentPage);
    NSInteger page = self.pageControl.currentPage;
    NSString *string;
    NSString *string2;
    switch (page)
    {
        case 0:
            _logo.hidden = NO;
            _firstLabel.hidden = NO;
            _label2.hidden = YES;
            break;
        case 1:
            _logo.hidden = YES;
            _firstLabel.hidden = YES;
            _label2.hidden = NO;
            _label2.text = @"Type something important then press face to attach a selfie";
            break;
        case 2:
            _label2.text = @"Press and hold the recipients' name to send the message";
            break;
        case 3:
            _label2.text = @"Press and hold the sender's name to read the message";
            _button.hidden = YES;
            break;
        case 4:
            string = @"This is how you practice safe text";
            string2 = @"Ready to typeface?";
            _label2.text = [NSString stringWithFormat:@"%@\r%@", string,string2];
            _button.hidden = NO;
            [_button setTitle:@"Allow Camera >"forState:UIControlStateNormal];
            
            
            
            break;
            
        default:
            break;
    }


}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)button:(id)sender {
    NSLog(@"%lu", _button.state);
    
    
    POPSpringAnimation *spring = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    spring.toValue = [NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)];
    spring.velocity = [NSValue valueWithCGPoint:CGPointMake(2, 2)];
    spring.springBounciness = 20.f;
    
    [spring setCompletionBlock:^(POPAnimation *anim, BOOL finished) {
        if (finished)
        {
            POPBasicAnimation* scaleAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPViewScaleXY];
            scaleAnimation.duration = 0.1;
            scaleAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(1, 1)];
            [_button pop_addAnimation:scaleAnimation forKey:@"scale"];
        }
    }];
    [_button pop_addAnimation:spring forKey:@"springy"];

    
    if (_button.state == 1)
    {
        _button.backgroundColor = [UIColor darkGrayColor];
            [_button setTitleColor:[UIColor colorWithRed:1.00 green:0.28 blue:0.44 alpha:1.0] forState: UIControlStateNormal];
   
    }
    if ([_button.titleLabel.text isEqualToString:@"Allow Camera >"])
    {
        NSLog(@"this is allow camera");
        [self cameraPermission];
    }
    else
    {
        contactBOOL = YES;
        [self contactPermission];
    }
}

- (IBAction)button2:(id)sender {
    if (_button2.state == 1)
    {
        _button2.backgroundColor = [UIColor darkGrayColor];
        [_button2 setTitleColor:[UIColor colorWithRed:1.00 green:0.28 blue:0.44 alpha:1.0] forState: UIControlStateNormal];
        
    }
    POPSpringAnimation *spring = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    spring.toValue = [NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)];
    spring.velocity = [NSValue valueWithCGPoint:CGPointMake(2, 2)];
    spring.springBounciness = 20.f;

    [spring setCompletionBlock:^(POPAnimation *anim, BOOL finished) {
        if (finished)
        {
            POPBasicAnimation* scaleAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPViewScaleXY];
            scaleAnimation.duration = 0.1;
            scaleAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(1, 1)];
            [_button2 pop_addAnimation:scaleAnimation forKey:@"scale"];
        }
    }];
        [_button2 pop_addAnimation:spring forKey:@"springy"];
    
    notificationBOOL = YES;
    [self notificationPermission];
}
@end
