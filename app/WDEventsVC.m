//
//  WDEventsVC.m
//  wd
//
//  Created by Joseph Schaffer on 3/6/14.
//  Copyright (c) 2014 Who's Down. All rights reserved.
//

#import "WDEventsVC.h"
#import "WDEventsDelegate.h"
#import "WDEventsDataSource.h"

#import "WDConstants.h"

@interface WDEventsVC ()
@property (nonatomic, weak) NSObject<WDEventsDelegate> *delegate;
@property (nonatomic, weak) NSObject<WDEventsDataSource> *dataSource;
@end

@implementation WDEventsVC

- (id)initWithDelegate:(NSObject<WDEventsDelegate> *)delegate
        withDataSource:(NSObject<WDEventsDataSource> *)dataSource
             viewInset:(UIEdgeInsets)inset {
  self = [super initWithStyle:UITableViewStylePlain];
  if (self) {
    _delegate = delegate;
    _dataSource = dataSource;
    self.tableView.contentInset = inset;
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [self.refreshControl beginRefreshing];
  
  [self.dataSource refreshEventsOnSuccess:^{
                                  [self.tableView reloadData];
                                  [self.refreshControl endRefreshing];
                                }
                                onFailure:^{
                                  [self.refreshControl endRefreshing];
                                }];
  
  // Refresh control
  self.refreshControl = [[UIRefreshControl alloc] init];
  [self.refreshControl addTarget:self
                          action:@selector(refresh)
                forControlEvents:UIControlEventValueChanged];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refresh {
  [self.refreshControl beginRefreshing];
  [self.dataSource refreshEventsOnSuccess:^{
                                  [self.tableView reloadData];
                                  [self.refreshControl endRefreshing];
                                }
                                onFailure:^{
                                  NSLog(@"Refresh Failed");
                                  [self.refreshControl endRefreshing];
                                }];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  NSDictionary *event = [self.dataSource.events objectAtIndex:[indexPath row]];
  
  [self.delegate didTapOnEvent:event];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  
  return [self.dataSource.events count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *CellIdentifier = @"Cell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
  }
  
  if (self.refreshControl.isRefreshing) {
    return cell;
  }
  
  NSDictionary *event = [self.dataSource.events objectAtIndex:[indexPath row]];

  if (!event) {
    return cell;
  }

  NSString *title    = [event objectForKey:WD_modelKey_Event_title];;
  NSString *subtitle = [event objectForKey:WD_modelKey_Event_message];

  cell.textLabel.text       = title    ? title    : @"Event";
  cell.detailTextLabel.text = subtitle ? subtitle : @"Event event event";
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

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
