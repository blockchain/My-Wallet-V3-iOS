//
//  ContactsViewController.m
//  Blockchain
//
//  Created by Kevin Wu on 11/1/16.
//  Copyright © 2016 Blockchain Luxembourg S.A. All rights reserved.
//

#import "ContactsViewController.h"
#import "BCModalViewController.h"
#import "Blockchain-Swift.h"
#import "Invitation.h"
#import "BCQRCodeView.h"
#import "NSString+NSString_EscapeQuotes.h"
#import "Contact.h"
#import "ContactDetailViewController.h"
#import "ContactTableViewCell.h"
#import "UIView+ChangeFrameAttribute.h"

#define VIEW_NAME_NEW_CONTACT @"newContact"

const int sectionContacts = 0;

@interface ContactsViewController () <UITableViewDelegate, UISearchBarDelegate, UITableViewDataSource>

@property (nonatomic) ContactDetailViewController *detailViewController;
@property (nonatomic) UITableView *tableView;
@property (nonatomic) UISearchBar *searchBar;
@property (nonatomic) NSArray *sections;
@property (nonatomic) NSArray *contactsToDisplay;
@property (nonatomic) NSArray *nonAlphabeticalContacts;
@property (nonatomic) UIView *noContactsView;
@property (nonatomic) NSDictionary *lastCreatedInvitation;
@property (nonatomic) AVCaptureSession *captureSession;
@property (nonatomic) AVCaptureVideoPreviewLayer *videoPreviewLayer;

@property (nonatomic) NSString *invitationFromURL;
@property (nonatomic) NSString *nameFromURL;

@property (nonatomic) NSString *invitationSentIdentifier;

@property (nonatomic) UIRefreshControl *refreshControl;

@property (nonatomic, copy) void (^onCompleteRelation)();
@property (nonatomic, copy) void (^onFailCompleteRelation)();

@end

@implementation ContactsViewController

#pragma mark - Lifecycle

- (id)initWithInvitation:(NSString *)identifier name:(NSString *)name
{
    if (self = [super init]) {
        self.invitationFromURL = identifier;
        self.nameFromURL = name;
    }
    return self;
}

- (id)initWithAcceptedInvitation:(NSString *)invitationSent
{
    if (self = [super init]) {
        self.invitationSentIdentifier = invitationSent;
    }
    return self;
}

- (void)showAcceptedInvitation:(NSString *)invitationSent
{
    NSArray *allContacts = [app.wallet.contacts allValues];
    for (Contact *contact in allContacts) {
        if ([contact.invitationSent isEqualToString:invitationSent]) {
            [app.wallet completeRelation:contact.identifier];
            break;
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.sections = [NSArray arrayWithObjects:@"",@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",
                     @"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z",@"#",nil];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.view.backgroundColor = COLOR_TABLE_VIEW_BACKGROUND_LIGHT_GRAY;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    BCNavigationController *navigationController = (BCNavigationController *)self.navigationController;
    navigationController.headerTitle = BC_STRING_CONTACTS;
    [navigationController.topRightButton removeFromSuperview];
    navigationController.topRightButton = nil;
    
    [self reload];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.invitationFromURL && self.nameFromURL) {
        [app.wallet readInvitation:[self JSDictionaryForInvitation:self.invitationFromURL name:self.nameFromURL]];
    } else if (self.invitationSentIdentifier) {
        [self showAcceptedInvitation:self.invitationSentIdentifier];
    }
    
    self.invitationFromURL = nil;
    self.nameFromURL = nil;\
    
    self.invitationSentIdentifier = nil;
    
    self.lastCreatedInvitation = nil;
    
    app.topViewControllerDelegate = (BCNavigationController *)self.navigationController;
}

- (void)setContactsToDisplay:(NSArray *)contactsToDisplay
{
    _contactsToDisplay = contactsToDisplay;
    
    [self updateNonAlphabeticalContacts];
}

- (void)updateNonAlphabeticalContacts
{
    if (self.contactsToDisplay && self.contactsToDisplay.count > 0) {
        NSMutableArray *contacts = [self.contactsToDisplay mutableCopy];
        
        NSString *beginsWithLetterRegex = @"^[A-Za-z].*";
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NOT (name MATCHES %@)", beginsWithLetterRegex];
        
        [contacts filterUsingPredicate:predicate];
        
        self.nonAlphabeticalContacts = contacts;
    } else {
        self.nonAlphabeticalContacts = nil;
    }
}

- (void)setupTableView
{
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, DEFAULT_HEADER_HEIGHT, self.view.frame.size.width, 44)];
    searchBar.placeholder = BC_STRING_SEARCH;
    searchBar.layer.borderColor = [COLOR_BLOCKCHAIN_BLUE CGColor];
    searchBar.layer.borderWidth = 1;
    searchBar.searchBarStyle = UISearchBarStyleProminent;
    searchBar.translucent = NO;
    searchBar.backgroundImage = [UIImage new];
    searchBar.tintAdjustmentMode = UIViewTintAdjustmentModeNormal;
    searchBar.barTintColor = COLOR_BLOCKCHAIN_BLUE;
    [[UIButton appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]]
     setTitle:BC_STRING_CANCEL forState:UIControlStateNormal];
    [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
    searchBar.delegate = self;
    [self.view addSubview:searchBar];
    self.searchBar = searchBar;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, searchBar.frame.origin.y + searchBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - DEFAULT_HEADER_HEIGHT) style:UITableViewStylePlain];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.sectionIndexColor = COLOR_BLOCKCHAIN_BLUE;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[ContactTableViewCell class] forCellReuseIdentifier:CELL_IDENTIFIER_CONTACT];
    [self.view addSubview:self.tableView];
}

