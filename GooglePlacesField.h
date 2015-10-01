//
//  GooglePlacesField.h
//
//  Created by Ian Keen on 16/09/2015.
//  Copyright (c) 2015 Mustard Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GooglePlacesField : UITextField
@property (nonatomic, strong) IBInspectable UIFont *boldPredictionFont;
@property (readonly) NSString *selectedPlaceId;
@property (nonatomic, assign) BOOL hidePredictionWhenResigningFirstResponder; //default: NO
@end
