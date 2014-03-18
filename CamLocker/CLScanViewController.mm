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
#import "EAGLView.h"

@interface CLScanViewController (){
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
    isPopupViewPresented = NO;
    self.showButton.hidden = YES;
    
    [[CLMarkerManager sharedManager] activateMarkers];
    
	NSString* trackingDataFile = [[CLMarkerManager sharedManager] trackingFilePath];

	if(trackingDataFile)
	{
		bool success = m_metaioSDK->setTrackingConfiguration([trackingDataFile UTF8String]);
		if( !success)
			NSLog(@"No success loading the tracking configuration");
	} else {
        NSLog(@"Cannot open file on disk");
    }
    /*
    // loadimage
    
    for (int i = 1; i <= numberOfImagePlanes; i++) {
        NSString* imagePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%d", i] ofType:@"jpg" inDirectory:@"photos"];
        
        if (imagePath)
        {
            m_imagePlane[i] = m_metaioSDK->createGeometryFromImage([imagePath UTF8String]);
            if (m_imagePlane[i]) {
                m_imagePlane[i]->setScale(metaio::Vector3d(8.0, 8.0, 8.0));
            }
            else NSLog(@"Error: could not load image plane");
        }
    }
    
    // start with markerless tracking
    [self setActiveTrackingConfig:0];
     */

    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleEnteredBackground)
                                                 name: UIApplicationDidEnterBackgroundNotification
                                               object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleBecomeActive)
                                                 name: UIApplicationDidBecomeActiveNotification
                                               object: nil];
}

- (void)handleEnteredBackground
{
    [[CLMarkerManager sharedManager] deactivateMarkers];
}

- (void)handleBecomeActive
{
    [[CLMarkerManager sharedManager] activateMarkers];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
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
	}
	else
	{
        NSString *cosName = [NSString stringWithUTF8String:trackingValues[0].cosName.c_str()];
        
        CLMarker *marker = [[CLMarkerManager sharedManager] markerByCosName:cosName];
        
        if (marker) {
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
    
    [[NSNotificationCenter defaultCenter] removeObserver:UIApplicationDidBecomeActiveNotification];
    [[NSNotificationCenter defaultCenter] removeObserver:UIApplicationDidEnterBackgroundNotification];
    [[CLMarkerManager sharedManager] deactivateMarkers];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)showButtonPressed:(id)sender {
    
    if ([targetMarker isKindOfClass:[CLTextMarker class]]) {
        
        isPopupViewPresented = YES;
        CLTextViewController *textVC = [[CLTextViewController alloc] initWithNibName:@"CLTextViewController" bundle:nil];
        textVC.hiddenText = [(CLTextMarker *)targetMarker hiddenText];
        textVC.delegate = self;
        [self presentPopupViewController:textVC animated:YES completion:nil];
        
    } else if ([targetMarker isKindOfClass:[CLImageMarker class]]) {
        
        isPopupViewPresented = YES;
        CLImageViewController *imageVC = [[CLImageViewController alloc] initWithNibName:@"CLImageViewController" bundle:nil];
        imageVC.hiddenImage = [[(CLImageMarker *)targetMarker hiddenImages] objectAtIndex:0];
        imageVC.delegate = self;
        [self presentPopupViewController:imageVC animated:YES completion:nil];
    }
    
    self.showButton.hidden = YES;
}

@end
