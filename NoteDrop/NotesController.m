//
//  NotesController.m
//  NoteDrop
//
//  Created by JRamos on 5/27/13.
//  Copyright (c) 2013 JRamos. All rights reserved.
//

#import "NotesController.h"
#import <dropbox/dropbox.h>

@interface NotesController ()

@property (nonatomic, retain) DBFilesystem *filesystem;
@property (nonatomic, retain) DBPath *root;
@property (nonatomic, retain) NSMutableArray *contents;


@end

@implementation NotesController

- (id)initWithFilesystem:(DBFilesystem *)filesystem root:(DBPath *)root {
	if ((self = [super init])) {
		self.filesystem = filesystem;
        self.root = root;
		self.navigationItem.title = [root isEqual:[DBPath root]] ? @"Dropbox" : [root name];
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //hide back button
    [self.navigationItem setHidesBackButton:YES];
    
    
    //make a keyboard toolbar "input accessory view"
    if(_keyboardToolbar == nil){
        _keyboardToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0, self.view.bounds.size.width, 44)];
        
        UIBarButtonItem *camera = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemCamera target:self action:@selector(resignKeyboard)];
        

        UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(resignKeyboard)];
        
        [_keyboardToolbar setItems:[[NSArray alloc] initWithObjects:camera, space, done, nil] animated:YES];
        
        _textView.inputAccessoryView = _keyboardToolbar;
        
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^() {
		NSArray *immContents = [_filesystem listFolder:_root error:nil];
		NSMutableArray *mContents = [NSMutableArray arrayWithArray:immContents];
		dispatch_async(dispatch_get_main_queue(), ^() {
			self.contents = mContents;
		});
	});
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:.9f
                                             target:self
                                           selector:@selector(reload)
                                           userInfo:nil
                                            repeats:YES];
    
}

-(void)reload
{
    NSLog(@"Size: %d", [self.contents count]);
}

-(void)viewDidAppear:(BOOL)animated
{
    
}

- (void)resignKeyboard
{
    [_textView resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
