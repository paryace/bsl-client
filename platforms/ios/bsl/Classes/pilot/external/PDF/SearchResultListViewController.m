//
//  SearchResultListViewController.m
//  pilot
//
//  Created by Sencho Kong on 12-9-26.
//  Copyright (c) 2012年 chen shaomou. All rights reserved.
//

#import "SearchResultListViewController.h"
#import "PDFDocumentsViewController.h"
#import "UIXToolbarView.h"
#import "Selection.h"
#import "Chapter.h"



@interface SearchResultListViewController (){
    
    UISearchBar* searchBar;
    int currentSearchPage;
    UIView*  refreshFooterView;
    UIActivityIndicatorView* spinner;
}

@property(retain,nonatomic)NSMutableArray* resultData;
@property(retain,nonatomic)UITableView* tableView;
@property(retain,nonatomic)Scanner* scanner;
- (void)insertDatas:(NSArray *)datas;

@end

@implementation SearchResultListViewController

static const  NSUInteger kMaximumResultNumber = 30;  //搜索结果最大数量



@synthesize keyWord=_keyWord;
@synthesize resultData;
@synthesize delegate;
@synthesize tableView;
@synthesize searchBar;
@synthesize currentPage;
@synthesize eBook;
@synthesize scanner;

-(void)dealloc{
    
    [tableView release];
    [_keyWord release];
    [resultData release];
    [eBook release];
    [searchBar release];
    searchBar=nil;
    
    if (scanner) {
        scanner.delegate=nil;
        [scanner stopScan];
        
        [scanner release];
    }
    scanner=nil;
    
    if (spinner) {
        [spinner stopAnimating];
        [spinner release];
    }
    spinner=nil;
    [self removeObserver:self forKeyPath:@"resultData"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AddDataNotif" object:nil];
        [super dealloc];
}

-(void)setKeyWord:(NSString *)keyWord{
    if (_keyWord) {
        [_keyWord release];
    }
    _keyWord=[keyWord retain];
}




- (id)init
{
    self = [super init];
    if (self) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(addDatas:)
                                                     name:@"AddDataNotif"
                                                   object:nil];
        
        [self addObserver:self forKeyPath:@"resultData" options:0 context:NULL];


        Scanner* aScanner=[[Scanner alloc]init];
        self.scanner=aScanner;
        [aScanner release];
        self.scanner.delegate=self;
        self.scanner.ebook=self.eBook;
        
            

               
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    UIImage *buttonForBackImage = [UIImage imageNamed: @"BackButtonItem"];
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0,50, 30) ];
    [backButton setBackgroundImage:buttonForBackImage forState:UIControlStateNormal];
    [backButton setTitle:@" 返回" forState:UIControlStateNormal];
    [backButton.titleLabel setFont:[UIFont boldSystemFontOfSize:12.0]];
    [backButton.titleLabel setShadowColor:[UIColor grayColor]];
    [backButton.titleLabel setShadowOffset:CGSizeMake(1.0, 1.0)];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *buttonForBack = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [backButton release];
    self.navigationItem.leftBarButtonItem = buttonForBack;
    [buttonForBack release];

    
    
    UISearchBar* aSearchBar=[[UISearchBar alloc]initWithFrame:CGRectMake(0, 0,self.view.bounds.size.width , 44)];
    aSearchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    aSearchBar.tintColor = [UIColor lightGrayColor];
    aSearchBar.delegate=self;
    self.searchBar=aSearchBar;
    [aSearchBar release];
    
    CGRect shadowRect = searchBar.bounds;
    shadowRect.origin.y += 44;//shadowRect.size.height;
    shadowRect.size.height = 4.0f;
    UIXToolbarShadow *shadowView = [[UIXToolbarShadow alloc] initWithFrame:shadowRect];
    [searchBar addSubview:shadowView];
    [shadowView release];
    [self.view addSubview:self.searchBar];

    
    
    
    
    self.resultData=[NSMutableArray array];
    
    self.title=self.eBook.bookName;
    
    self.tableView=[[[UITableView alloc]initWithFrame:CGRectMake(0, 44, self.view.bounds.size.width, self.view.bounds.size.height-44) style:UITableViewStylePlain]autorelease];
    tableView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    tableView.delegate=self;
    tableView.dataSource=self;
    [self.view addSubview: tableView];
   
    
    
  
    
}

-(void)back:(id)sender{
    [self stopScan];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
   
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
   
}

- (void) createTableFooter
{
    if(refreshFooterView ==nil){
        refreshFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.bounds.size.width, 40.0f)];
        
        UIActivityIndicatorView *tableFooterActivityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width/2, 10.0f, 20.0f, 20.0f)];
        [tableFooterActivityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        [tableFooterActivityIndicator startAnimating];
        [refreshFooterView addSubview:tableFooterActivityIndicator];
        [tableFooterActivityIndicator release];
        
        
    }
    self.tableView.tableFooterView = refreshFooterView;
}


- (void)addDatas:(NSNotification *)notif {
    
    assert([NSThread isMainThread]);
    [self insertDatas:[[notif userInfo] valueForKey:@"AddDataNotif"]];
  
}


