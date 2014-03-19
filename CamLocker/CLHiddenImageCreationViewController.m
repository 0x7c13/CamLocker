//
//  CLHiddenImageCreationViewController.m
//  CamLocker
//
//  Created by FlyinGeek on 3/18/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import "CLMarkerManager.h"
#import "CLHiddenImageCreationViewController.h"
#import "JDStatusBarNotification.h"
#import "ETActivityIndicatorView.h"

@interface CLHiddenImageCreationViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    BOOL isEncrypting;
}

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIButton *addImageButton;

@end

@implementation CLHiddenImageCreationViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    isEncrypting = NO;
    self.imageView.hidden = YES;
    self.doneButton.hidden = YES;
}

- (IBAction)addImageButtonPressed:(id)sender {
    
    if (isEncrypting) return;
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (IBAction)doneButtonPressed:(id)sender {
    
    if (isEncrypting) return;
    isEncrypting = YES;
    ETActivityIndicatorView *etActivity = [[ETActivityIndicatorView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 30, self.view.frame.size.height/2 -30, 60, 60)];
    [etActivity startAnimating];
    [self.view addSubview:etActivity];
    [JDStatusBarNotification showWithStatus:@"Encrypting Data..." styleName:JDStatusBarStyleError];
    
    [[CLMarkerManager sharedManager] addImageMarkerWithMarkerImage:[CLMarkerManager sharedManager].tempMarkerImage
                                                      hiddenImages:@[self.imageView.image]
                                               withCompletionBlock:^{
                                                   [JDStatusBarNotification showWithStatus:@"New marker created!" dismissAfter:1.0f styleName:JDStatusBarStyleSuccess];
                                                   [CLMarkerManager sharedManager].tempMarkerImage = nil;
                                                   [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                                                   [etActivity stopAnimating];
                                                   [etActivity removeFromSuperview];
                                                   isEncrypting = NO;
    }];
}

#pragma mark - UIImagePickerControllerDelegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    self.imageView.image = chosenImage;
    self.imageView.hidden = NO;
    self.doneButton.hidden = NO;
    self.addImageButton.hidden = YES;
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}



@end
