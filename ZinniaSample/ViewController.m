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
@property NSArray *detailArray;
@property NSDictionary *kanjiDictionary;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.kanjiDictionary=[self importKanjiDictionary];
    
    
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
    id object=self.detailArray[indexPath.row];
    if (object !=[NSNull null]) {
        NSString *reading=object;
        if (reading.length>0) {
            cell.detailTextLabel.text=reading;
            
        }
    }
    else{
        cell.detailTextLabel.text=@"";
    }
    
    return cell;
}

-(void)canvasDidRecognizeCharacters:(NSArray*)characters withScores:(NSArray*)scores{
    
    self.characterArray=characters;
    NSMutableArray *readings=[NSMutableArray array];
    for (NSString *character in characters) {
        NSString *reading=self.kanjiDictionary[character];
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

@end
