//
//  LocalFileViewController.m
//  Connectivity
//
//  Created by siping ruan on 17/1/16.
//  Copyright © 2017年 Rasping. All rights reserved.
//

#import "LocalFileViewController.h"

NSString *const kLocalFileNameKey = @"fileName";
NSString *const kLocalFileSizeKey = @"fileSize";

@interface LocalFileViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)cancelBtnClicked:(UIBarButtonItem *)btn;

@end

@implementation LocalFileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
}

#pragma mark - Action

- (IBAction)cancelBtnClicked:(UIBarButtonItem *)btn
{
    if ([self.delegate respondsToSelector:@selector(localFileVCDidCancel:)]) {
        [self.delegate localFileVCDidCancel:self];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseIdentifier = @"fileCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
        
        //separator
        UIView *view = [[UIView alloc] init];
        view.frame = CGRectMake(5, cell.contentView.frame.size.height - 1, self.view.frame.size.width - 10, 1);
        view.alpha = 0.8;
        view.backgroundColor = [UIColor grayColor];
        [cell.contentView addSubview:view];
    }
    NSDictionary *dict = self.dataArray[indexPath.row];
    cell.textLabel.text = dict[kLocalFileNameKey];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"大小：%@B", dict[kLocalFileSizeKey]];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(didSelectFilePath:)]) {
        NSDictionary *dict = self.dataArray[indexPath.row];
        [self.delegate didSelectFilePath:dict[kLocalFileNameKey]];
    }
}
@end