- (void)setupNoContactsView
{
    self.noContactsView = [[UIView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:self.noContactsView];

    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.text = BC_STRING_NO_CONTACTS_YET_TITLE;
    titleLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_LARGE];
    titleLabel.textColor = COLOR_TEXT_HEADER_GRAY;
    [titleLabel sizeToFit];
    titleLabel.center = self.noContactsView.center;
    [self.noContactsView addSubview:titleLabel];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    imageView.image = [UIImage imageNamed:@"icon_contact"];
    imageView.frame = CGRectMake(0, titleLabel.frame.origin.y - 16 - 60, 100, 60);
    imageView.center = CGPointMake(self.noContactsView.center.x, imageView.center.y);
    [self.noContactsView addSubview:imageView];
    
    UITextView *subtitleTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, self.noContactsView.frame.size.width - 80, 0)];
    subtitleTextView.text = BC_STRING_NO_CONTACTS_YET_SUBTITLE;
    subtitleTextView.textAlignment = NSTextAlignmentCenter;
    subtitleTextView.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_MEDIUM];
    subtitleTextView.editable = NO;
    subtitleTextView.selectable = NO;
    subtitleTextView.scrollEnabled = NO;
    subtitleTextView.textColor = COLOR_TEXT_SUBHEADER_GRAY;
    subtitleTextView.textContainerInset = UIEdgeInsetsZero;
    subtitleTextView.frame = CGRectMake(0, titleLabel.frame.origin.y + titleLabel.frame.size.height + 8, subtitleTextView.frame.size.width, subtitleTextView.contentSize.height);
    subtitleTextView.center = CGPointMake(self.noContactsView.center.x, subtitleTextView.center.y);
    subtitleTextView.backgroundColor = [UIColor clearColor];
    [subtitleTextView sizeToFit];
    [self.noContactsView addSubview:subtitleTextView];
    
    UIButton *inviteButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 240, BUTTON_HEIGHT)];
    inviteButton.backgroundColor = COLOR_BLOCKCHAIN_LIGHT_BLUE;
    [inviteButton setTitle:BC_STRING_INVITE_CONTACT forState:UIControlStateNormal];
    inviteButton.titleLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_MEDIUM];
    inviteButton.titleLabel.textColor = [UIColor whiteColor];
    inviteButton.frame = CGRectMake(0, subtitleTextView.frame.origin.y + subtitleTextView.frame.size.height + 16, inviteButton.frame.size.width, inviteButton.frame.size.height);
    inviteButton.center = CGPointMake(self.noContactsView.center.x, inviteButton.center.y);
    inviteButton.layer.cornerRadius = CORNER_RADIUS_BUTTON;
    [inviteButton addTarget:self action:@selector(newContactClicked:) forControlEvents:UIControlEventTouchUpInside];

    [self.noContactsView addSubview:inviteButton];
}

