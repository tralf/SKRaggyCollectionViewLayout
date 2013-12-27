

#import "SKRaggyCollectionViewLayout.h"

@interface SKRaggyCollectionViewLayout ()

// Saved prelayout frames with index path as key
@property (nonatomic, strong) NSMutableDictionary *framesByIndexPath;

// Stores cached index paths with frames as key
@property (nonatomic, strong) NSMutableDictionary *indexPathsByFrame;

// An array with saved X-coordinate for the right corner of the last cell for every row
@property (nonatomic, strong) NSMutableArray *edgeXPositions;

// Method to get the farthest X-coordinate among all rows
@property (nonatomic, readonly) float edgeX;

// Cached attributes, were returned with layoutAttributesForElementsInRect: method last time
@property (nonatomic, strong) NSMutableArray* previousLayoutAttributes;

// Rectangle for cached layout attributes for elements in rect returned last time
@property (nonatomic, assign) CGRect previousLayoutRect;

// Indicates whether previous cell at the first row is tall or short.
// Used for raggy first row.
@property (nonatomic, assign) BOOL prevWasTallFirst;

// Indicates whether previous cell at the last row is tall or short.
// Used for raggy last row.
@property (nonatomic, assign) BOOL prevWasTallLast;

@end


@implementation SKRaggyCollectionViewLayout

#pragma mark Initialization methods

- (id)init {
    if((self = [super init]))
        [self initialize];
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if((self = [super initWithCoder:aDecoder]))
        [self initialize];
    
    return self;
}

- (void)initialize {
// Initalize all defaults
    self.numberOfRows = 1;
    self.variableFrontierHeight = YES;
    self.framesByIndexPath = [[NSMutableDictionary alloc] init];
    self.indexPathsByFrame = [[NSMutableDictionary alloc] init];
    self.edgeXPositions = [[NSMutableArray alloc] init];
    [self flushEdgeXPositions];
    self.previousLayoutAttributes = [[NSMutableArray alloc] init];
    self.fixedLastRowVar = self.fixedFirstRowVar = 20.f;
    self.randomLastRowVar = self.randomFirstRowVar = 20.f;
}

#pragma mark Overridden methods for this class

- (void)setNumberOfRows:(NSUInteger)numberOfRows {
    _numberOfRows = numberOfRows;
    [self flushEdgeXPositions];
}

- (float)edgeX {
    float x = 0;
    for (NSNumber *f in self.edgeXPositions) {
        if ([f floatValue] > x) x = [f floatValue];
    }
    return x;
}

#pragma mark Overridden methods of UICollectionViewLayout

- (void)prepareLayout {
    [super prepareLayout];
// calculate and save frames for all indexPaths. Unfortunately, we must do it for all cells to know content size of the collection
    for (int i = 0; i < [self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:0]; i++) {
        NSIndexPath *path = [NSIndexPath indexPathForItem:i inSection:0];
        [self frameForIndexPath:path];
    }
}

// cleanup every cached data if current layout becomes invalid
- (void)invalidateLayout {
    self.prevWasTallFirst = YES;
    self.prevWasTallLast = NO;
    [self.framesByIndexPath removeAllObjects];
    [self.indexPathsByFrame removeAllObjects];
    [self.previousLayoutAttributes removeAllObjects];
    self.previousLayoutRect = CGRectZero;
    [self flushEdgeXPositions];
    [super invalidateLayout];
}

#pragma mark Methods for UICollectionLayout customization

- (CGSize)collectionViewContentSize {
    return CGSizeMake(self.edgeX, self.collectionView.frame.size.height);
}

