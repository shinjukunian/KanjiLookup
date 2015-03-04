//
//  ViewController.m
//  ZinniaSample
//
//  Created by Morten Bertz on 3/3/15.
//  Copyright (c) 2015 Morten Bertz. All rights reserved.
//

#import "ViewController.h"
#import "WordsTableViewController.h"

@import ZinniaCocoaTouch;
@interface ViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchControllerDelegate,UISearchResultsUpdating>

@property NSArray *characterArray;
@property NSArray *detailArray;
@property NSDictionary *kanjiDictionary;
@property NSDictionary *wordsDictionary;

@property UISearchController *searchController;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.searchController=[[UISearchController alloc]initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater=self;
    self.searchController.delegate=self;
    self.searchController.searchBar.frame=CGRectMake(0, 0, CGRectGetWidth(self.tableView.bounds), 44);
    self.searchController.dimsBackgroundDuringPresentation=NO;
    self.tableView.tableHeaderView=self.searchController.searchBar;
    self.tableView.contentOffset=CGPointMake(0, self.searchController.searchBar.frame.size.height);

    
    
    self.kanjiDictionary=[self importKanjiDictionary];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDate *now=[NSDate date];
        NSDictionary *dict=[self importWordsDictionary];
        if (dict) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"imported for %f seconds",[[NSDate date]timeIntervalSinceDate:now]);
                self.wordsDictionary=dict;
            });
        }
    });
    
}


-(NSDictionary*)importKanjiDictionary{
    NSString *path=[[NSBundle mainBundle]pathForResource:@"kanjiDict" ofType:@"txt"];
    NSError *error;
    NSString *dictString=[NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    NSMutableDictionary *kanjiDict=[NSMutableDictionary dictionary];
    if (dictString.length>0) {
        NSArray *lines=[dictString componentsSeparatedByString:@"\n"];
        for (NSString *line in lines) {
            NSArray *components=[line componentsSeparatedByString:@","];
            if (components.count>1) {
                NSString *literal=components.firstObject;
                NSString *reading=components.lastObject;
                [kanjiDict addEntriesFromDictionary:@{literal:reading}];
            }
        }
    }
    return kanjiDict.copy;
}


-(NSDictionary*)importWordsDictionary{
    NSString *path=[[NSBundle mainBundle]pathForResource:@"wordsDict" ofType:@"txt"];
    NSError *error;
    NSString *dictString=[NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    NSMutableDictionary *wordsDict=[NSMutableDictionary dictionary];
    if (dictString.length>0) {
        NSArray *lines=[dictString componentsSeparatedByString:@"\n"];
        for (NSString *line in lines) {
            NSArray *components=[line componentsSeparatedByString:@":"];
            NSString *kanji=components.firstObject;
            NSString *wordString=components.lastObject;
            NSArray *wordComponents=[wordString componentsSeparatedByString:@","];
            if (wordComponents.count>2) {
                NSString *word=wordComponents.firstObject;
                NSString *wordKana=wordComponents[1];
                NSString *translation=[[wordComponents subarrayWithRange:NSMakeRange(2, wordComponents.count-2)]componentsJoinedByString:@", "];
                NSMutableArray *wordsArray=[NSMutableArray arrayWithArray:wordsDict[kanji]];
                [wordsArray addObject:@{@"word":word,@"wordKana":wordKana,@"translation":translation}];
                [wordsDict addEntriesFromDictionary:@{kanji:wordsArray.copy}];

            }
        }
    }
    
    return wordsDict.copy;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.characterArray.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"characterCell" forIndexPath:indexPath];
    NSString *character=self.characterArray[indexPath.row];
    cell.textLabel.text=character;
    id object=self.detailArray[indexPath.row];
    if (object !=[NSNull null]) {
        NSString *reading=object;
        if (reading.length>0) {
            cell.detailTextLabel.text=reading;
        }
    }
    else{
        cell.detailTextLabel.text=@" "; //strange hack, if string is empty labels disappear, must be some problem with dequeuing
       
    }
    NSArray *words=self.wordsDictionary[character];
    if (words.count>0) {
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    }
    else{
        cell.accessoryType=UITableViewCellAccessoryNone;
    }
    
    return cell;
}

-(void)canvasDidRecognizeCharacters:(NSArray*)characters withScores:(NSArray*)scores{
    
    self.characterArray=characters;
    NSMutableArray *readings=[NSMutableArray array];
    for (NSString *character in characters) {
        NSString *reading=self.kanjiDictionary[character];
      //  NSLog(@"index %lu character:%@ reading:%@",[characters indexOfObject:character], character,reading);
        if (reading.length>0) {
            [readings addObject:reading];
        }
        else{
            [readings addObject:[NSNull null]];
        }
    }
    self.detailArray=readings.copy;
    
    [self.tableView reloadData];
}

-(IBAction)clear:(id)sender{
    [self.canvas clearCanvas];
    self.characterArray=@[];
    [self.tableView reloadData];
}




-(void)didPresentSearchController:(UISearchController *)searchController{
    [self clear:nil];
    
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    NSString *searchString = [self.searchController.searchBar text];
    
    if (searchString.length>0) {
        NSArray *filteredKanji=[self.kanjiDictionary.allKeys filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self contains %@",searchString]];
        self.characterArray=filteredKanji;
        [self.tableView reloadData];
    }
}

-(void)willDismissSearchController:(UISearchController *)searchController{
    [self clear:nil];
}





- (IBAction)unwindToStartScreen:(UIStoryboardSegue *)unwindSegue
{
}


-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    if ([identifier isEqualToString:@"toWords"]) {
        UITableViewCell *cell=sender;
        NSIndexPath *path=[self.tableView indexPathForCell:cell];
        NSString *character=self.characterArray[path.row];
        NSArray *array=self.wordsDictionary[character];
        if (array.count>0) {
            return YES;
        }
        
    }
    return NO;
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:@"toWords"]) {
        UINavigationController *nav=segue.destinationViewController;
        WordsTableViewController *controller=(WordsTableViewController*)nav.visibleViewController;
        UITableViewCell *cell=sender;
        NSIndexPath *path=[self.tableView indexPathForCell:cell];
        NSString *character=self.characterArray[path.row];
        NSArray *array=self.wordsDictionary[character];
        if (array.count>0) {
            controller.words=array;
            controller.kanji=character;
        }

    }
    
}

@end