- (void)refreshControlActivated
{
    [app.topViewControllerDelegate showBusyViewWithLoadingText:BC_STRING_LOADING_LOADING_TRANSACTIONS];
    [app.wallet performSelector:@selector(getHistory) withObject:nil afterDelay:0.1f];
}

- (void)setupPullToRefresh
{
    // Tricky way to get the refreshController to work on a UIViewController - @see http://stackoverflow.com/a/12502450/2076094
    UITableViewController *tableViewController = [[UITableViewController alloc] init];
    tableViewController.tableView = self.tableView;
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl setTintColor:[UIColor grayColor]];
    [self.refreshControl addTarget:self
                            action:@selector(refreshControlActivated)
                  forControlEvents:UIControlEventValueChanged];
    tableViewController.refreshControl = self.refreshControl;
}

- (void)reload
{
    [app.wallet getMessages];
}

- (void)updateContactDetail
{
    [self reload];
    
    NSString *contactIdentifier = self.detailViewController.contact.identifier;
    
    Contact *reloadedContact = [app.wallet.contacts objectForKey:contactIdentifier];
    
    self.detailViewController.contact = reloadedContact;
}

#pragma mark - Search Bar Delegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText && searchText.length > 0) {
        self.contactsToDisplay = [[app.wallet.contacts allValues] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name beginswith[c] %@", searchText]];
    } else {
        self.contactsToDisplay = [app.wallet.contacts allValues];
    }
    
    [self.tableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    searchBar.showsCancelButton = NO;
}

#pragma mark - Table View Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.sections.count;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return self.sections;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString*)title atIndex:(NSInteger)index
{
    return index;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 0;
    }
    
    NSArray *contacts = [self contactsForSection:section];
    
    return contacts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER_CONTACT forIndexPath:indexPath];
    
    NSArray *contacts = [self contactsForSection:indexPath.section];
    
    Contact *contact = contacts[indexPath.row];
    
    BOOL actionRequired = [app.wallet actionRequiredForContact:contact];
    
    [cell configureWithContact:contact actionRequired:actionRequired];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSArray *contacts = [self contactsForSection:indexPath.section];
    Contact *contact = contacts[indexPath.row];
    
    if (self.navigationController.topViewController == self) {
        [self contactClicked:contact];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 45.0;
    } else if ([self tableView:tableView numberOfRowsInSection:section] == 0) {
        return 0;
    } else {
        return 22.0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 45)];
        view.backgroundColor = [UIColor whiteColor];

        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, self.view.frame.size.width, 14)];
        label.text = BC_STRING_ADD_NEW_CONTACT;
        label.center = CGPointMake(label.center.x, view.center.y);
        [view addSubview:label];

        UIButton *addButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
        addButton.frame = CGRectMake(self.view.frame.size.width - 58, 4, 50, 40);
        addButton.tintColor = COLOR_BLOCKCHAIN_BLUE;
        addButton.center = CGPointMake(addButton.center.x, view.center.y);
        addButton.imageView.tintColor = COLOR_BLOCKCHAIN_BLUE;
        [addButton addTarget:self action:@selector(newContactClicked:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:addButton];
        
        return view;
    } else {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 22.0)];
        view.backgroundColor = [UIColor groupTableViewBackgroundColor];

        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.text = [self.sections objectAtIndex:section];
        [label sizeToFit];
        [label changeXPosition:20];
        label.center = CGPointMake(label.center.x, view.center.y);
        [view addSubview:label];
        
        return view;
    }
}

#pragma mark - Table View Helpers

