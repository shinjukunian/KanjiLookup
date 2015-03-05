//
//  ViewController.m
//  ZinniaSample
//
//  Created by Morten Bertz on 3/3/15.
//  Copyright (c) 2015 Morten Bertz. All rights reserved.
//

#import "ViewController.h"
#import "WordsTableViewController.h"
#import "AppDelegate.h"

#import "KanjiTableViewCell.h"

@import ZinniaCocoaTouch;
@interface ViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchControllerDelegate,UISearchResultsUpdating,UISearchBarDelegate>

@property NSArray *characterArray;
@property NSArray *detailArray;
@property NSDictionary *kanjiDictionary;
@property NSDictionary *wordsDictionary;

@property UISearchController *searchController;
@property NSString *savedSearchString;



@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.searchController=[[UISearchController alloc]initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater=self;
    self.searchController.delegate=self;
    self.searchController.searchBar.delegate=self;
    self.searchController.searchBar.frame=CGRectMake(0, 0, CGRectGetWidth(self.tableView.bounds), 44);
    self.searchController.dimsBackgroundDuringPresentation=NO;
    self.searchController.searchBar.showsCancelButton=NO;
    self.tableView.tableHeaderView=self.searchController.searchBar;
    
   // self.tableView.contentOffset=CGPointMake(0, self.tableView.tableHeaderView.bounds.size.height);
    self.tableView.rowHeight=UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight=50;
    
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
    
    __weak ViewController *weakSelf=self;
    [[NSNotificationCenter defaultCenter]addObserverForName:pasteboardContainsTextNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note){
        BOOL autoLookup=[[NSUserDefaults standardUserDefaults]boolForKey:@"autoLookup"];
        if (autoLookup) {
            NSString *string=note.userInfo[@"text"];
            if (string.length>0) {
                NSOrderedSet *kanji=[weakSelf kanjiCharactersInString:string];
                if (kanji.count>0) {
                    [weakSelf clear:nil];
                    weakSelf.characterArray=kanji.array;
                    [weakSelf.tableView reloadData];
                    weakSelf.searchController.searchBar.text=[kanji.array componentsJoinedByString:@""];
                }
            }
        }
    
    }];
}


-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:YES];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
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
            NSArray *wordComponents=[wordString componentsSeparatedByString:@";"];
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
    KanjiTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"characterCell" forIndexPath:indexPath];
    NSString *character=self.characterArray[indexPath.row];
    cell.kanjiLabel.text=character;
    
    NSString *reading=self.kanjiDictionary[character];
    if (reading.length>0) {
        cell.descriptionLabel.text=reading;
        [cell.kanjiLabel setUtterancesFromDescription:reading];
    }
    else{
        cell.descriptionLabel.text=@" ";
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
    
    NSArray *displayCharacters=[characters filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSString *character, NSDictionary *bindings){
        
        NSString *reading=self.kanjiDictionary[character];
        if (reading.length>0) {
            return YES;
        }
        else{
            return NO;
        }
    
    }]];
    
    self.characterArray=displayCharacters;
    [self.tableView reloadData];
}

-(IBAction)clear:(id)sender{
    [self.canvas clearCanvas];
    self.characterArray=@[];
    [self.tableView reloadData];
    if (self.searchController.searchBar.text.length>0) {
        self.searchController.searchBar.text=@"";
    }
}



-(IBAction)kanjiTapped:(UITapGestureRecognizer*)sender{
    CGPoint touchPoint=[sender locationInView:self.tableView];
    NSIndexPath *path=[self.tableView indexPathForRowAtPoint:touchPoint];
    if (path) {
        KanjiTableViewCell *cell=(KanjiTableViewCell*)[self.tableView cellForRowAtIndexPath:path];
        if (cell) {
            TappableFuriganaLabel *label=cell.kanjiLabel;
            [label becomeFirstResponder];
            CGRect rect=label.frame;
            UIMenuItem *speakItem=[[UIMenuItem alloc]initWithTitle:NSLocalizedString(@"Speak", nil) action:@selector(speak:)];
            
            UIMenuController *menu=[UIMenuController sharedMenuController];
            menu.menuItems=@[speakItem];
            [menu setTargetRect:rect inView:cell];
            [menu setMenuVisible:YES animated:YES];
        }
    }
    
}



-(void)didPresentSearchController:(UISearchController *)searchController{
    if (searchController.searchBar.text.length==0) {
        [self.canvas clearCanvas];
        self.characterArray=@[];
        [self.tableView reloadData];
    }
    else{
         [self.canvas clearCanvas];
    }
    
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    NSString *searchString = [self.searchController.searchBar text];

    if (searchString.length>0) {
        NSOrderedSet *kanjiCharacters=[self kanjiCharactersInString:searchString];
        NSArray *filteredKanji=[self.kanjiDictionary.allKeys filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self in %@",kanjiCharacters]];
        self.characterArray=filteredKanji.copy;
        [self.tableView reloadData];
    }
    else{
        [self.canvas clearCanvas];
//        self.characterArray=@[];
//        [self.tableView reloadData];
    }

}

-(void)willDismissSearchController:(UISearchController *)searchController{
    if (searchController.searchBar.text.length==0) {
        [self.canvas clearCanvas];
        self.characterArray=@[];
        [self.tableView reloadData];
        
    }
    else{
        [self.canvas clearCanvas];
    }
 
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    self.savedSearchString=searchBar.text;
}




-(NSOrderedSet*)kanjiCharactersInString:(NSString*)string{
    NSCharacterSet *kanjiCharacterset=[NSCharacterSet characterSetWithRange:NSMakeRange(0x4e00, 0x9fbf-0x4e00)];
    NSMutableOrderedSet *kanji=[[NSMutableOrderedSet alloc]init];
    for (NSUInteger i=0; i<string.length; i++) {
        unichar uni=[string characterAtIndex:i];
        if ([kanjiCharacterset characterIsMember:uni]) {
            NSString *str = [NSString stringWithFormat: @"%C", uni];
            [kanji addObject:str];
        }
    }
    return kanji.copy;
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
        cell.selected=NO;
        return NO;
    }
    return YES;
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:@"toWords"]) {
        UINavigationController *nav=segue.destinationViewController;
        WordsTableViewController *controller=(WordsTableViewController*)nav.visibleViewController;
        UITableViewCell *cell=sender;
        cell.selected=NO;
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
