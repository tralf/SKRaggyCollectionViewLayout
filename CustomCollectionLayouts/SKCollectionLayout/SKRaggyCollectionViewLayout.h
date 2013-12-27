/*
 
 Custom UICollectionViewLayout for layout with horizontal scrolling, fixed cell height and variable cell width.
 
 */

#import <UIKit/UIKit.h>

@class SKRaggyCollectionViewLayout;

@protocol SKRaggyCollectionViewLayoutDelegate <UICollectionViewDelegate>

// Layout should know preferred width for element only, because its height would be calculated based on number of rows and collecton view height

- (float)collectionLayout:(SKRaggyCollectionViewLayout*)layout preferredWidthForItemAtIndexPath:(NSIndexPath *)indexPath;

@optional

- (UIEdgeInsets)collectionLayout:(SKRaggyCollectionViewLayout*)layout edgeInsetsForItemAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface SKRaggyCollectionViewLayout : UICollectionViewLayout

// Layout delegate.

@property (nonatomic, weak) IBOutlet id <SKRaggyCollectionViewLayoutDelegate> delegate;

// The number of rows for layout.
// Default value is 1.

@property (nonatomic, assign) NSUInteger numberOfRows;

// Set it to YES if you want raggy first and last rows of the collection.
// Default value is YES.

@property (nonatomic, assign) BOOL variableFrontierHeight;

// The fixed value of difference between neighbor cells for the first row in pixels.
// Default value is 20.
// Ignored if variableFrontierHeight is NO.

@property (nonatomic, assign) int fixedFirstRowVar;

// The fixed value of difference between neighbor cells for the last row in pixels.
// Default value is 20.
// Ignored if variableFrontierHeight is NO.

@property (nonatomic, assign) int fixedLastRowVar;

// A random value of difference between neighbor cells for the first row in pixels.
// Default value is 20.
// Ignored if variableFrontierHeight is NO.

@property (nonatomic, assign) int randomFirstRowVar;

// A random value of difference between neighbor cells for the last row in pixels.
// Default value is 20.
// Ignored if variableFrontierHeight is NO.

@property (nonatomic, assign) int randomLastRowVar;

@end