- (NSArray*)layoutAttributesForElementsInRect:(CGRect)bounds {
// Return saved attributes if there are cached attributes for this rect
    if (CGRectEqualToRect(bounds, self.previousLayoutRect)) {
        return self.previousLayoutAttributes;
    }
    [self.previousLayoutAttributes removeAllObjects];
    self.previousLayoutRect = bounds;
    
#warning Weak point of the algorithm. Works slowly if there are more than 10000 cells
    
// Let's take all prelayouted frames and add to the result array if they intersect given rect
    NSArray *allFrames = self.framesByIndexPath.allValues;
    int count = 0;
    for (NSValue *frameValue in allFrames) {
        ++count;
        CGRect rect = [frameValue CGRectValue];
        if (CGRectIntersectsRect(rect, bounds)) {
            [self.previousLayoutAttributes addObject:[self layoutAttributesForItemAtIndexPath:[self.indexPathsByFrame objectForKey:[NSValue valueWithCGRect:rect]]]];
        }
    }
    return self.previousLayoutAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UIEdgeInsets insets = UIEdgeInsetsZero;
    if ([self.delegate respondsToSelector:@selector(collectionLayout:edgeInsetsForItemAtIndexPath:)]) {
        insets = [self.delegate collectionLayout:self edgeInsetsForItemAtIndexPath:indexPath];
    }
    CGRect frame = [self frameForIndexPath:indexPath];
// Get saved frame and edge insets for given path and create attributes object with them
    UICollectionViewLayoutAttributes* attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attributes.frame = UIEdgeInsetsInsetRect(frame, insets);
    return attributes;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return !(CGSizeEqualToSize(newBounds.size, self.collectionView.frame.size));
}

#pragma mark Supplementary methods

- (void)flushEdgeXPositions {
    [self.edgeXPositions removeAllObjects];
    for (int i = 0; i < self.numberOfRows; i++) {
        [self.edgeXPositions addObject:[NSNumber numberWithFloat:0.f]];
    }
}

// The method where there is all magic

- (CGRect)frameForIndexPath:(NSIndexPath*)path {
// if there is saved frame for fiven ath, return it
    NSValue *v = [self.framesByIndexPath objectForKey:path];
    if (v) return [v CGRectValue];
    
// Find X-coordinate and a row which are the closest to the collection left corner. A cell for this path should be placed here.
    int currentRow = 0;
    float currentX = MAXFLOAT;
    for (int i = 0; i < self.edgeXPositions.count; i++) {
        float x = [[self.edgeXPositions objectAtIndex:i] floatValue];
        if (x < currentX) {
            currentRow = i;
            currentX = x;
        }
    }
// Calculate cell frame values based on collection height, current row, currentX, the number of rows and delegate's preferredWidthForItemAtIndexPath: value
// If variableFrontierHeight is YES this value will be adjusted for the first and last rows
    float maxH = self.collectionView.frame.size.height;
    float rowMaxH = maxH / self.numberOfRows;
    float x = currentX;
    float y = rowMaxH * currentRow;
    float w = [self.delegate collectionLayout:self preferredWidthForItemAtIndexPath:path];
    float h = self.collectionView.frame.size.height / self.numberOfRows;
    float newH = h;
// Adjust height of the frame if we need raggy style
    if (self.variableFrontierHeight) {
        if (currentRow == 0) {
            float space = arc4random() % self.randomFirstRowVar;
            if (self.prevWasTallFirst) {
                space += self.fixedFirstRowVar;
            }
            self.prevWasTallFirst = !self.prevWasTallFirst;
            y += space;
            newH -= space;
        } else if (currentRow == self.numberOfRows - 1) {
            float space = arc4random() % self.randomLastRowVar;
            if (self.prevWasTallLast) {
                space += self.fixedLastRowVar;
            }
            self.prevWasTallLast = !self.prevWasTallLast;
            newH -= space;
        }
    }
// Assure that we have preferred height more than 1
    h = h <= 1 ? 1.f : h;
// Adjust frame width with new value of height to save cell's right proportions
    w = w * newH / h;
// Save new calculated data ad return
    [self.edgeXPositions replaceObjectAtIndex:currentRow withObject:[NSNumber numberWithFloat:x + w]];
    CGRect currentRect = CGRectMake(x, y, w, newH);
    NSValue *value = [NSValue valueWithCGRect:currentRect];
    [self.indexPathsByFrame setObject:path forKey:value];
    [self.framesByIndexPath setObject:value forKey:path];
    return currentRect;
}

@end
