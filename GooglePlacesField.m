//
//  GooglePlacesField.m
//
//  Created by Ian Keen on 16/09/2015.
//  Copyright (c) 2015 Mustard Software. All rights reserved.
//

#import "GooglePlacesField.h"
#import <GoogleMaps/GMSPlacesClient.h>
#import <GoogleMaps/GMSAutocompletePrediction.h>
#import "GooglePlacesFieldPredictionsView.h"

@interface GooglePlacesField ()
@property (nonatomic, strong) GMSPlacesClient *placeClient;
@property (nonatomic, strong) GooglePlacesFieldPredictionsView *predictionTable;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@end

static CGFloat PredictionTableAnimationLength = 0.35;

@implementation GooglePlacesField
#pragma mark - Lifecycle
-(void)awakeFromNib {
    [super awakeFromNib];
    [self setup];
}
-(void)dealloc {
    [self detachFromNotifications];
}
-(void)layoutSubviews {
    [super layoutSubviews];
    self.predictionTable.frame = [self predictionTableFrame];
    self.spinner.frame = [self spinnerFrame];
}
-(void)drawTextInRect:(CGRect)rect {
    [super drawTextInRect:rect];
    if ([self emptyString:self.text]) {
        [self selectedPrediction:nil];
    }
}

#pragma mark - Properties
-(void)setFont:(UIFont *)font {
    [super setFont:font];
    self.predictionTable.font = font;
}
-(void)setBoldPredictionFont:(UIFont *)boldPredictionFont {
    _boldPredictionFont = boldPredictionFont;
    self.predictionTable.boldPredictionFont = boldPredictionFont;
}

#pragma mark - Setup
-(void)setup {
    self.rightViewMode = UITextFieldViewModeAlways;
    self.autocorrectionType = UITextAutocorrectionTypeNo;
    
    [self setupSpinner];
    [self hideSpinner];
    
    self.placeClient = [GMSPlacesClient sharedClient];
    self.boldPredictionFont = [UIFont boldSystemFontOfSize:self.font.pointSize];
    [self attachToNotifications];
    [self setupPredictionsTable];
}
-(void)setupPredictionsTable {
    self.predictionTable = [GooglePlacesFieldPredictionsView new];
    self.predictionTable.font = self.font;
    self.predictionTable.boldPredictionFont = self.boldPredictionFont;
    self.predictionTable.frame = [self predictionTableFrame];
    [self.predictionTable predictionSelected:^(GMSAutocompletePrediction *prediction) {
        [self selectedPrediction:prediction];
    }];
}

#pragma mark - Interaction
-(void)searchForPlacesNamed:(NSString *)placeName {
    if ([self emptyString:placeName]) {
        [self selectedPrediction:nil];
        return;
    }
    
    [self showSpinner];
    
    [self.placeClient
     autocompleteQuery:placeName bounds:nil filter:nil
     callback:^(NSArray *results, NSError *error) {
         [self hideSpinner];
         
         if (error) {
             NSLog(@"Google Places Error: %@", error);
             return;
         }
         [self showPredictions:results];
     }];
}
-(void)selectedPrediction:(GMSAutocompletePrediction *)prediction {
    _selectedPlaceId = prediction.placeID;
    self.attributedText = prediction.attributedFullText;
    [self hidePredictions];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

#pragma mark - Spinner
-(void)setupSpinner {
    self.spinner = [UIActivityIndicatorView new];
    self.spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    self.spinner.hidesWhenStopped = YES;
}
-(CGRect)spinnerFrame {
    return CGRectMake(CGRectGetWidth(self.bounds) - CGRectGetHeight(self.bounds),
                      0,
                      CGRectGetHeight(self.bounds),
                      CGRectGetHeight(self.bounds));
}
-(void)showSpinner {
    self.rightView = self.spinner;
    [self.spinner startAnimating];
}
-(void)hideSpinner {
    [self.spinner stopAnimating];
    self.rightView = nil;
}

#pragma mark - Prediction Table
-(CGRect)predictionTableFrame {
    CGRect frame = self.frame;
    frame.origin.y = CGRectGetMaxY(frame);
    frame.size.height = (self.predictionTable.rowHeight * 4.0);
    return frame;
}
-(void)showPredictions:(NSArray *)predictions {
    [self.predictionTable updateList:predictions];
    if (self.predictionTable.superview != nil) { return; }
    
    self.predictionTable.alpha = 0.0;
    [self.superview addSubview:self.predictionTable];
    [UIView animateWithDuration:PredictionTableAnimationLength animations:^{
        self.predictionTable.alpha = 1.0;
    }];
}
-(void)hidePredictions {
    if (self.predictionTable.superview == nil) { return; }
    
    [UIView animateWithDuration:PredictionTableAnimationLength animations:^{
        self.predictionTable.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self.predictionTable removeFromSuperview];
    }];
}

#pragma mark - Notifications
-(void)attachToNotifications {
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(searchTermUpdated:)
     name:UITextFieldTextDidChangeNotification
     object:self];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(searchFieldLostFocus:)
     name:UITextFieldTextDidEndEditingNotification
     object:self];
}
-(void)detachFromNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)searchTermUpdated:(NSNotification *)notification {
    [self searchForPlacesNamed:self.text];
}
-(void)searchFieldLostFocus:(NSNotification *)notification {
    if (self.hidePredictionWhenResigningFirstResponder) {
        [self hidePredictions];
    }
}

#pragma mark - Misc
-(BOOL)emptyString:(NSString *)string {
    return ((string ?: @"").length == 0);
}
@end
