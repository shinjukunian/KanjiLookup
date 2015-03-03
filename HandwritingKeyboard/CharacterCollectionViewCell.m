//
//  CharacterCollectionViewCell.m
//  ZinniaSample
//
//  Created by Morten Bertz on 3/3/15.
//  Copyright (c) 2015 Morten Bertz. All rights reserved.
//

#import "CharacterCollectionViewCell.h"

@implementation CharacterCollectionViewCell

-(void)layoutSubviews{
    [super layoutSubviews];
    self.layer.borderColor=[[UIColor lightGrayColor]CGColor];
    self.layer.borderWidth=0.5;
}



-(UICollectionViewLayoutAttributes*)preferredLayoutAttributesFittingAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes{
    return [super preferredLayoutAttributesFittingAttributes:layoutAttributes];
}

@end
