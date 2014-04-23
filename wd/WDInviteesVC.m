//
//  WDInviteesVC.m
//  wd
//
//  Created by Joseph Schaffer on 4/23/14.
//  Copyright (c) 2014 Who's Down. All rights reserved.
//

#import "WDInviteesVC.h"

#import "WDEventDataSource.h"
#import "WDEventVC.h"
#import "WDConstants.h"

@interface WDInviteesVC ()
@property (nonatomic, weak) NSObject<WDEventDataSource> *dataSource;
@property (nonatomic, strong) UITableViewController *listVC;
@property (nonatomic, strong) NSMutableArray *attending;
@property (nonatomic, strong) NSMutableArray *pending;
@property (nonatomic, strong) NSMutableArray *rejected;

@property NSArray *sectionNames;
@property NSArray *sectionSets;
@end

@implementation WDInviteesVC

- (id)initWithDataSource:(NSObject<WDEventDataSource> *)dataSource {
  self = [super init];
  if (self) {
    _dataSource = dataSource;
    _listVC = [[UITableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    _attending = [[NSMutableArray alloc] init];
    _pending = [[NSMutableArray alloc] init];
    _rejected = [[NSMutableArray alloc] init];
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.sectionNames = @[@"down", @"yet to decide", @"not down"];
  self.sectionSets  = @[self.attending, self.pending, self.rejected];
  
  [self pushViewController:self.listVC animated:NO];
  self.listVC.tableView.dataSource = self;
  self.listVC.tableView.delegate = self;

  self.listVC.navigationItem.leftBarButtonItem =
      [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                    target:self
                                                    action:@selector(didTapOnCancelButton)];
  
  [self refreshSets];
  
  self.listVC.navigationItem.rightBarButtonItem = self.listVC.editButtonItem;

}

- (void)refreshSets {
  [self.attending removeAllObjects];
  [self.pending removeAllObjects];
  [self.rejected removeAllObjects];
  
  for (NSDictionary *person in [self.dataSource.event objectForKey:WD_modelKey_Event_recips]) {
    NSNumber *status = [person objectForKey:WD_modelKey_Recip_status];
    
    if (status == nil || status == (id)[NSNull null] || [status isEqualToNumber:@0]) {
      [self.pending addObject:person];
    } else if ([status isEqualToNumber:@1]) {
      [self.attending addObject:person];
    } else {
      [self.rejected addObject:person];
    }
  }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didTapOnCancelButton {
  [self.parent dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
  // Return the number of sections.
  return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [[self.sectionSets objectAtIndex:section] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  return [self.sectionNames objectAtIndex:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *Identifier = @"Identifier";
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    
  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                  reuseIdentifier:Identifier];
  }
  
  NSDictionary *person =
    [[self.sectionSets objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];

  if (!person) {
    return cell;
  }
  
  cell.textLabel.text = [person objectForKey:WD_modelKey_Recip_name];
  
  return cell;
}

- (void)tableView:(UITableView *)tableView
    moveRowAtIndexPath:(NSIndexPath *)fromIndexPath
           toIndexPath:(NSIndexPath *)toIndexPath {
  NSDictionary *person =
    [[self.sectionSets objectAtIndex:fromIndexPath.section] objectAtIndex:fromIndexPath.row];
    
  [person setValue:[NSNumber numberWithInt:-1 * (toIndexPath.section - 1)]
            forKey:WD_modelKey_Recip_status];
  
  
  [self.dataSource updateRecipient:person];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
  // Return NO if you do not want the item to be re-orderable.
  return YES;
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
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
