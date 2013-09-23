//
//  DictionaryQueryViewController.m
//  Dictionary
//
//  Created by mono on 9/23/13.
//  Copyright (c) 2013 mono. All rights reserved.
//

#import "DictionaryQueryViewController.h"
#import <UIKit/UITextChecker.h>

typedef NS_ENUM (NSUInteger, SectionType) {
	SectionTypeMatch = 0,
    SectionTypeSeggestions = 1,
    SectionTypeHistory = 2,
    SectionTypeCount = 3,
};

@interface DictionaryQueryViewController ()
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic) NSString* matched;
@property (nonatomic) NSArray* suggestions;
@property (nonatomic) NSArray* history;
@property (nonatomic) UITextChecker* checker;
@end

@implementation DictionaryQueryViewController

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
        _searchBar.spellCheckingType = UITextSpellCheckingTypeNo;
        _checker = [[UITextChecker alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return SectionTypeCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case SectionTypeMatch:
            return _matched ? 1 : 0;
            break;
        case SectionTypeSeggestions:
            return _suggestions.count;
            break;
        case SectionTypeHistory:
            return _history.count;
            break;
        default:
            NSAssert(NO, @"異常な型");
            break;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *ret;
    switch (section) {
        case SectionTypeMatch:
            ret = NSLocalizedString(@"Match", nil);
            break;
        case SectionTypeSeggestions:
            ret = NSLocalizedString(@"Suggestions", nil);
            break;
        case SectionTypeHistory:
            ret = NSLocalizedString(@"History", nil);
            break;
        default:
            NSAssert(NO, @"異常な型");
            break;
    }
    return ret;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    NSString *text;
    switch (indexPath.section) {
        case SectionTypeMatch:
            text = _matched;
            break;
        case SectionTypeSeggestions:
            text = [_suggestions objectAtIndex:indexPath.row];
            break;
        case SectionTypeHistory:
            text = [_history objectAtIndex:indexPath.row];
            break;
        default:
            NSAssert(NO, @"異常な型");
            break;
    }
    cell.textLabel.text = text;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *term = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
    if (!term) {
        return;
    }
    UIViewController *vc = [[UIReferenceLibraryViewController alloc] initWithTerm:term];
    [self.navigationController pushViewController:vc animated:YES];
    
}


#pragma mark - UISearchBarDelegate
- (void)search
{
    [self tableView:self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    _suggestions = [_checker guessesForWordRange:NSMakeRange(0, searchText.length)
                                        inString:searchText
                                        language:@"en_US"];
#warning en_US??
    // 一致した単語があるかどうかを判定
    BOOL isMatched = [UIReferenceLibraryViewController dictionaryHasDefinitionForTerm:searchText];
    _matched = isMatched &&  searchText.length ? searchText : nil;
    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                animated:YES
                          scrollPosition:UITableViewScrollPositionNone];
    [self search];
}

- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar
{
    // called when bookmark button pressed
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    // called when cancel button pressed
}

- (void)searchBarResultsListButtonClicked:(UISearchBar *)searchBar
{
    // called when search results button pressed
}
@end
