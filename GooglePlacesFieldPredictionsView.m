//
//  GooglePlacesFieldPredictionsView.m
//
//  Created by Ian Keen on 16/09/2015.
//  Copyright (c) 2015 Mustard Software. All rights reserved.
//

#import "GooglePlacesFieldPredictionsView.h"
#import <GoogleMaps/GMSAutocompletePrediction.h>

@interface GooglePlacesFieldPredictionsView () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, copy) didSelectPredictionBlock selected;
@property (nonatomic, strong) NSArray *predictions;
@end

static NSString * CellId = @"CellId";

@implementation GooglePlacesFieldPredictionsView
#pragma mark - Lifecycle
-(instancetype)init {
    if (!(self = [super init])) { return nil; }
    [self setup];
    return self;
}
-(void)setup {
    [self registerClass:[UITableViewCell class] forCellReuseIdentifier:CellId];
    self.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.rowHeight = 40;
    self.dataSource = self;
    self.delegate = self;
    self.layer.borderWidth = 1.0;
    self.layer.borderColor = self.separatorColor.CGColor;
    self.layer.cornerRadius = 5.0;
}

#pragma mark - Public
-(void)updateList:(NSArray *)predictions {
    self.predictions = predictions;
    [self reloadData];
}
-(void)predictionSelected:(didSelectPredictionBlock)selected {
    self.selected = selected;
}

#pragma mark - UITableViewDataSource / UITableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (self.predictions.count ?: 0);
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellId forIndexPath:indexPath];
    GMSAutocompletePrediction *prediction = self.predictions[indexPath.row];
    cell.textLabel.attributedText = [self stringForPrediction:prediction];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GMSAutocompletePrediction *prediction = self.predictions[indexPath.row];
    if (self.selected) { self.selected(prediction); }
}

#pragma mark - Helpers
-(NSAttributedString *)stringForPrediction:(GMSAutocompletePrediction *)prediction {
    NSMutableAttributedString *bolded = [prediction.attributedFullText mutableCopy];
    [bolded enumerateAttribute:kGMSAutocompleteMatchAttribute
                       inRange:NSMakeRange(0, bolded.length)
                       options:0
                    usingBlock:^(id value, NSRange range, BOOL *stop) {
                        UIFont *font = ((value == nil) ? self.font : self.boldPredictionFont);
                        [bolded addAttribute:NSFontAttributeName value:font range:range];
                    }];
    
    return bolded;
}
@end