- (NSArray *)contactsForSection:(NSInteger)section
{
    NSArray *contacts = self.contactsToDisplay;
    NSArray *sectionArray;
    
    if (section == self.sections.count - 1) {
        sectionArray = self.nonAlphabeticalContacts;
    } else {
        sectionArray = [contacts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name beginswith[c] %@", [self.sections objectAtIndex:section]]];
    }
    
    return sectionArray;
}

- (BOOL)isValidContactName:(NSString *)name
{
    void (^handler)() = ^(UIAlertAction * _Nonnull action) {
        [self newContactClicked:nil];
    };
    
    if ([self nameAlreadyExists:name]) {
        UIAlertController *invalidNameAlert = [UIAlertController alertControllerWithTitle:BC_STRING_ERROR message:BC_STRING_CONTACT_ALREADY_EXISTS preferredStyle:UIAlertControllerStyleAlert];
        [invalidNameAlert addAction:[UIAlertAction actionWithTitle:BC_STRING_OK style:UIAlertActionStyleCancel handler:handler]];
        [self presentViewController:invalidNameAlert animated:YES completion:nil];
        return NO;
    }
    return YES;
}

#pragma mark - Actions

- (void)contactClicked:(Contact *)contact
{
    self.onCompleteRelation = nil;
    self.onFailCompleteRelation = nil;
    
    if (contact.mdid) {
        self.detailViewController = [[ContactDetailViewController alloc] initWithContact:contact];
        [self.navigationController pushViewController:self.detailViewController animated:YES];
    } else {
        __weak ContactsViewController *weakSelf = self;
        self.onCompleteRelation = ^() {
            weakSelf.detailViewController = [[ContactDetailViewController alloc] initWithContact:contact];
            [weakSelf.navigationController pushViewController:weakSelf.detailViewController animated:YES];
        };
        self.onFailCompleteRelation = ^() {
            [weakSelf promptToResendInvitationToContact:contact];
        };
        [app.wallet completeRelation:contact.identifier];
    }
}

- (void)newContactClicked:(id)sender
{
    UIAlertController *newContactAlert = [UIAlertController alertControllerWithTitle:BC_STRING_INVITE_CONTACT message:BC_STRING_ENTER_NAME_CONTACT preferredStyle:UIAlertControllerStyleAlert];
    [newContactAlert addAction:[UIAlertAction actionWithTitle:BC_STRING_CANCEL style:UIAlertActionStyleCancel handler:nil]];
    UIAlertAction *submitAction = [UIAlertAction actionWithTitle:BC_STRING_NEXT style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *name = [[newContactAlert textFields] firstObject].text;
        if ([self isValidContactName:name]) {
            [self promptForUserNameWithContactName:name];
        }
    }];
    submitAction.enabled = NO;
    [newContactAlert addAction:submitAction];
    [newContactAlert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        [self configureTextField:textField];
    }];
    
    [self presentViewController:newContactAlert animated:YES completion:nil];
}

- (void)promptForUserNameWithContactName:(NSString *)contactName
{
    UIAlertController *userNameAlert = [self alertControllerForPromptingNameWithContactName:contactName];
    UIAlertAction *submitAction = [UIAlertAction actionWithTitle:BC_STRING_CONFIRM style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *senderName = [[userNameAlert textFields] firstObject].text;
        if ([app checkInternetConnection]) {
            [app showBusyViewWithLoadingText:BC_STRING_LOADING_CREATING_INVITATION];
            [app.wallet createContactWithName:senderName ID:contactName];
        }
    }];
    submitAction.enabled = NO;
    [userNameAlert addAction:submitAction];
    
    [self presentViewController:userNameAlert animated:YES completion:nil];
}

- (void)shareInvitationClicked
{
    NSString *identifier = [self.lastCreatedInvitation objectForKey:DICTIONARY_KEY_INVITATION_RECEIVED];
    NSString *sharedInfo = [self.lastCreatedInvitation objectForKey:DICTIONARY_KEY_NAME];
    
    NSString *helperText = [NSString stringWithFormat:BC_STRING_INVITE_HELPER_TEXT, sharedInfo];
    NSString *shareLink = [[[API sharedInstance] walletUrl] stringByAppendingFormat:@"/invite#id=%@&name=%@", [identifier stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]], [sharedInfo stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]]];
    NSArray *items = @[[NSString stringWithFormat:@"%@\n%@", helperText, shareLink]];
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
    
    [activityController setValue:BC_STRING_CONTACT_REQUEST_SUBJECT forKey:@"subject"];
    
    [self presentViewController:activityController animated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_SHARE_CONTACT_LINK object:nil];
    }];
}

- (void)reloadSymbols
{
    [self.detailViewController reloadSymbols];
}

