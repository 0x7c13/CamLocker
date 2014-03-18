//
//  CLImageViewController.m
//  CamLocker
//
//  Created by FlyinGeek on 3/4/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import "CLImageViewController.h"

@interface CLImageViewController ()

@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation CLImageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    UIToolbar *toolbarBackground = [[UIToolbar alloc] initWithFrame:self.view.frame];
    [self.view addSubview:toolbarBackground];
    [self.view sendSubviewToBack:toolbarBackground];
 
    self.imageView.image = self.hiddenImage;
}

- (IBAction)quitButtonPressed:(id)sender {
    if (self.delegate) {
        [self.delegate dismissViewController];
    }
}


@end
