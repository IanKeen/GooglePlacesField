//
//  GooglePlacesFieldPredictionsView.h
//
//  Created by Ian Keen on 16/09/2015.
//  Copyright (c) 2015 Mustard Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GMSAutocompletePrediction;

typedef void(^didSelectPredictionBlock)(GMSAutocompletePrediction *prediction);

@interface GooglePlacesFieldPredictionsView : UITableView
-(void)updateList:(NSArray *)predictions;
-(void)predictionSelected:(didSelectPredictionBlock)selected;

@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIFont *boldPredictionFont;
@end
