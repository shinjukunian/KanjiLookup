//
//  KanjiTableViewCell.h
//  ZinniaSample
//
//  Created by Morten Bertz on 3/5/15.
//  Copyright (c) 2015 Morten Bertz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TappableFuriganaLabel.h"

@interface KanjiTableViewCell : UITableViewCell

@property IBOutlet TappableFuriganaLabel *kanjiLabel;
@property IBOutlet TappableFuriganaLabel *readingLabel;
@property IBOutlet UILabel *descriptionLabel;



@end
