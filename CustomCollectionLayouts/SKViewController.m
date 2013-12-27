

#import "SKViewController.h"

@interface SKViewController ()

@property (nonatomic, weak) IBOutlet UICollectionView *collection;
@property (nonatomic, weak) IBOutlet SKRaggyCollectionViewLayout *layout;

@end

static NSString *cellIdentifier = @"cell";

#define NUMBER_OF_ROWS              3

@implementation SKViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UINib *cellNib = [UINib nibWithNibName:@"SKCollectionViewCell" bundle:nil];
    [self.collection registerNib:cellNib forCellWithReuseIdentifier:cellIdentifier];
    self.layout.numberOfRows = NUMBER_OF_ROWS;
// set to YES because we want our layout to by raggy
    self.layout.variableFrontierHeight = YES;
    self.layout.fixedFirstRowVar = self.layout.fixedLastRowVar = 40.f;
    self.layout.variableFrontierHeight = self.layout.variableFrontierHeight = 30.f;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - UICollectionViewDelegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 6000;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
// create random cell color to make epileptics happy
    float r = arc4random() % 250;
    float g = arc4random() % 250;
    float b = arc4random() % 250;
    cell.backgroundColor = [UIColor colorWithRed:r/255.f green:g/255.f blue:b/255.f alpha:1.f];
    UILabel *l = (UILabel*)[cell viewWithTag:2];
    l.text = [NSString stringWithFormat:@"%d", indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark – SKCollectionLayoutDelegate

- (float)collectionLayout:(SKRaggyCollectionViewLayout*)layout preferredWidthForItemAtIndexPath:(NSIndexPath *)indexPath {
    float width = arc4random() % 400 + 100.f;
    return width;
}

- (UIEdgeInsets)collectionLayout:(SKRaggyCollectionViewLayout*)layout edgeInsetsForItemAtIndexPath:(NSIndexPath *)indexPath {
    return UIEdgeInsetsMake(10.f, 10.f, 10.f, 10.f);
}

@end
