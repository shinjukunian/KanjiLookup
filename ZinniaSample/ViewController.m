//
//  ViewController.m
//  ZinniaSample
//
//  Created by Morten Bertz on 3/3/15.
//  Copyright (c) 2015 Morten Bertz. All rights reserved.
//

#import "ViewController.h"
@import ZinniaCocoaTouch;
@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>

@property NSArray *characterArray;
@property NSArray *scoresArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    cell.textLabel.text=self.characterArray[indexPath.row];
    NSNumber *score=self.scoresArray[indexPath.row];
    cell.detailTextLabel.text=score.stringValue;
    return cell;
}

-(void)canvasDidRecognizeCharacters:(NSArray*)characters withScores:(NSArray*)scores{
    
    self.characterArray=characters;
    self.scoresArray=scores;
    [self.tableView reloadData];
}

-(IBAction)clear:(id)sender{
    [self.canvas clearCanvas];
    self.characterArray=@[];
    [self.tableView reloadData];
}

@end
