//
//  CLTextViewController.m
//  CamLocker
//
//  Created by FlyinGeek on 3/4/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import "CLTextViewController.h"

@interface CLTextViewController ()

@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation CLTextViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    UIToolbar *toolbarBackground = [[UIToolbar alloc] initWithFrame:self.view.frame];
    [self.view addSubview:toolbarBackground];
    [self.view sendSubviewToBack:toolbarBackground];
    
    self.textView.text = self.hiddenText;
}

- (IBAction)quitButtonPressed:(id)sender {
    if (self.delegate) {
        [self.delegate dismissViewController];
    }
}


@end
