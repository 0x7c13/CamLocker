//
//  CLScanViewController
//  CamLocker
//
//  Created by FlyinGeek on 3/4/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import "CLMarker.h"
#import "CLTextMarker.h"
#import "CLImageMarker.h"
#import "CLMarkerManager.h"
#import "CLTrackingXMLGenerator.h"
#import "CLScanViewController.h"
#import "FBShimmeringView.h"
#import "ETActivityIndicatorView.h"
#import "JDStatusBarNotification.h"
#import "UIColor+MLPFlatColors.h"
#import "MHNatGeoViewControllerTransition.h"
#import "EAGLView.h"

@interface CLScanViewController (){
    BOOL isDecrypting;
    BOOL isPopupViewPresented;
    int targetIndex;
    CLMarker *targetMarker;
}

@property (weak, nonatomic) IBOutlet UIView *blurView;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet FBShimmeringView *shimmeringView;

@end


@implementation CLScanViewController


#pragma mark - UIViewController lifecycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    targetIndex = 0;
    isDecrypting = NO;
    isPopupViewPresented = NO;
    self.shimmeringView.hidden = YES;
    self.backButton.hidden = YES;
    // load frame
    
    NSString* imagePath = [[NSBundle mainBundle] pathForResource:@"Markers/frame.png" ofType:nil];
    
    if (imagePath)
    {
        imagePlane = m_metaioSDK->createGeometryFromImage([imagePath UTF8String]);
        imagePlane->setName("frame");
        if (imagePlane) {
            imagePlane->setScale(metaio::Vector3d(3.0, 3.0, 3.0));
        }
    } else NSLog(@"Error: could not load image plane");
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:self.blurView.bounds];
    toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.blurView addSubview:toolbar];
    self.blurView.alpha = 0.0f;
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    UILabel *loadingLabel = [[UILabel alloc] initWithFrame:self.shimmeringView.bounds];
    loadingLabel.textAlignment = NSTextAlignmentCenter;
    loadingLabel.font = [UIFont fontWithName:@"OpenSans" size:38];
    loadingLabel.textColor = [UIColor flatRedColor];
    loadingLabel.text = NSLocalizedString(@"Tap to unlock", nil);
    self.shimmeringView.contentView = loadingLabel;
    self.shimmeringView.shimmering = YES;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    ETActivityIndicatorView *etActivity = [[ETActivityIndicatorView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 30, self.view.frame.size.height/1.3 -30, 60, 60)];
    [etActivity startAnimating];
    [self.glView addSubview:etActivity];
    
    [[CLMarkerManager sharedManager] activateMarkersWithCompletionBlock:^{
        
        NSString* trackingDataFile = [[CLMarkerManager sharedManager] trackingFilePath];
        
        if(trackingDataFile)
        {
            bool success = m_metaioSDK->setTrackingConfiguration([trackingDataFile UTF8String]);
            if( !success)
                NSLog(@"No success loading the tracking configuration");
        } else {
            NSLog(@"Cannot open file on disk");
        }
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(handleEnteredBackground)
                                                     name: UIApplicationDidEnterBackgroundNotification
                                                   object: nil];
        
        [etActivity stopAnimating];
        [etActivity removeFromSuperview];
        self.backButton.hidden = NO;
    }];

}

- (void)handleEnteredBackground
{
    [[NSNotificationCenter defaultCenter] removeObserver:UIApplicationDidEnterBackgroundNotification];
    [[CLMarkerManager sharedManager] deactivateMarkers];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self dismissNatGeoViewController];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [super viewDidDisappear:animated];
}

#pragma mark - Handling Touches

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Here's how to pick a geometry
	UITouch *touch = [touches anyObject];
	CGPoint loc = [touch locationInView:glView];
	
    // get the scale factor (will be 2 for retina screens)
    float scale = glView.contentScaleFactor;
    
	// ask sdk if the user picked an object
	// the 'true' flag tells sdk to actually use the vertices for a hit-test, instead of just the bounding box
    metaio::IGeometry* model = m_metaioSDK->getGeometryFromScreenCoordinates(loc.x * scale, loc.y * scale, true);
	
	if ( model )
	{
        NSString *modelName =[NSString stringWithUTF8String:model->getName().c_str()];
        if ([modelName isEqualToString:@"frame"]) {
            [self showButtonPressed:nil];
        }
    }
	
}

#pragma mark - App Logic

- (void)onTrackingEvent:(const metaio::stlcompat::Vector<metaio::TrackingValues>&)trackingValues
{
    if (isPopupViewPresented) {
        return;
    }
    
	if (trackingValues.empty() || !trackingValues[0].isTrackingState())
	{
        self.shimmeringView.hidden = YES;
        imagePlane->setVisible(0);
	}
	else
	{
        NSString *cosName = [NSString stringWithUTF8String:trackingValues[0].cosName.c_str()];
        
        CLMarker *marker = [[CLMarkerManager sharedManager] markerByCosName:cosName];
        
        if (marker) {
            imagePlane->setCoordinateSystemID(trackingValues[0].coordinateSystemID);
            imagePlane->setVisible(true);
            targetMarker = marker;
            self.shimmeringView.hidden = NO;
        }
	}
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    // allow rotation in all directions
    return YES;
}

- (void)dismissViewController
{
    
    [self dismissPopupViewControllerAnimated:YES completion:^{
        isPopupViewPresented = NO;
        [UIView animateWithDuration:1.0f animations:^{
            self.blurView.alpha = 0.0f;
        }];
    }];
}

- (IBAction)exit:(id)sender {
    
    [[NSNotificationCenter defaultCenter] removeObserver:UIApplicationDidEnterBackgroundNotification];
    [[CLMarkerManager sharedManager] deactivateMarkers];
    
    //[self dismissViewControllerAnimated:YES completion:nil];
    [self dismissNatGeoViewController];
}

- (IBAction)showButtonPressed:(id)sender {
    
    if (isDecrypting) return;
    
    self.shimmeringView.hidden = YES;
    imagePlane->setVisible(false);
    
    if ([targetMarker isKindOfClass:[CLTextMarker class]]) {
        
        isPopupViewPresented = YES;
        CLTextViewController *textVC = [[CLTextViewController alloc] initWithNibName:@"CLTextViewController" bundle:nil];
        [(CLTextMarker *)targetMarker decryptHiddenTextWithCompletionBlock:^(NSString *hiddenText){
            textVC.hiddenText = hiddenText;
        }];
        textVC.delegate = self;
        [self presentPopupViewController:textVC animated:YES completion:nil];
        
    } else if ([targetMarker isKindOfClass:[CLImageMarker class]]) {

        isDecrypting = YES;
        
        [JDStatusBarNotification showWithStatus:@"Decrypting..." styleName:JDStatusBarStyleError];
        
        [(CLImageMarker *)targetMarker decryptHiddenImagesWithCompletionBlock:^(NSArray *images){
           
            isPopupViewPresented = YES;
            CLImageViewController *imageVC = [[CLImageViewController alloc] initWithNibName:@"CLImageViewController" bundle:nil];
            imageVC.hiddenImages = images;
            imageVC.delegate = self;
            [self presentPopupViewController:imageVC animated:YES completion:nil];
            isDecrypting = NO;
            [JDStatusBarNotification showWithStatus:@"Decryption succeeded!" dismissAfter:1.0f styleName:JDStatusBarStyleSuccess];
        }];
    }
    [UIView animateWithDuration:1.0f animations:^{
        self.blurView.alpha = 1.0f;
    }];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


@end