-(void)showSpin{
    
    if (!spinner) {
        spinner=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [spinner startAnimating];
        
    }
    
    self.navigationItem.rightBarButtonItem= [[[UIBarButtonItem alloc]initWithCustomView:spinner]autorelease];
    
    if (self.navigationItem.rightBarButtonItem==nil) {
        self.searchBar.showsCancelButton=YES;
        
//        UIButton* cancelButton;
        
        for(id view in [self.searchBar subviews])
        {
            if([view isKindOfClass:[UIButton class]])
            {
//                cancelButton=view;
                spinner.frame=[(UIButton*)view bounds];
                [view addSubview:spinner];
                [view setTitle:@"" forState:UIControlStateNormal ];
                
            }
        }

    }
       
    
}

-(void)startScanFromPage:(NSInteger)page WithKeyWord:(NSString*)keyWord{
 
    [self showSpin];
    
    [self.resultData removeAllObjects];
    [self.tableView reloadData];
    
    self.keyWord=keyWord;
    
    self.searchBar.text=keyWord;
    
    __block Scanner* blockscanner =self.scanner;
       
    dispatch_queue_t searchQueue= dispatch_queue_create("search queue", NULL);
    
    dispatch_async(searchQueue, ^{
        
      
        blockscanner.keyword=keyWord;
        [blockscanner scanEbook:self.eBook];
    });
    
    dispatch_release(searchQueue);
    /*
    //如果是在内文搜索就搜全文包括章节
    if (delegate && [delegate isKindOfClass:[ReaderViewController class]]) {
        
        if ([delegate respondsToSelector:@selector(willBeginScanEbook:Page:Keyword:)]) {
            [delegate  willBeginScanEbook:self.eBook Page:1 Keyword:_keyWord];
        }
        
        //[scanner scanFromPageNumber:1];
        
        
    }else{
        //全文搜索从第一页开始
        if (page<1)page=1;
        //[scanner scanFromPageNumber:page];
        [scanner scanEbook:self.eBook];
    }
     */
}

-(void)stopScan{
    
    [self.scanner stopScan];
    self.navigationItem.rightBarButtonItem=nil;
    
}

#pragma mark -
#pragma mark Scanner elegate

-(void)Scanner:(Scanner *)scanner DidScanFinishEbook:(Ebook *)ebook{
    
    if (self.navigationController) {
        
        self.navigationItem.rightBarButtonItem=nil;
    }
    
    self.tableView.tableFooterView=nil;
    self.searchBar.showsCancelButton=NO;
    
    if ([delegate respondsToSelector:@selector(SearchResultListViewControllerDidFinishScanPage:)]) {
        [delegate  SearchResultListViewControllerDidFinishScanPage:currentPage];
    }
}


#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate{
    
    
    // 下拉到最底部时显示更多数据
    
    float contentSizeHeight =scrollView.contentSize.height;
    float scrollViewHeight  =scrollView.frame.size.height;
    
    if (contentSizeHeight<scrollViewHeight) {
        contentSizeHeight=scrollViewHeight;
    }
    
    if( scrollView.contentOffset.y > ((contentSizeHeight - scrollView.frame.size.height)))
    {
        /*
        
        NSLog(@"%i",scanner.isScanning );
        //如果还在搜索则不执行搜索
        if (scanner.isScanning==NO) {
            //如果是在内文搜索就搜当前一页,否则可以搜索现更多页
            if (delegate && [delegate isKindOfClass:[ReaderViewController class]]){
                [self createTableFooter];
                [self showSpin];
                [scanner scanFromPageNumber:scanner.currentPageNumber +1];
            }
            
        }
        
        
        */
    }
    
}



-(void)pullUpGetDataBegin{
    
}

#pragma mark -
#pragma mark KVO support

- (void)insertDatas:(NSArray *)datas
{
    if (self.resultData==nil) {
        self.resultData=[NSMutableArray array];
    }
    if (datas.count>0) {
        [self willChangeValueForKey:@"resultData"];

        [self.resultData addObjectsFromArray:datas]; 
         
        [self didChangeValueForKey:@"resultData"];
        
        self.tableView.tableFooterView=nil;

    }
    
}


- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    
    
    
    
    [self.tableView reloadData];
}



#pragma mark - UISearchBar Delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)asearchBar{
    
  
    
    [self showSpin];
    
    [self startScanFromPage:1 WithKeyWord: asearchBar.text];
    [asearchBar resignFirstResponder];
    
    
}
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    
    [self.scanner stopScan];
}


#pragma mark -
#pragma mark Memory Manager
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [scanner stopScan];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    // Return the number of rows in the section.
    return [self.resultData count];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (!cell)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        
	}
    Selection* selection= (Selection*)[self.resultData objectAtIndex:indexPath.row];
    NSString* chapterName=[selection.chapter.bookName stringByDeletingPathExtension];
    cell.detailTextLabel.text=chapterName;
    cell.textLabel.text=[NSString stringWithFormat:@"第 %i 页:%@" ,selection.pageNumber,selection.unicodeContent];
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [scanner stopScan];
    
    Selection* selection=[resultData objectAtIndex:indexPath.row];
    
    if (delegate&& [delegate respondsToSelector:@selector(didSelectedSelection:Keyword:)]) {
        [delegate  didSelectedSelection:selection Keyword:_keyWord];
        
    }
    

      
}


#pragma mark -  view Orientation

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    
    if (device_Type == UIUserInterfaceIdiomPad) {
        return YES;
    }else{
        return NO;
    }
    
    
}

@end
