//
//  NetworkingViewController.m
//  iConfs-iOS
//
//  Created by Marta Lidon on 01/06/13.
//  Copyright (c) 2013 FCTUNL. All rights reserved.
//

#import "NetworkingViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "PersonProfileViewController.h"

@interface NetworkingViewController ()
@end

@implementation NetworkingViewController
@synthesize networkingDescriptionContent, networkingTitle, networkingDescription, personPhoto, personName, photoPath, netTitle, namePerson, personId, numNetworking;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = netTitle;
    networkingTitle.text = netTitle;
    self.navigationBar.topItem.title = netTitle;

    [personName setTitle: namePerson forState: UIControlStateNormal];
    [self.networkingDescription setEditable:NO];
    self.networkingDescription.text = networkingDescriptionContent;
   // self.personPhoto = [[UIImageView alloc] initWithFrame:CGRectMake(200,10,100,50)];
    UIImage * imageFromURL = [UIImage imageWithContentsOfFile:photoPath];
    [self.personPhoto setImage:imageFromURL];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*- (IBAction)personPage:(UIButton *)sender {
    //change view
   PersonProfileViewController *second= [self.storyboard instantiateViewControllerWithIdentifier:@"PersonProfileViewController"];
    second.personID = personId;
    //second.previous = self;
  //  [self performSegueWithIdentifier: @"segue3" sender: self];
   [self presentViewController:second animated:YES completion:nil];
}*/

/*- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    PersonProfileViewController *second = [[PersonProfileViewController alloc] init];
     second = [segue destinationViewController];
    second.personID = personId;
}*/


- (IBAction)goToPersonProfile:(UIButton *)sender {
    
    PersonProfileViewController * network = [self.storyboard instantiateViewControllerWithIdentifier:@"PersonProfileViewController"];
    network.personID = personId;
    [self presentViewController:network animated:YES completion:nil];
    
}

@end
