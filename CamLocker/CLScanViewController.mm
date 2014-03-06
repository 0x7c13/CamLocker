//
//  CLScanViewController
//  CamLocker
//
//  Created by FlyinGeek on 3/4/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//


#import "CLScanViewController.h"
#import "EAGLView.h"

@interface CLScanViewController (){
    BOOL isPopupViewPresented;
    int targetIndex;
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
    
    // TODO: Add Multiple References Tracking
    // load our tracking configuration
	NSString* trackingDataFile = [[NSBundle mainBundle] pathForResource:@"TrackingData"
																 ofType:@"xml"
															inDirectory:@"Markers"];
    
    
	// if you want to test the 3D tracking, please uncomment the line below and comment the line above
	//NSString* trackingDataFile = [[NSBundle mainBundle] pathForResource:@"TrackingData_ML3D" ofType:@"xml" inDirectory:@"Tutorials/TutorialContentTypes/Assets"];
    
    
	if(trackingDataFile)
	{
		bool success = m_metaioSDK->setTrackingConfiguration([trackingDataFile UTF8String]);
		if( !success)
			NSLog(@"No success loading the tracking configuration");
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


- (void)viewDidUnload
{
    // Release any retained subviews of the main view.
    [super viewDidUnload];
}



- (void) setActiveTrackingConfig:(int)index
{
    switch (index)
    {
        case 0:
		{
            for (int i = 1; i <= numberOfImagePlanes; i++) {
                m_imagePlane[i]->setVisible(false);
            }

            break;
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
        self.showButton.hidden = YES;
	}
	else
	{
        NSInteger index = [[[NSString stringWithUTF8String:trackingValues[0].cosName.c_str()] substringFromIndex:13] integerValue];
		NSLog(@"%d", index);
        
        targetIndex = index;
        self.showButton.hidden = NO;
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

- (IBAction)showButtonPressed:(id)sender {
    
    
    switch (targetIndex) {
        case 1: {
            isPopupViewPresented = YES;
            CLImageViewController *imageVC = [[CLImageViewController alloc] initWithNibName:@"CLImageViewController" bundle:nil];
            imageVC.delegate = self;
            [self presentPopupViewController:imageVC animated:YES completion:nil];
            break;
        }
        case 2: {
            isPopupViewPresented = YES;
            CLTextViewController *textVC = [[CLTextViewController alloc] initWithNibName:@"CLTextViewController" bundle:nil];
            textVC.delegate = self;
            [self presentPopupViewController:textVC animated:YES completion:nil];
            break;
        }
            
        default:
            break;
    }
    self.showButton.hidden = YES;
}

@end
