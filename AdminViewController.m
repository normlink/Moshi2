//
//  AdminViewController.m
//  MoshiDex
//
//  Created by Yaniv Kerem on 5/5/14.
//  Copyright (c) 2014 Grants International Inc. All rights reserved.
//

#import "AdminViewController.h"

@interface AdminViewController (){
    
    UIImagePickerController *myPicker;
    __weak IBOutlet UITextField *nameText;
    __weak IBOutlet UITextField *numberText;
    __weak IBOutlet UITextField *seriesText;
    __weak IBOutlet UITextField *typeText;
    __weak IBOutlet UITextField *speciesText;
    __weak IBOutlet UITextField *rarityText;
    __weak IBOutlet UITextField *locationText;
    __weak IBOutlet UITextView *descriptionText;
    __weak IBOutlet UIImageView *imageView;
    __weak IBOutlet UILabel *approvedText;
    UIImage *chosenImage;
    UIActivityIndicatorView *activityInd;
}
- (IBAction)editApprove:(id)sender;
- (IBAction)selectPhoto:(id)sender;
- (IBAction)deleteMoshling:(id)sender;

@end

@implementation AdminViewController

@synthesize detailInfo,adminReloadVar;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    activityInd = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityInd.center = self.view.center;
    [activityInd setColor:[UIColor yellowColor]];
    [activityInd setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:activityInd];
    [self.view bringSubviewToFront:activityInd];
    [activityInd setHidden:YES];
    
    myPicker = [[UIImagePickerController alloc]init];
    myPicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    myPicker.allowsEditing = YES;
    myPicker.delegate = self;
    
    [self getPicDoText];
}

-(void) getPicDoText{
    
    PFFile* pic =[detailInfo objectForKey:@"MoshiPicture"];
    [pic getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            imageView.image = [UIImage imageWithData:data];
            chosenImage = imageView.image;
        }else {
            NSString *errorString = [[error userInfo] objectForKey:@"error"];
            UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorString delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [errorAlertView show];
        }
    }];
    
    nameText.text = detailInfo[@"MoshiName"];
    numberText.text = [NSString stringWithFormat:@"%@",detailInfo[@"MoshiNumber"]];
    seriesText.text = [NSString stringWithFormat:@"%@",detailInfo[@"MoshiSeries"]];
    speciesText.text = detailInfo[@"MoshiSpecies"];
    typeText.text = detailInfo[@"MoshiType"];
    locationText.text = detailInfo[@"MoshiLocation"];
    rarityText.text = detailInfo[@"MoshiRare"];
    descriptionText.text = detailInfo[@"MoshiDescription"];
    if ([detailInfo[@"MoshiApproved"] isEqual:@YES]) {
        approvedText.text = @"Approved: YES";
    } else {
        approvedText.text = @"Approved: NO";
    }
}

- (IBAction)editApprove:(id)sender {
    [self startAnimate];
    [self.adminDelegate adminReload:YES];
    //    [query whereKey:@"name" equalTo:[detailInfo objectForKey:@"name"]
    PFQuery *query = [PFQuery queryWithClassName:@"MoshiData"];
    [query getObjectInBackgroundWithId:detailInfo.objectId block:^(PFObject *mobject, NSError *error) {
        
        mobject[@"MoshiApproved"] = @YES;
        mobject[@"MoshiName"] = nameText.text;
        mobject[@"MoshiNumber"] = @([numberText.text intValue]);
        mobject[@"MoshiSeries"] = @([seriesText.text intValue]);
        mobject[@"MoshiSpecies"] = speciesText.text;
        mobject[@"MoshiType"] = typeText.text;
        mobject[@"MoshiLocation"] = locationText.text;
        mobject[@"MoshiRare"] = rarityText.text;
        mobject[@"MoshiDescription"] = descriptionText.text;
        
        NSData *photo = UIImagePNGRepresentation(chosenImage);
        PFFile *imageFile = [PFFile fileWithName:@"MM.png" data:photo];
        [mobject setObject:imageFile forKey:@"MoshiPicture"];
        
        [mobject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [self finishAnimate];
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                NSString *errorString = [[error userInfo] objectForKey:@"error"];
                NSLog(@"Error: %@", errorString);
                [self finishAnimate];
            }
        }];
    }];
}

- (IBAction)selectPhoto:(id)sender {
    [self presentViewController:myPicker animated:YES completion:nil];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    chosenImage = info[UIImagePickerControllerEditedImage];
    imageView.image = chosenImage;
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (IBAction)deleteMoshling:(id)sender {
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"You are about to delete this helpless Moshling!" delegate:self cancelButtonTitle:@"Ok to Delete" otherButtonTitles:@"Cancel",nil];
    alert.tag = 1;
    [alert show];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        if (alertView.tag == 1) {
            [self startAnimate];
            [self.adminDelegate adminReload:YES];
            
            // to delete entire object(row)
            [detailInfo deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    [self finishAnimate];
                    [self.navigationController popViewControllerAnimated:YES];
                } else {
                    NSString *errorString = [[error userInfo] objectForKey:@"error"];
                    UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorString delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                    [errorAlertView show];
                    
                    [self finishAnimate];
                }
            }];
        }
    }
//                alternate delete method
//                PFQuery *query = [PFQuery queryWithClassName:@"MoshiData"];
//                [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//                    if (!error) {
//                        NSMutableArray* moshiArray = [[NSMutableArray alloc] initWithArray:objects];
//                            for (PFObject* obj in moshiArray) {
//                                if ([obj[@"MoshiName"]   isEqualToString:@"" ]) {
//                                    [obj deleteInBackground];
//                            }}}
//                }];
    
}
- (void)startAnimate {
    [self.view setUserInteractionEnabled:NO];
    [activityInd setHidden:NO];
    [activityInd startAnimating];
}

- (void)finishAnimate {
    [activityInd setHidden:YES];
    [activityInd stopAnimating];
    [self.view setUserInteractionEnabled:YES];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
