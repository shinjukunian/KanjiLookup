//
//  ViewController.h
//  ZinniaSample
//
//  Created by Morten Bertz on 3/3/15.
//  Copyright (c) 2015 Morten Bertz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CanvasView.h"

@interface ViewController : UIViewController<CanvasViewDelegate>

@property IBOutlet UITableView *tableView;
@property IBOutlet CanvasView *canvas;

@end

