//
//  KeyboardViewController.m
//  HandwritingKeyboard
//
//  Created by Morten Bertz on 3/3/15.
//  Copyright (c) 2015 Morten Bertz. All rights reserved.
//

#import "KeyboardViewController.h"
#import "CharacterCollectionViewCell.h"

@interface KeyboardViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>

@property NSArray *characters;
@property NSArray *frequentWords;
@property NSArray *autoCompleteSuggestions;
@property NSString *selectedCharacter;
@end

@implementation KeyboardViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    UINib *nib=[UINib nibWithNibName:@"KeyboardView" bundle:nil];
    NSArray *objects=[nib instantiateWithOwner:self options:nil];
    UIView *keyboardView=[objects firstObject];
    self.view=keyboardView;
    self.selectedCharacter=@"";
    UINib *cellNib = [UINib nibWithNibName:@"CharacterCell" bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:@"characterCell"];
    [self.wordSuggestionsCollectionView registerNib:cellNib forCellWithReuseIdentifier:@"characterCell"];
//    [self requestSupplementaryLexiconWithCompletion:^(UILexicon *lexicon){
//        for (UILexiconEntry *entry in lexicon.entries) {
//            NSLog(@"input:%@ entry:%@",entry.userInput,entry.documentText);
//        }
//    
//    }];
    NSString *path=[[NSBundle mainBundle]pathForResource:@"top1000Words" ofType:@"txt"];
    NSError *error;
    NSString *words=[NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    if (words.length>0) {
        self.frequentWords=[words componentsSeparatedByString:@","];
    }
    UICollectionViewFlowLayout *layout=(UICollectionViewFlowLayout*)self.wordSuggestionsCollectionView.collectionViewLayout;
    layout.estimatedItemSize=CGSizeMake(50, 25);
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated
}

- (void)textWillChange:(id<UITextInput>)textInput {
    // The app is about to change the document's contents. Perform any preparation here.
}

- (void)textDidChange:(id<UITextInput>)textInput {
    // The app has just changed the document's contents, the document context has been updated.
    
    UIColor *textColor = nil;
    if (self.textDocumentProxy.keyboardAppearance == UIKeyboardAppearanceDark) {
        textColor = [UIColor whiteColor];
    } else {
        textColor = [UIColor blackColor];
    }
    
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([collectionView.restorationIdentifier isEqualToString:@"wordSuggestionsCollectionView"]) {
        NSString *character=self.autoCompleteSuggestions[indexPath.row];
        [self.textDocumentProxy insertText:character];
        [self clear:nil];

    }
    else if ([collectionView.restorationIdentifier isEqualToString:@"characterCollectionView"]){
         NSString *character=self.characters[indexPath.row];
        if (![self.selectedCharacter isEqualToString:character]) {
            NSArray *suggestions=[self autocompleteSuggestionsForCharacter:self.characters[indexPath.row]];
            if (suggestions.count>0) {
                self.autoCompleteSuggestions=suggestions;
                [self.wordSuggestionsCollectionView reloadData];
                self.selectedCharacter=character;
            }
            else{
                NSString *character=self.characters[indexPath.row];
                [self.textDocumentProxy insertText:character];
                [self clear:nil];
                self.selectedCharacter=@"";
            }
            
        }
        else{
            NSString *character=self.characters[indexPath.row];
            [self.textDocumentProxy insertText:character];
            [self clear:nil];
            self.selectedCharacter=@"";
        }
        

        
        
    }
    
    
}

-(void)canvasDidRecognizeCharacters:(NSArray *)characters withScores:(NSArray *)scores{
    self.characters=characters;
    self.autoCompleteSuggestions=[self autocompleteSuggestionsForCharacter:characters.firstObject];
    self.selectedCharacter=@"";
    
    [self.collectionView reloadData];
    [self.wordSuggestionsCollectionView reloadData];
}


-(NSArray*)autocompleteSuggestionsForCharacter:(NSString*)character{
    
    NSArray *suggestions=[self.frequentWords filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF beginswith %@",character]];
    if (suggestions.count>0) {
        return suggestions;
    }
    return nil;
    
}


-(IBAction)nextKeyboard:(id)sender{
    [self advanceToNextInputMode];
}

-(IBAction)clear:(id)sender{
    self.selectedCharacter=@"";
    [self.canvas clearCanvas];
    self.characters=@[];
    self.autoCompleteSuggestions=@[];
    [self.collectionView reloadData];
    [self.wordSuggestionsCollectionView reloadData];
}


-(IBAction)delete:(id)sender{
    [self.textDocumentProxy deleteBackward];
    [self clear:nil];

}

-(IBAction)enter:(id)sender{
    [self.textDocumentProxy insertText:@"\n"];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if ([collectionView.restorationIdentifier isEqualToString:@"wordSuggestionsCollectionView"]) {
        return self.autoCompleteSuggestions.count;
    }
    else if ([collectionView.restorationIdentifier isEqualToString:@"characterCollectionView"]){
        return self.characters.count;

    }
    else{
        return 0;
    }
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([collectionView.restorationIdentifier isEqualToString:@"wordSuggestionsCollectionView"]) {
        CharacterCollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"characterCell" forIndexPath:indexPath];
        cell.characterLabel.text=self.autoCompleteSuggestions[indexPath.row];
        return cell;
        
    }
    else if ([collectionView.restorationIdentifier isEqualToString:@"characterCollectionView"]){
        CharacterCollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"characterCell" forIndexPath:indexPath];
        cell.characterLabel.text=self.characters[indexPath.row];
        return cell;
        
    }

    return nil;

}

@end
