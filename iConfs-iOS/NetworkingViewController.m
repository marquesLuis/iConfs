//
//  NetworkingViewController.m
//  iConfs-iOS
//
//  Created by Marta Lidon on 01/06/13.
//  Copyright (c) 2013 FCTUNL. All rights reserved.
//

#import "NetworkingViewController.h"

@interface NetworkingViewController ()

@end

@implementation NetworkingViewController
@synthesize networkingDescriptionContent, networkingTitle, networkingDescription, personPhoto, personName, photoPath;


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
	// Do any additional setup after loading the view.
    
    self.title = networkingTitle.text;
    NSLog(@"22222");
    [self.networkingDescription setEditable:NO];
    self.networkingDescription.text = networkingDescriptionContent;
    NSLog(@"22222");
   // self.personPhoto = [[UIImageView alloc] initWithFrame:CGRectMake(200,10,100,50)];
    UIImage * imageFromURL = [UIImage imageWithContentsOfFile:photoPath];
    
    if(imageFromURL)
        NSLog(@"not nil");
    else
        NSLog(@"nil");
    
    [self.personPhoto setImage:imageFromURL];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end