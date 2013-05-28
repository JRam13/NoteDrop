//
//  ViewController.m
//  NoteDrop
//
//  Created by JRamos on 5/27/13.
//  Copyright (c) 2013 JRamos. All rights reserved.
//

#import "LinkHomeController.h"
#import <Dropbox/Dropbox.h>
#import "NotesController.h"


@interface LinkHomeController ()
@property (nonatomic, readonly) DBAccount *linkedAccount;

@end

@implementation LinkHomeController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    if (![self.navigationController isNavigationBarHidden])
        [self.navigationController setNavigationBarHidden:YES animated:NO];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    DBAccount *account = [[DBAccountManager sharedManager] linkedAccount];
	if (account) {
        //[account unlink];
        
        //set filesystem
        DBFilesystem *filesystem = [[DBFilesystem alloc] initWithAccount:account];
        
        NotesController *nc =
        [[NotesController alloc] initWithFilesystem:filesystem root:[DBPath root]];
        
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle: nil];
        nc = [storyboard instantiateViewControllerWithIdentifier:@"nc"];
        [self.navigationController pushViewController:nc animated:YES];
        if ([self.navigationController isNavigationBarHidden])
            [self.navigationController setNavigationBarHidden:NO animated:YES];
	}
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)linkDB:(UIButton *)sender {
    
    [_linkedAccount unlink];
    [[DBAccountManager sharedManager] linkFromController:self];
    
}
@end
