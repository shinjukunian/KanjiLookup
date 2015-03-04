//
//  WordsTableViewController.m
//  ZinniaSample
//
//  Created by Morten Bertz on 3/4/15.
//  Copyright (c) 2015 Morten Bertz. All rights reserved.
//

#import "WordsTableViewController.h"

@interface WordsTableViewController ()<UISearchControllerDelegate,UISearchResultsUpdating>

@property UISearchController *searchController;
@property NSArray *wordsArray;
@property NSDictionary *dataDictionary;
@property NSArray *dataArray;

@end

@implementation WordsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.searchController=[[UISearchController alloc]initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater=self;
    self.searchController.delegate=self;
    self.searchController.searchBar.frame=CGRectMake(0, 0, CGRectGetWidth(self.tableView.bounds), 44);
    self.searchController.dimsBackgroundDuringPresentation=NO;
    self.tableView.tableHeaderView=self.searchController.searchBar;
    self.tableView.contentOffset=CGPointMake(0, self.searchController.searchBar.frame.size.height);
    
    self.navigationItem.title=self.kanji;
    
    NSMutableArray *wordsMutable=[NSMutableArray array];
    NSMutableDictionary *wordsDict=[NSMutableDictionary dictionary];
    for (NSDictionary *dict in self.words) {
        NSString *word=dict[@"word"];
        NSString *kana=dict[@"wordKana"];
        NSString *translation=dict[@"translation"];
        if (word.length>0) {
            [wordsMutable addObject:word];
            [wordsDict addEntriesFromDictionary:@{word:@{@"translation":translation,@"wordKana":kana}}];
        }
    }
    self.wordsArray=wordsMutable.copy;
    self.dataArray=self.wordsArray;
    self.dataDictionary=wordsDict.copy;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)didPresentSearchController:(UISearchController *)searchController{
    self.dataArray=nil;
    [self.tableView reloadData];
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    NSString *searchString = [self.searchController.searchBar text];

    if (searchString.length>0) {
        NSArray *filteredWords=[self.wordsArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self contains %@",searchString]];
        self.dataArray=filteredWords;
        [self.tableView reloadData];
    }
}

-(void)willDismissSearchController:(UISearchController *)searchController{
    self.dataArray=self.wordsArray;
    [self.tableView reloadData];
}




#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    return self.dataArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"wordCell" forIndexPath:indexPath];
    NSString *word=self.dataArray[indexPath.row];
    NSDictionary *wordDict=self.dataDictionary[word];
    
    NSString *kana=wordDict[@"wordKana"];
    NSString *translation=wordDict[@"translation"];
    NSString *title=[NSString stringWithFormat:@"%@ 【%@】",word,kana];
    cell.textLabel.text=title;
    cell.detailTextLabel.text=translation;
   
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
