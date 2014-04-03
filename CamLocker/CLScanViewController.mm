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
#import "ETActivityIndicatorView.h"
#import "JDStatusBarNotification.h"
#import "MHNatGeoViewControllerTransition.h"
#import "EAGLView.h"

@interface CLScanViewController (){
    BOOL isDecrypting;
    BOOL isPopupViewPresented;
    int targetIndex;
    CLMarker *targetMarker;
}

@property (weak, nonatomic) IBOutlet UIButton *showButton;

@end


@implementation CLScanViewController


#pragma mark - UIViewController lifecycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    targetIndex = 0;
    isDecrypting = NO;
    isPopupViewPresented = NO;
    self.showButton.hidden = YES;
    
    // load frame
    
    NSString* imagePath = [[NSBundle mainBundle] pathForResource:@"Markers/frame.png" ofType:nil];
    
    if (imagePath)
    {
        imagePlane = m_metaioSDK->createGeometryFromImage([imagePath UTF8String]);
        if (imagePlane) {
            imagePlane->setScale(metaio::Vector3d(3.0, 3.0, 3.0));
        }
    } else NSLog(@"Error: could not load image plane");
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
    }];

}

- (void)handleEnteredBackground
{
    [[NSNotificationCenter defaultCenter] removeObserver:UIApplicationDidEnterBackgroundNotification];
    [[CLMarkerManager sharedManager] deactivateMarkers];
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

#pragma mark - App Logic

- (void)onTrackingEvent:(const metaio::stlcompat::Vector<metaio::TrackingValues>&)trackingValues
{
    if (isPopupViewPresented) {
        return;
    }
    
	if (trackingValues.empty() || !trackingValues[0].isTrackingState())
	{
        self.showButton.hidden = YES;
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
            self.showButton.hidden = NO;
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
    
    self.showButton.hidden = YES;
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
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
