//
//  ViewController.m
//  Refresh
//
//  Created by apple on 2017/12/5.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "ViewController.h"
#import "GifHeaderRefresh.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 布局视图
    [self LayoutView];
    // 网络请求
    [self RequestData];
}

#pragma mark - 网络请求
- (void)RequestData {
    self.tableView.mj_header = [GifHeaderRefresh headerWithRefreshingBlock:^{
        
        [self.tableView.mj_header endRefreshing];
    }];
    // 马上进入刷新状态
    [self.tableView.mj_header beginRefreshing];
}

#pragma mark - 布局视图
- (void)LayoutView {
    /** table */
    self.tableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    // tableview高度随数据高度变化而变化
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
}


#pragma mark - tableviewDegate、DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"DangerRecordCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"加载数据---%ld", indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



@end
