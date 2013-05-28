//
//  ListNotesController.m
//  NoteDrop
//
//  Created by JRamos on 5/28/13.
//  Copyright (c) 2013 JRamos. All rights reserved.
//

#import "ListNotesController.h"
#import "NotesController.h"

@interface ListNotesController ()

@property (nonatomic, retain) DBPath *root;
@property (nonatomic, assign) BOOL loadingFiles;
@property (nonatomic, retain) NSMutableArray *contents;




@end

@implementation ListNotesController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setFileSystem];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
	__weak ListNotesController *weakSelf = self;
	[_filesystem addObserver:self block:^() { [weakSelf reload]; }];
	[_filesystem addObserver:self forPathAndChildren:self.root block:^() { [weakSelf loadFiles]; }];
	[self.navigationController setToolbarHidden:NO];
	[self loadFiles];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	[_filesystem removeObserver:self];
}

- (void) setFileSystem
{
    if(!self.filesystem){
    DBAccount *account = [[DBAccountManager sharedManager] linkedAccount];
    
    //set filesystem
    DBFilesystem *filesystem = [[DBFilesystem alloc] initWithAccount:account];
    
    _filesystem = filesystem;
    _root = [DBPath root];
    }

}

- (void)loadFiles
{
	if (_loadingFiles) return;
	_loadingFiles = YES;
    
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^() {
		NSArray *immContents = [_filesystem listFolder:_root error:nil];
		NSMutableArray *mContents = [NSMutableArray arrayWithArray:immContents];
        NSLog(@"Size: %d" , [mContents count]);
		[mContents sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [[obj2 path] compare:[obj1 path]];
        }];
		dispatch_async(dispatch_get_main_queue(), ^() {
			self.contents = mContents;
			_loadingFiles = NO;
			[self reload];
		});
	});
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.contents count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
    
	DBFileInfo *info = [_contents objectAtIndex:[indexPath row]];
	cell.textLabel.text = [info.path name];
	return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    DBFileInfo *info = [_contents objectAtIndex:[indexPath row]];
    NSLog(@"Info: %@" , info);
    
    DBError *error = [[DBError alloc] init];
    _file = [_filesystem openFile:info.path error:&error];
    _noteName = info.path.name;
    
    [self.navigationController popViewControllerAnimated:YES];

    
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (void)reload
{
    [self.tableView reloadData];
}

- (IBAction)addNote:(UIBarButtonItem *)sender {
    _file = NULL;
    _content = @"";
    _noteName = [self todaysFormattedDate];
    [self.navigationController popViewControllerAnimated:YES];
}

-(NSString*)todaysFormattedDate
{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MM-dd-yyyy-HH:mm:ss"];
    NSString *theDate = [format stringFromDate:[NSDate date]];
    return [NSString stringWithFormat:@"%@.txt", theDate];
}
@end