- (void)promptToResendInvitationToContact:(Contact *)contact
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:BC_STRING_PENDING_CONTACT message:[NSString stringWithFormat:BC_STRING_WAITING_FOR_ARGUMENT_TO_ACCEPT_CONTACT_REQUEST, contact.name] preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:BC_STRING_RESEND_INVITE style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self resendInvitationForContact:contact];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:BC_STRING_DELETE_CONTACT style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self confirmDeleteContact:contact];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:BC_STRING_CANCEL style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)confirmDeleteContact:(Contact *)contact
{
    UIAlertController *alertForDeletingContact = [UIAlertController alertControllerWithTitle:BC_STRING_DELETE_CONTACT_ALERT_TITLE message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertForDeletingContact addAction:[UIAlertAction actionWithTitle:BC_STRING_CONTINUE style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [app.wallet deleteContact:contact.identifier];
    }]];
    [alertForDeletingContact addAction:[UIAlertAction actionWithTitle:BC_STRING_CANCEL style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertForDeletingContact animated:YES completion:nil];
}

- (void)resendInvitationForContact:(Contact *)contact
{
    UIAlertController *userNameAlert = [self alertControllerForPromptingNameWithContactName:contact.name];
    UIAlertAction *submitAction = [UIAlertAction actionWithTitle:BC_STRING_CONFIRM style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *senderName = [[userNameAlert textFields] firstObject].text;
        [self didCreateInvitation:@{DICTIONARY_KEY_INVITATION_RECEIVED : contact.invitationSent, DICTIONARY_KEY_NAME : senderName}];
    }];
    submitAction.enabled = NO;
    [userNameAlert addAction:submitAction];
    
    [self presentViewController:userNameAlert animated:YES completion:nil];
}

- (void)contactAcceptedInvitation:(NSString *)invitationSent
{
    [self reload];
}

#pragma mar - Alert Text Field Helper

- (void)alertTextFieldDidChange:(UITextField *)sender
{
    UIAlertController *alertController = (UIAlertController *)self.presentedViewController;
    if (alertController) {
        UITextField *textField = alertController.textFields.firstObject;
        UIAlertAction *confirmAction = alertController.actions.lastObject;
        confirmAction.enabled = textField.text.length > 0;
    }
}

#pragma mark - Helpers

- (NSString *)JSDictionaryForInvitation:(NSString *)identifier name:(NSString *)name;
{
    return [NSString stringWithFormat:@"{name: \"%@\", invitationReceived: \"%@\"}", [name escapeStringForJS], [identifier escapeStringForJS]];
}

- (BOOL)nameIsEmpty:(NSString *)name
{
    NSCharacterSet *inverted = [[NSCharacterSet whitespaceAndNewlineCharacterSet] invertedSet];
    NSRange range = [name rangeOfCharacterFromSet:inverted];
    return range.location == NSNotFound;
}

- (BOOL)nameAlreadyExists:(NSString *)name
{
    NSArray *allContacts = [app.wallet.contacts allValues];
    for (Contact *contact in allContacts) {
        if ([contact.name isEqualToString:name]) {
            return YES;
        }
    }
    
    return NO;
}

- (BCNavigationController *)navigationControllerForNewContact:(BCModalViewController *)modalViewController
{
    BCNavigationController *controller = [[BCNavigationController alloc] initWithRootViewController:modalViewController title:BC_STRING_ADD_NEW_CONTACT];
    
    __weak ContactsViewController *weakSelf = self;
    
    void (^checkAndDeleteContactInfo)() = ^() {
        if (weakSelf.lastCreatedInvitation) {
            NSString *contactId = [weakSelf.lastCreatedInvitation objectForKey:DICTIONARY_KEY_INVITATION_RECEIVED];
            [app.wallet deleteContactAfterStoringInfo:contactId];
            weakSelf.lastCreatedInvitation = nil;
        }
    };
    
    controller.onPopViewController = checkAndDeleteContactInfo;
    controller.onViewWillDisappear = checkAndDeleteContactInfo;
    
    return controller;
}

- (void)configureTextField:(UITextField *)textField
{
    BCSecureTextField *secureTextField = (BCSecureTextField *)textField;
    secureTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    secureTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    secureTextField.spellCheckingType = UITextSpellCheckingTypeNo;
    secureTextField.returnKeyType = UIReturnKeyNext;
    [secureTextField addTarget:self action:@selector(alertTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}

- (UIAlertController *)alertControllerForPromptingNameWithContactName:(NSString *)contactName
{
    UIAlertController *userNameAlert = [UIAlertController alertControllerWithTitle:BC_STRING_INVITE_CONTACT message:[NSString stringWithFormat:BC_STRING_WHAT_NAME_DOES_ARGUMENT_KNOW_YOU_BY, contactName] preferredStyle:UIAlertControllerStyleAlert];
    [userNameAlert addAction:[UIAlertAction actionWithTitle:BC_STRING_CANCEL style:UIAlertActionStyleCancel handler:nil]];
    [userNameAlert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        [self configureTextField:textField];
    }];
    
    return userNameAlert;
}

#pragma mark - Wallet Callbacks

- (void)didReadInvitation:(NSDictionary *)invitation identifier:(NSString *)identifier
{
    DLog(@"Read invitation success");
    
    NSString *name = [invitation objectForKey:DICTIONARY_KEY_NAME];
    NSString *invitationID = [invitation objectForKey:DICTIONARY_KEY_INVITATION_RECEIVED];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(ANIMATION_DURATION * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [app.wallet acceptRelation:identifier name:name identifier:invitationID];
    });
}

- (void)didAcceptRelation:(NSString *)invitation name:(NSString *)name
{
    DLog(@"Accept relation/invitation success");
    
    UIAlertController *successAlert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat: BC_STRING_ACCEPTED_RELATION_ALERT_TITLE_NAME_ARGUMENT, name] message:[NSString stringWithFormat:BC_STRING_ACCEPTED_RELATION_ALERT_MESSAGE_NAME_ARGUMENT, name] preferredStyle:UIAlertControllerStyleAlert];
    [successAlert addAction:[UIAlertAction actionWithTitle:BC_STRING_OK style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:successAlert animated:YES completion:nil];
    [self reload];
}

- (void)didCompleteRelation
{
    DLog(@"Complete relation success");
    
    [self reload];
    
    if (self.onCompleteRelation) {
        self.onCompleteRelation();
        self.onCompleteRelation = nil;
    }
}

- (void)didFailCompleteRelation
{
    DLog(@"Complete relation failure");
    
    if (self.onFailCompleteRelation) {
        self.onFailCompleteRelation();
        self.onFailCompleteRelation = nil;
    }
}

- (void)didFailAcceptRelation:(NSString *)name
{
    DLog(@"Accept relation failure");
    
    [app standardNotify:[NSString stringWithFormat:BC_STRING_ACCEPT_RELATION_ERROR_ALERT_MESSAGE_NAME_ARGUMENT, name]];
}

- (void)didCreateInvitation:(NSDictionary *)invitationDict
{
    [app hideBusyView];
    
    self.lastCreatedInvitation = invitationDict;
    
    [self shareInvitationClicked];
    
    [self reload];
}

- (void)didGetMessages
{
    self.contactsToDisplay = [app.wallet.contacts allValues];
    
    if (self.contactsToDisplay.count > 0) {
        [self.noContactsView removeFromSuperview];
        self.noContactsView = nil;
        
        if (!self.tableView) {
            [self setupTableView];
        }
    } else {
        [self.tableView removeFromSuperview];
        self.tableView = nil;
        
        [self.searchBar removeFromSuperview];
        self.searchBar = nil;
        
        self.refreshControl = nil;
        
        [self setupNoContactsView];
    }
    
    [self.tableView reloadData];
    
    if (self.detailViewController.contact.identifier) {
        Contact *updatedContact = [app.wallet.contacts objectForKey:self.detailViewController.contact.identifier];
        
        [self.detailViewController didGetMessages:updatedContact];
    }
    
    if (self.refreshControl && self.refreshControl.isRefreshing) {
        [self.refreshControl endRefreshing];
    }
}

- (void)didFetchExtendedPublicKey
{
    [self updateContactDetail];
    
    [self.detailViewController showExtendedPublicKey];
}

- (void)didChangeContactName
{
    [self reload];
}

- (void)didDeleteContactAfterStoringInfo
{
    [self reload];
}

@end
