//
//  Wallet.m
//  Blockchain
//
//  Created by Ben Reeves on 16/03/2012.
//  Copyright (c) 2012 Blockchain Luxembourg S.A. All rights reserved.
//

#import "Wallet.h"
#import "RootService.h"
#import "Transaction.h"
#import "EtherTransaction.h"
#import "Contact.h"
#import "ContactTransaction.h"
#import "NSString+NSString_EscapeQuotes.h"
#import "MultiAddressResponse.h"
#import "UncaughtExceptionHandler.h"
#import "NSString+JSONParser_NSString.h"
#import "NSString+NSString_EscapeQuotes.h"
#import "crypto_scrypt.h"
#import "NSData+Hex.h"
#import "TransactionsBitcoinViewController.h"
#import "NSArray+EncodedJSONString.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "ModuleXMLHttpRequest.h"
#import "KeychainItemWrapper+Credentials.h"
#import <openssl/evp.h>
#import "SessionManager.h"
#import "NSURLRequest+SRWebSocket.h"
#import <CommonCrypto/CommonKeyDerivation.h>
#import "HDNode.h"
#import "PrivateHeaders.h"
#import "Assets.h"
#import "ExchangeTrade.h"

#import "BTCKey.h"
#import "BTCData.h"
#import "KeyPair.h"
#import "NSData+BTCData.h"

@interface Wallet ()
@property (nonatomic) JSContext *context;
@property (nonatomic) BOOL isSettingDefaultAccount;
@property (nonatomic) NSMutableDictionary *timers;
@end

@implementation transactionProgressListeners
@end

@implementation Key
@synthesize addr;
@synthesize priv;
@synthesize tag;
@synthesize label;

- (NSString *)description
{
    return [NSString stringWithFormat:@"<Key : addr %@, tag, %d>", addr, tag];
}

- (NSComparisonResult)compare:(Key *)otherObject
{
    return [self.addr compare:otherObject.addr];
}

@end

@implementation Wallet

@synthesize delegate;
@synthesize password;
@synthesize sharedKey;
@synthesize guid;

- (id)init
{
    self = [super init];
    
    if (self) {
        _transactionProgressListeners = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (NSString *)getJSSource
{
    NSString *walletJSPath = [[NSBundle mainBundle] pathForResource:JAVASCRIPTCORE_RESOURCE_MY_WALLET ofType:JAVASCRIPTCORE_TYPE_JS];
    NSString *walletiOSPath = [[NSBundle mainBundle] pathForResource:JAVASCRIPTCORE_RESOURCE_WALLET_IOS ofType:JAVASCRIPTCORE_TYPE_JS];
    NSString *walletJSSource = [NSString stringWithContentsOfFile:walletJSPath encoding:NSUTF8StringEncoding error:nil];
    NSString *walletiOSSource = [NSString stringWithContentsOfFile:walletiOSPath encoding:NSUTF8StringEncoding error:nil];
    
    NSString *jsSource = [NSString stringWithFormat:@"%@\n%@\n%@", JAVASCRIPTCORE_PREFIX_JS_SOURCE, walletJSSource, walletiOSSource];
    
    return jsSource;
}

- (NSString *)getConsoleScript
{
    return @"var console = {};";
}

- (id)getExceptionHandler
{
    return ^(JSContext *context, JSValue *exception) {
        NSString *stacktrace = [[exception objectForKeyedSubscript:JAVASCRIPTCORE_STACK] toString];
        // type of Number
        NSString *lineNumber = [[exception objectForKeyedSubscript:JAVASCRIPTCORE_LINE] toString];
        
        DLog(@"%@ \nstack: %@\nline number: %@", [exception toString], stacktrace, lineNumber);
    };
}

- (NSSet *)getConsoleFunctionNames
{
    return [[NSSet alloc] initWithObjects:@"log", @"debug", @"info", @"warn", @"error", @"assert", @"dir", @"dirxml", @"group", @"groupEnd", @"time", @"timeEnd", @"count", @"trace", @"profile", @"profileEnd", nil];
}

- (NSMutableDictionary *)timers
{
    if (!_timers) {
        _timers = [NSMutableDictionary new];
    }
    
    return _timers;
}

- (id)getSetTimeout
{
    __weak Wallet *weakSelf = self;

    return ^(JSValue* callback, double timeout) {
        
        NSString *uuid = [[NSUUID alloc] init].UUIDString;
        
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:timeout/1000
                                                          target:[NSBlockOperation blockOperationWithBlock:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([weakSelf.timers objectForKey:uuid]) {
                    [callback callWithArguments:nil];
                }
            });
        }]
                                                        selector:@selector(main)
                                                        userInfo:nil
                                                         repeats:NO];

        weakSelf.timers[uuid] = timer;
        [timer fire];
        
        return uuid;
    };
}

- (id)getClearTimeout
{
    __weak Wallet *weakSelf = self;

    return ^(NSString *identifier) {
        NSTimer *timer = (NSTimer *)[weakSelf.timers objectForKey:identifier];
        [timer invalidate];
        [weakSelf.timers removeObjectForKey:identifier];
    };
}

- (id)getSetInterval
{
    __weak Wallet *weakSelf = self;
    
    return ^(JSValue *callback, double timeout) {
        
        NSString *uuid = [[NSUUID alloc] init].UUIDString;
        
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:timeout/1000
                                                          target:[NSBlockOperation blockOperationWithBlock:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([weakSelf.timers objectForKey:uuid]) {
                    [callback callWithArguments:nil];
                }
            });
        }]
                                                        selector:@selector(main)
                                                        userInfo:nil
                                                         repeats:YES];
        weakSelf.timers[uuid] = timer;
        [timer fire];
        
        return uuid;
    };
}

- (id)getClearInterval
{
    __weak Wallet *weakSelf = self;
    
    return ^(NSString *identifier) {
        NSTimer *timer = (NSTimer *)[weakSelf.timers objectForKey:identifier];
        [timer invalidate];
        [weakSelf.timers removeObjectForKey:identifier];
    };
}

- (void)loadJS
{
    self.context = [[JSContext alloc] init];
    
    [self.context evaluateScript:[self getConsoleScript]];
    
    NSSet *names = [self getConsoleFunctionNames];
    
    for (NSString *name in names) {
        self.context[@"console"][name] = ^(NSString *message) {
            DLog(@"Javascript %@: %@", name, message);
        };
    }
    
    __weak Wallet *weakSelf = self;
    
    self.context.exceptionHandler = [self getExceptionHandler];
    
    self.context[JAVASCRIPTCORE_SET_TIMEOUT] = [self getSetTimeout];
    self.context[JAVASCRIPTCORE_CLEAR_TIMEOUT] = [self getClearTimeout];
    self.context[JAVASCRIPTCORE_SET_INTERVAL] = [self getSetInterval];
    self.context[JAVASCRIPTCORE_CLEAR_INTERVAL] = [self getClearInterval];
    
#pragma mark Decryption
    
    self.context[@"objc_message_sign"] = ^(KeyPair *keyPair, NSString *message, JSValue *network) {
         return [[keyPair.key signatureForMessage:message] hexadecimalString];
    };
    
    self.context[@"objc_get_shared_key"] = ^(KeyPair *publicKey, KeyPair *privateKey) {
        return [BTCSHA256([[publicKey.key diffieHellmanWithPrivateKey:privateKey.key] publicKey]) hexadecimalString];
    };
    
    self.context[@"objc_message_verify_base64"] = ^(NSString *address, NSString *signature, NSString *message) {
        NSData *signatureData = [[NSData alloc] initWithBase64EncodedString:signature options:kNilOptions];
        NSData *messageData = [message dataUsingEncoding:NSUTF8StringEncoding];
        BTCKey *key = [BTCKey verifySignature:signatureData forBinaryMessage:messageData];
        KeyPair *keyPair = [[KeyPair alloc] initWithKey:key network:nil];
        return [[keyPair getAddress] isEqualToString:address];
    };
    
    self.context[@"objc_message_verify"] = ^(NSString *address, NSString *signature, NSString *message) {
        NSData *signatureData = BTCDataFromHex(signature);
        NSData *messageData = [message dataUsingEncoding:NSUTF8StringEncoding];
        BTCKey *key = [BTCKey verifySignature:signatureData forBinaryMessage:messageData];
        KeyPair *keyPair = [[KeyPair alloc] initWithKey:key network:nil];
        return [[keyPair getAddress] isEqualToString:address];
    };
    
    self.context[@"objc_pbkdf2_sync"] = ^(NSString *mnemonicBuffer, NSString *saltBuffer, int iterations, int keylength, NSString *digest) {
        // Salt data getting from salt string.
        NSData *saltData = [saltBuffer dataUsingEncoding:NSUTF8StringEncoding];
        
        // Data of String to generate Hash key(hexa decimal string).
        NSData *passwordData = [mnemonicBuffer dataUsingEncoding:NSUTF8StringEncoding];
        
        // Hash key (hexa decimal) string data length.
        NSMutableData *hashKeyData = [NSMutableData dataWithLength:keylength];
        
        // Key Derivation using PBKDF2 algorithm.
        int result = CCKeyDerivationPBKDF(kCCPBKDF2, passwordData.bytes, passwordData.length, saltData.bytes, saltData.length, kCCPRFHmacAlgSHA512, iterations, hashKeyData.mutableBytes, hashKeyData.length);
        
        return [hashKeyData hexadecimalString];
    };
    
    self.context[@"objc_sjcl_misc_pbkdf2"] = ^(NSString *_password, id _salt, int iterations, int keylength, NSString *hmacSHA1) {
        
        uint8_t * finalOut = malloc(keylength);
        
        uint8_t * _saltBuff = NULL;
        size_t _saltBuffLen = 0;
        
        if ([_salt isKindOfClass:[NSArray class]]) {
            _saltBuff = alloca([_salt count]);
            _saltBuffLen = [_salt count];
            
            {
                int ii = 0;
                for (NSNumber * number in _salt) {
                    _saltBuff[ii] = [number shortValue];
                    ++ii;
                }
            }
        } else if ([_salt isKindOfClass:[NSString class]]) {
            _saltBuff = (uint8_t*)[_salt UTF8String];
            _saltBuffLen = [_salt length];
        } else {
            DLog(@"Scrypt salt unsupported type");
            return [[NSData new] hexadecimalString];
        }
        
        const char *passwordUTF8String = [_password UTF8String];
        
        if (PKCS5_PBKDF2_HMAC_SHA1(passwordUTF8String, (int)strlen(passwordUTF8String), _saltBuff, (int)_saltBuffLen, iterations, keylength, finalOut) == 0) {
            return [[NSData new] hexadecimalString];
        };
        
        return [[NSData dataWithBytesNoCopy:finalOut length:keylength] hexadecimalString];
    };
    
    self.context[@"objc_get_satoshi"] = ^() {
        return SATOSHI;
    };
    
    self.context[@"objc_on_error_maintenance_mode"] = ^(){
        [weakSelf on_error_maintenance_mode];
    };
    
    self.context[@"objc_on_error_pin_code_get_timeout"] = ^(){
        [weakSelf on_error_pin_code_get_timeout];
    };
    
    self.context[@"objc_on_error_pin_code_get_empty_response"] = ^(){
        [weakSelf on_error_pin_code_get_empty_response];
    };
    
    self.context[@"objc_on_error_pin_code_put_error"] = ^(NSString *error){
        [weakSelf on_error_pin_code_put_error:error];
    };
    
    self.context[@"objc_on_error_creating_new_account"] = ^(NSString *error) {
        [weakSelf on_error_creating_new_account:error];
    };
    
    self.context[@"objc_on_pin_code_get_response"] = ^(NSDictionary *response) {
        [weakSelf on_pin_code_get_response:response];
    };
    
    self.context[@"objc_loading_start_download_wallet"] = ^(){
        [weakSelf loading_start_download_wallet];
    };
    
    self.context[@"objc_loading_start_get_wallet_and_history"] = ^() {
        [weakSelf loading_start_get_wallet_and_history];
    };
    
    self.context[@"objc_loading_stop"] = ^(){
        [weakSelf loading_stop];
    };
    
    self.context[@"objc_did_load_wallet"] = ^(){
        [weakSelf did_load_wallet];
    };
    
    self.context[@"objc_did_decrypt"] = ^(){
        [weakSelf did_decrypt];
    };
    
    self.context[@"objc_error_other_decrypting_wallet"] = ^(NSString *error) {
        [weakSelf error_other_decrypting_wallet:error];
    };
    
    self.context[@"objc_loading_start_decrypt_wallet"] = ^(){
        [weakSelf loading_start_decrypt_wallet];
    };
    
    self.context[@"objc_loading_start_build_wallet"] = ^(){
        [weakSelf loading_start_build_wallet];
    };
    
    self.context[@"objc_loading_start_multiaddr"] = ^(){
        [weakSelf loading_start_multiaddr];
    };
    
#pragma mark Multiaddress
    
    self.context[@"objc_did_set_latest_block"] = ^(){
        [weakSelf did_set_latest_block];
    };
    
    self.context[@"objc_did_multiaddr"] = ^(){
        [weakSelf did_multiaddr];
    };
    
    self.context[@"objc_loading_start_get_history"] = ^(){
        [weakSelf loading_start_get_history];
    };
    
    self.context[@"objc_on_get_history_success"] = ^(){
        [weakSelf on_get_history_success];
    };
    
    self.context[@"objc_on_error_get_history"] = ^(NSString *error) {
        [weakSelf on_error_get_history:error];
    };
    
    self.context[@"objc_update_loaded_all_transactions"] = ^(NSNumber *index) {
        [weakSelf update_loaded_all_transactions:index];
    };
    
#pragma mark Send Screen
    
    self.context[@"objc_update_send_balance_fees"] = ^(NSNumber *balance, NSDictionary *fees) {
        [weakSelf update_send_balance:balance fees:fees];
    };
    
    self.context[@"objc_update_surge_status"] = ^(NSNumber *surgeStatus) {
        [weakSelf update_surge_status:surgeStatus];
    };
    
    self.context[@"objc_did_change_satoshi_per_byte_dust_show_summary"] = ^(NSNumber *sweepAmount, NSNumber *fee, NSNumber *dust, FeeUpdateType updateType) {
        [weakSelf did_change_satoshi_per_byte:sweepAmount fee:fee dust:dust updateType:updateType];
    };
    
    self.context[@"objc_update_max_amount_fee_dust_willConfirm"] = ^(NSNumber *maxAmount, NSNumber *fee, NSNumber *dust, NSNumber *willConfirm) {
        [weakSelf update_max_amount:maxAmount fee:fee dust:dust willConfirm:willConfirm];
    };
    
    self.context[@"objc_update_total_available_final_fee"] = ^(NSNumber *sweepAmount, NSNumber *finalFee) {
        [weakSelf update_total_available:sweepAmount final_fee:finalFee];
    };
    
    self.context[@"objc_check_max_amount_fee"] = ^(NSNumber *amount, NSNumber *fee) {
        [weakSelf check_max_amount:amount fee:fee];
    };
    
    self.context[@"objc_did_get_fee_dust_txSize"] = ^(NSNumber *fee, NSNumber *dust, NSNumber *txSize) {
        [weakSelf did_get_fee:fee dust:dust txSize:txSize];
    };
    
    self.context[@"objc_tx_on_success_secondPassword_hash"] = ^(NSString *success, NSString *secondPassword, NSString *txHash) {
        [weakSelf tx_on_success:success secondPassword:secondPassword transactionHash:txHash];
    };
    
    self.context[@"objc_tx_on_start"] = ^(NSString *transactionId) {
        [weakSelf tx_on_start:transactionId];
    };
    
    self.context[@"objc_tx_on_begin_signing"] = ^(NSString *transactionId) {
        [weakSelf tx_on_begin_signing:transactionId];
    };
    
    self.context[@"objc_tx_on_sign_progress_input"] = ^(NSString *transactionId, NSString *input) {
        [weakSelf tx_on_sign_progress:transactionId input:input];
    };
    
    self.context[@"objc_tx_on_finish_signing"] = ^(NSString *transactionId) {
        [weakSelf tx_on_finish_signing:transactionId];
    };
    
    self.context[@"objc_on_error_update_fee"] = ^(NSDictionary *error, FeeUpdateType updateType) {
        [weakSelf on_error_update_fee:error updateType:updateType];
    };
    
    self.context[@"objc_on_success_import_key_for_sending_from_watch_only"] = ^() {
        [weakSelf on_success_import_key_for_sending_from_watch_only];
    };
    
    self.context[@"objc_on_error_import_key_for_sending_from_watch_only"] = ^(NSString *error) {
        [weakSelf on_error_import_key_for_sending_from_watch_only:error];
    };
    
    self.context[@"objc_on_payment_notice"] = ^(NSString *notice) {
        [weakSelf on_payment_notice:notice];
    };
    
    self.context[@"objc_tx_on_error_error_secondPassword"] = ^(NSString *txId, NSString *error, NSString *secondPassword) {
        [weakSelf tx_on_error:txId error:error secondPassword:secondPassword];
    };
    
#pragma mark Wallet Creation/Pairing
    
    self.context[@"objc_on_create_new_account_sharedKey_password"] = ^(NSString *_guid, NSString *_sharedKey, NSString *_password) {
        [weakSelf on_create_new_account:_guid sharedKey:_sharedKey password:_password];
    };
    
    self.context[@"objc_didParsePairingCode"] = ^(NSDictionary *pairingCode) {
        [weakSelf didParsePairingCode:pairingCode];
    };
    
    self.context[@"objc_errorParsingPairingCode"] = ^(NSString *error) {
        [weakSelf errorParsingPairingCode:error];
    };

    self.context[@"objc_didMakePairingCode"] = ^(NSString *pairingCode) {
        [weakSelf didMakePairingCode:pairingCode];
    };

    self.context[@"objc_errorMakingPairingCode"] = ^(NSString *error) {
        [weakSelf errorMakingPairingCode:error];
    };

    self.context[@"objc_error_restoring_wallet"] = ^(){
        [weakSelf error_restoring_wallet];
    };
    
    self.context[@"objc_on_pin_code_put_response"] = ^(NSDictionary *response) {
        [weakSelf on_pin_code_put_response:response];
    };
    
    self.context[@"objc_get_second_password"] = ^(JSValue *secondPassword, JSValue *helperText) {
        [weakSelf getSecondPassword:nil success:secondPassword error:nil helperText:[helperText isUndefined] ? nil :  [helperText toString]];
    };
    
    self.context[@"objc_get_private_key_password"] = ^(JSValue *privateKeyPassword) {
        [weakSelf getPrivateKeyPassword:nil success:privateKeyPassword error:nil];
    };
    
    self.context[@"objc_on_resend_two_factor_sms_success"] = ^() {
        [weakSelf on_resend_two_factor_sms_success];
    };
    
    self.context[@"objc_on_resend_two_factor_sms_error"] = ^(NSString *error) {
        [weakSelf on_resend_two_factor_sms_error:error];
    };
    
#pragma mark Accounts/Addresses
    
    self.context[@"objc_getRandomValues"] = ^(JSValue *intArray) {
        DLog(@"objc_getRandomValues");
        
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:@"/dev/urandom"];
        
        if (!fileHandle) {
            @throw [NSException exceptionWithName:@"GetRandomValues Exception"
                                           reason:@"fileHandleForReadingAtPath:/dev/urandom returned nil" userInfo:nil];
        }
        
        NSUInteger length = [[intArray toArray] count];
        NSData *data = [fileHandle readDataOfLength:length];

        if ([data length] != length) {
            @throw [NSException exceptionWithName:@"GetRandomValues Exception"
                                           reason:@"Data length is not equal to intArray length" userInfo:nil];
        }
        
        return [data hexadecimalString];
    };
    
    self.context[@"objc_crypto_scrypt_salt_n_r_p_dkLen"] = ^(id _password, id salt, NSNumber *N, NSNumber *r, NSNumber *p, NSNumber *derivedKeyLen, JSValue *success, JSValue *error) {
        [weakSelf crypto_scrypt:_password salt:salt n:N r:r p:p dkLen:derivedKeyLen success:success error:error];
    };
    
    self.context[@"objc_loading_start_create_new_address"] = ^() {
        [weakSelf loading_start_create_new_address];
    };
    
    self.context[@"objc_on_error_creating_new_address"] = ^(NSString *error) {
        [weakSelf on_error_creating_new_address:error];
    };
    
    self.context[@"objc_on_generate_key"] = ^() {
        [weakSelf on_generate_key];
    };
    
    self.context[@"objc_on_add_new_account"] = ^() {
        [weakSelf on_add_new_account];
    };
    
    self.context[@"objc_on_error_account_name_in_use"] = ^() {
        [weakSelf on_error_account_name_in_use];
    };
    
    self.context[@"objc_on_error_add_new_account"] = ^(NSString *error) {
        [weakSelf on_error_add_new_account:error];
    };
    
    self.context[@"objc_loading_start_new_account"] = ^() {
        [weakSelf loading_start_new_account];
    };
    
    self.context[@"objc_on_add_private_key_start"] = ^() {
        [weakSelf on_add_private_key_start];
    };
    
    self.context[@"objc_on_add_incorrect_private_key"] = ^(NSString *address) {
        [weakSelf on_add_incorrect_private_key:address];
    };
    
    self.context[@"objc_on_add_private_key_to_legacy_address"] = ^(NSString *address) {
        [weakSelf on_add_private_key_to_legacy_address:address];
    };
    
    self.context[@"objc_on_add_key"] = ^(NSString *key) {
        [weakSelf on_add_key:key];
    };
    
    self.context[@"objc_on_error_adding_private_key"] = ^(NSString *error) {
        [weakSelf on_error_adding_private_key:error];
    };
    
    self.context[@"objc_on_add_incorrect_private_key"] = ^(NSString *key) {
        [weakSelf on_add_incorrect_private_key:key];
    };
    
    self.context[@"objc_on_error_adding_private_key_watch_only"] = ^(NSString *key) {
        [weakSelf on_error_adding_private_key_watch_only:key];
    };
    
    self.context[@"objc_update_transfer_all_amount_fee_addressesUsed"] = ^(NSNumber *amount, NSNumber *fee, NSArray *addressesUsed) {
        [weakSelf update_transfer_all_amount:amount fee:fee addressesUsed:addressesUsed];
    };
    
    self.context[@"objc_loading_start_transfer_all"] = ^(NSNumber *index, NSNumber *totalAddreses) {
        [weakSelf loading_start_transfer_all:index totalAddresses:totalAddreses];
    };
    
    self.context[@"objc_on_error_transfer_all_secondPassword"] = ^(NSString *error, NSString *secondPassword) {
        [weakSelf on_error_transfer_all:error secondPassword:secondPassword];
    };
    
    self.context[@"objc_send_transfer_all"] = ^(NSString *secondPassword) {
        [weakSelf send_transfer_all:secondPassword];
    };
    
    self.context[@"objc_show_summary_for_transfer_all"] = ^() {
        [weakSelf show_summary_for_transfer_all];
    };
    
    self.context[@"objc_did_archive_or_unarchive"] = ^() {
        [weakSelf did_archive_or_unarchive];
    };
    
    self.context[@"objc_did_get_swipe_addresses"] = ^(NSArray *swipeAddresses) {
        [weakSelf did_get_swipe_addresses:swipeAddresses];
    };
    
#pragma mark State
    
    self.context[@"objc_reload"] = ^() {
        [weakSelf reload];
    };
    
    self.context[@"objc_on_backup_wallet_start"] = ^() {
        [weakSelf on_backup_wallet_start];
    };
    
    self.context[@"objc_on_backup_wallet_success"] = ^() {
        [weakSelf on_backup_wallet_success];
    };
    
    self.context[@"objc_on_backup_wallet_error"] = ^() {
        [weakSelf on_backup_wallet_error];
    };
    
    self.context[@"objc_on_get_session_token"] = ^(NSString *token) {
        [weakSelf on_get_session_token:token];
    };
    
    self.context[@"objc_ws_on_open"] = ^() {
        [weakSelf ws_on_open];
    };
    
    self.context[@"objc_on_tx_received"] = ^() {
        [weakSelf on_tx_received];
    };
    
    self.context[@"objc_makeNotice_id_message"] = ^(NSString *type, NSString *_id, NSString *message) {
        [weakSelf makeNotice:type id:_id message:message];
    };
    
    self.context[@"objc_upgrade_success"] = ^() {
        [weakSelf upgrade_success];
    };
    
#pragma mark Recovery
    
    self.context[@"objc_loading_start_generate_uuids"] = ^() {
        [weakSelf loading_start_generate_uuids];
    };
    
    self.context[@"objc_loading_start_recover_wallet"] = ^() {
        [weakSelf loading_start_recover_wallet];
    };
    
    self.context[@"objc_on_success_recover_with_passphrase"] = ^(NSDictionary *totalReceived, NSString *finalBalance) {
        [weakSelf on_success_recover_with_passphrase:totalReceived];
    };
    
    self.context[@"objc_on_error_recover_with_passphrase"] = ^(NSString *error) {
        [weakSelf on_error_recover_with_passphrase:error];
    };
    
#pragma mark Buy/Sell
    
    self.context[@"objc_get_whitelisted_guids"] = ^(JSValue *trade) {
        return WHITELISTED_GUIDS;
    };
    
    self.context[@"objc_show_completed_trade"] = ^(JSValue *trade) {
        [weakSelf show_completed_trade:trade];
    };
    
    self.context[@"objc_on_get_pending_trades_error"] = ^(JSValue *error) {
        [weakSelf on_get_pending_trades_error:error];
    };
    
    self.context[@"objc_initialize_webview"] = ^() {
        [weakSelf initialize_webview];
    };
    
#pragma mark Settings
    
    self.context[@"objc_on_get_account_info_success"] = ^(NSString *accountInfo) {
        [weakSelf on_get_account_info_success:accountInfo];
    };
    
    self.context[@"objc_on_get_all_currency_symbols_success"] = ^(NSString *currencies) {
        [weakSelf on_get_all_currency_symbols_success:currencies];
    };
    
    self.context[@"objc_on_error_creating_new_address"] = ^(NSString *error) {
        [weakSelf on_error_creating_new_address:error];
    };
    
    self.context[@"objc_on_progress_recover_with_passphrase_finalBalance"] = ^(NSString *totalReceived, NSString *finalBalance) {
        [weakSelf on_progress_recover_with_passphrase:totalReceived finalBalance:finalBalance];
    };
    
    self.context[@"objc_on_success_get_recovery_phrase"] = ^(NSString *recoveryPhrase) {
        [weakSelf on_success_get_recovery_phrase:recoveryPhrase];
    };
    
    self.context[@"objc_on_change_local_currency_success"] = ^() {
        [weakSelf on_change_local_currency_success];
    };
    
    self.context[@"objc_on_change_currency_error"] = ^() {
        [weakSelf on_change_currency_error];
    };
    
    self.context[@"objc_on_change_email_success"] = ^() {
        [weakSelf on_change_email_success];
    };
    
    self.context[@"objc_on_change_notifications_success"] = ^() {
        [weakSelf on_change_notifications_success];
    };
    
    self.context[@"objc_on_change_notifications_error"] = ^() {
        [weakSelf on_change_notifications_error];
    };
    
    self.context[@"objc_on_change_two_step_success"] = ^() {
        [weakSelf on_change_two_step_success];
    };
    
    self.context[@"objc_on_change_two_step_error"] = ^() {
        [weakSelf on_change_two_step_error];
    };
    
    self.context[@"objc_on_change_password_success"] = ^() {
        [weakSelf on_change_password_success];
    };
    
    self.context[@"objc_on_change_password_error"] = ^() {
        [weakSelf on_change_password_error];
    };
    
    self.context[@"objc_on_verify_mobile_number_success"] = ^() {
        [weakSelf on_verify_mobile_number_success];
    };
    
    self.context[@"objc_on_verify_mobile_number_error"] = ^() {
        [weakSelf on_verify_mobile_number_error];
    };
    
    self.context[@"objc_on_change_mobile_number_success"] = ^() {
        [weakSelf on_change_mobile_number_success];
    };
    
    self.context[@"objc_on_resend_verification_email_success"] = ^() {
        [weakSelf on_resend_verification_email_success];
    };
    
    self.context[@"objc_show_email_authorization_alert"] = ^() {
        [weakSelf show_email_authorization_alert];
    };
    
    self.context[@"objc_on_fetch_needs_two_factor_code"] = ^() {
        [weakSelf on_fetch_needs_two_factor_code];
    };
    
    self.context[@"objc_wrong_two_factor_code"] = ^(NSString *error) {
        [weakSelf wrong_two_factor_code:error];
    };
    
#pragma mark Contacts
    
    self.context[@"objc_on_create_invitation_success"] = ^(JSValue *invitation) {
        [weakSelf on_create_invitation_success:invitation];
    };
    
    self.context[@"objc_on_create_invitation_error"] = ^(JSValue *error) {
        [weakSelf on_create_invitation_error:error];
    };
    
    self.context[@"objc_on_read_invitation_success"] = ^(JSValue *invitation, NSString *identifier) {
        [weakSelf on_read_invitation_success:invitation identifier:identifier];
    };
    
    self.context[@"objc_on_complete_relation_success"] = ^() {
        [weakSelf on_complete_relation_success];
    };
    
    self.context[@"objc_on_complete_relation_error"] = ^() {
        [weakSelf on_complete_relation_error];
    };
    
    self.context[@"objc_on_accept_relation_success"] = ^(NSString *name, NSString *invitation) {
        [weakSelf on_accept_relation_success:invitation name:name];
    };
    
    self.context[@"objc_on_accept_relation_error"] = ^(NSString *name) {
        [weakSelf on_accept_relation_error:name];
    };
    
    self.context[@"objc_on_fetch_xpub_success"] = ^(NSString *xpub) {
        [weakSelf on_fetch_xpub_success:xpub];
    };
    
    self.context[@"objc_on_get_messages_success"] = ^(JSValue *messages, JSValue *firstLoad) {
        [weakSelf on_get_messages_success:messages firstLoad:firstLoad];
    };
    
    self.context[@"objc_on_get_messages_error"] = ^(JSValue *error) {
        [weakSelf on_get_messages_error:[error toString]];
    };
    
    self.context[@"objc_on_send_payment_request_success"] = ^(JSValue *info, JSValue *intendedAmount, JSValue *userId, JSValue *requestId) {
        [weakSelf on_send_payment_request_success:info amount:intendedAmount identifier:userId requestId:requestId];
    };
    
    self.context[@"objc_on_send_payment_request_error"] = ^(JSValue *error) {
        [weakSelf on_send_payment_request_error:error];
    };
    
    self.context[@"objc_on_request_payment_request_success"] = ^(JSValue *info, JSValue *userId) {
        [weakSelf on_request_payment_request_success:info identifier:userId];
    };
    
    self.context[@"objc_on_request_payment_request_error"] = ^(JSValue *error) {
        [weakSelf on_request_payment_request_error:error];
    };
    
    self.context[@"objc_on_send_payment_request_response_success"] = ^(JSValue *info) {
        [weakSelf on_send_payment_request_response_success:info];
    };
    
    self.context[@"objc_on_send_payment_request_response_error"] = ^(JSValue *error) {
        [weakSelf on_send_payment_request_response_error:error];
    };
    
    self.context[@"objc_on_change_contact_name_success"] = ^(JSValue *info) {
        [weakSelf on_change_contact_name_success:info];
    };
    
    self.context[@"objc_on_delete_contact_success"] = ^(JSValue *info) {
        [weakSelf on_delete_contact_success:info];
    };
    
    self.context[@"objc_on_send_cancellation_success"] = ^() {
        [weakSelf on_send_cancellation_success];
    };
    
    self.context[@"objc_on_send_cancellation_error"] = ^(JSValue *info) {
        [weakSelf on_send_cancellation_error:info];
    };
    
    self.context[@"objc_on_send_declination_success"] = ^() {
        [weakSelf on_send_declination_success];
    };

    self.context[@"objc_on_send_declination_error"] = ^(JSValue *info) {
        [weakSelf on_send_declination_error:info];
    };

    self.context[@"objc_on_delete_contact_after_storing_info_success"] = ^(JSValue *info) {
        [weakSelf on_delete_contact_after_storing_info_success:info];
    };
    
#pragma mark Ethereum
    
    self.context[@"objc_on_fetch_eth_history_success"] = ^() {
        [weakSelf on_fetch_eth_history_success];
    };
    
    self.context[@"objc_on_create_eth_account_for_exchange_success"] = ^() {
        [weakSelf on_create_eth_account_for_exchange_success];
    };
    
    self.context[@"objc_on_fetch_eth_history_error"] = ^(JSValue *error) {
        [weakSelf on_fetch_eth_history_error:[error toString]];
    };
    
    self.context[@"objc_update_eth_payment"] = ^(JSValue *etherPayment) {
        [weakSelf on_update_eth_payment:[etherPayment toDictionary]];
    };
    
    self.context[@"objc_on_fetch_eth_exchange_rate_success"] = ^(JSValue *rate, JSValue *code) {
        [weakSelf on_fetch_eth_exchange_rate_success:rate code:code];
    };
    
    self.context[@"objc_eth_socket_send"] = ^(JSValue *message) {
        [weakSelf eth_socket_send:[message toString]];
    };
    
    self.context[@"objc_on_send_ether_payment_success"] = ^() {
        [weakSelf on_send_ether_payment_success];
    };
    
    self.context[@"objc_on_send_ether_payment_error"] = ^(JSValue *error) {
        [weakSelf on_send_ether_payment_error:error];
    };
    
    self.context[@"objc_did_get_ether_address_with_second_password"] = ^() {
        [weakSelf did_get_ether_address_with_second_password];
    };
    
#pragma mark Exchange
    
    self.context[@"objc_on_get_exchange_trades_success"] = ^(NSArray *trades) {
        [weakSelf on_get_exchange_trades_success:trades];
    };
    
    self.context[@"objc_on_get_exchange_rate_success"] = ^(JSValue *limit, JSValue *minimum, JSValue *minerFee, JSValue *maxLimit, JSValue *pair, JSValue *rate, JSValue *ethHardLimit) {
        [weakSelf on_get_exchange_rate_success:@{DICTIONARY_KEY_LIMIT : [limit toString], DICTIONARY_KEY_MINIMUM : [minimum toString], DICTIONARY_KEY_MINER_FEE : [minerFee toString], DICTIONARY_KEY_MAX_LIMIT : [maxLimit toString], DICTIONARY_KEY_RATE : [rate toString], DICTIONARY_KEY_ETH_HARD_LIMIT_RATE : [ethHardLimit toString]}];
    };
    
    self.context[@"objc_on_build_exchange_trade_success"] = ^(JSValue *from, JSValue *depositAmount, JSValue *fee, JSValue *rate, JSValue *minerFee, JSValue *withdrawalAmount, JSValue *expiration) {
        [weakSelf on_build_exchange_trade_success_from:[from toString] depositAmount:[depositAmount toString] fee:[fee toNumber] rate:[rate toString] minerFee:[minerFee toString] withdrawalAmount:[withdrawalAmount toString] expiration:[expiration toDate]];
    };
    
    self.context[@"objc_on_get_available_btc_balance_success"] = ^(JSValue *result) {
        [weakSelf on_get_available_btc_balance_success:[result toDictionary]];
    };
    
    self.context[@"objc_on_get_available_btc_balance_error"] = ^(JSValue *result) {
        [weakSelf on_get_available_balance_error:[result toString] symbol:CURRENCY_SYMBOL_BTC];
    };
    
    self.context[@"objc_on_get_available_eth_balance_success"] = ^(JSValue *amount, JSValue *fee) {
        NSDictionary *dict = @{DICTIONARY_KEY_AMOUNT : [amount toNumber], DICTIONARY_KEY_FEE : [fee toNumber]};
        [weakSelf on_get_available_eth_balance_success:dict];
    };
    
    self.context[@"objc_on_get_available_eth_balance_error"] = ^(JSValue *result) {
        [weakSelf on_get_available_balance_error:[result toString] symbol:CURRENCY_SYMBOL_ETH];
    };
    
    self.context[@"objc_on_shift_payment_success"] = ^(JSValue *result) {
        [weakSelf on_shift_payment_success:[result toDictionary]];
    };
    
    self.context[@"objc_on_shift_payment_error"] = ^(JSValue *error) {
        [weakSelf on_shift_payment_error:[error toDictionary]];
    };
    
    [self.context evaluateScript:[self getJSSource]];
    
    self.context[@"XMLHttpRequest"] = [ModuleXMLHttpRequest class];
    self.context[@"Bitcoin"][@"HDNode"] = [HDNode class];
    self.context[@"HDNode"] = [HDNode class];
    
    [self login];
}

- (NSMutableArray *)pendingEthSocketMessages
{
    if (!_pendingEthSocketMessages) _pendingEthSocketMessages = [NSMutableArray new];
    return _pendingEthSocketMessages;
}

- (void)setupEthSocket
{
    _ethSocket = [[SRWebSocket alloc] initWithURLRequest:[self getWebSocketRequest:AssetTypeEther]];
    _ethSocket.delegate = self;
}

- (void)setupWebSocket
{
    self.webSocket = [[SRWebSocket alloc] initWithURLRequest:[self getWebSocketRequest:AssetTypeBitcoin]];
    self.webSocket.delegate = self;
    
    [self.webSocketTimer invalidate];
    self.webSocketTimer = nil;
    self.webSocketTimer = [NSTimer scheduledTimerWithTimeInterval:15.0
                                     target:self
                                   selector:@selector(pingWebSocket)
                                   userInfo:nil
                                    repeats:YES];
    
    [self.webSocket open];
}

- (NSURLRequest *)getWebSocketRequest:(AssetType)assetType
{
    NSString *websocketURL;
    
    if (assetType == AssetTypeBitcoin) {
        websocketURL = URL_WEBSOCKET;
    } else if (assetType == AssetTypeEther) {
        websocketURL = URL_WEBSOCKET_ETH;
    }
    
    NSMutableURLRequest *webSocketRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:URL_WEBSOCKET]];
    [webSocketRequest addValue:URL_SERVER forHTTPHeaderField:@"Origin"];
    
#ifdef ENABLE_CERTIFICATE_PINNING
    if ([[NSUserDefaults standardUserDefaults] boolForKey:USER_DEFAULTS_KEY_DEBUG_ENABLE_CERTIFICATE_PINNING]) {
        NSString *cerPath = [[NSBundle mainBundle] pathForResource:[app.certificatePinner getCertificateName] ofType:@"der"];
        NSData *certData = [[NSData alloc] initWithContentsOfFile:cerPath];
        CFDataRef certDataRef = (__bridge CFDataRef)certData;
        SecCertificateRef certRef = SecCertificateCreateWithData(NULL, certDataRef);
        id certificate = (__bridge id)certRef;
        
        [webSocketRequest setSR_SSLPinnedCertificates:@[certificate]];
        [webSocketRequest setSR_comparesPublicKeys:YES];
        
        CFRelease(certRef);
    }
#endif
    
    return webSocketRequest;
}

- (void)pingWebSocket
{
    if (self.webSocket.readyState == 1) {
        NSError *error;
        [self.webSocket sendPing:[@"{ op: \"ping\" }" dataUsingEncoding:NSUTF8StringEncoding] error:&error];
        if (error) DLog(@"Error sending ping: %@", [error localizedDescription]);
    } else {
        DLog(@"reconnecting websocket");
        [self setupWebSocket];
    }
}

- (void)subscribeToXPub:(NSString *)xPub
{
    if (self.webSocket && self.webSocket.readyState == 1) {
        NSError *error;
        [self.webSocket sendString:[NSString stringWithFormat:@"{\"op\":\"xpub_sub\",\"xpub\":\"%@\"}", xPub] error:&error];
        if (error) DLog(@"Error subscribing to xpub: %@", [error localizedDescription]);
    } else {
        [self setupWebSocket];
    }
}

- (void)subscribeToAddress:(NSString *)address
{    
    if (self.webSocket && self.webSocket.readyState == 1) {
        NSError *error;
        [self.webSocket sendString:[NSString stringWithFormat:@"{\"op\":\"addr_sub\",\"addr\":\"%@\"}", address] error:&error];
        if (error) DLog(@"Error subscribing to address: %@", [error localizedDescription]);
    } else {
        [self setupWebSocket];
    }
}

- (void)subscribeToSwipeAddress:(NSString *)address
{    
    self.swipeAddressToSubscribe = address;

    [self subscribeToAddress:address];
}

- (void)apiGetPINValue:(NSString*)key pin:(NSString*)pin
{
    [self loadJS];
    
    [self useDebugSettingsIfSet];
    
    [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.apiGetPINValue(\"%@\", \"%@\")", key, pin]];
}

- (void)loadWalletWithGuid:(NSString*)_guid sharedKey:(NSString*)_sharedKey password:(NSString*)_password
{
    // DLog(@"guid: %@, password: %@", _guid, _password);
    self.guid = _guid;
    // Shared Key can be empty
    self.sharedKey = _sharedKey;
    self.password = _password;
    
    // Load the JS. Proceed in the webViewDidFinishLoad callback
    [self loadJS];
}

- (void)loadBlankWallet
{
    [self loadWalletWithGuid:nil sharedKey:nil password:nil];
}

- (void)login
{
    [self useDebugSettingsIfSet];
    
    if ([delegate respondsToSelector:@selector(walletJSReady)]) {
        [delegate walletJSReady];
    } else {
        DLog(@"Error: delegate of class %@ does not respond to selector walletJSReady!", [delegate class]);
    }
    
    if ([delegate respondsToSelector:@selector(walletDidLoad)]) {
        [delegate walletDidLoad];
    } else {
        DLog(@"Error: delegate of class %@ does not respond to selector walletDidLoad!", [delegate class]);
    }
    
    if (self.guid && self.password) {
        DLog(@"Fetch Wallet");
        
        NSString *escapedSharedKey = self.sharedKey == nil ? @"" : [self.sharedKey escapeStringForJS];
        NSString *escapedSessionToken = self.sessionToken == nil ? @"" : [self.sessionToken escapeStringForJS];
        NSString *escapedTwoFactorInput = self.twoFactorInput == nil ? @"" : [self.twoFactorInput escapeStringForJS];
        
        [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.login(\"%@\", \"%@\", false, \"%@\", \"%@\", \"%@\")", [self.guid escapeStringForJS], escapedSharedKey, [self.password escapeStringForJS], escapedSessionToken, escapedTwoFactorInput]];
    }
}

- (void)resetSyncStatus
{
    // Some changes to the wallet requiring syncing afterwards need only specific updates to the UI; reloading the entire Receive screen, for example, is not necessary when setting the default account. Unfortunately information about the specific function that triggers backup is lost by the time multiaddress is called.
    
    self.isSettingDefaultAccount = NO;
}

- (void)setupBackupTransferAll:(id)transferAllController
{
    if ([delegate respondsToSelector:@selector(setupBackupTransferAll:)]) {
        [delegate setupBackupTransferAll:transferAllController];
    } else {
        DLog(@"Error: delegate of class %@ does not respond to selector setupBackupTransferAll!", [delegate class]);
    }
}

- (NSDecimalNumber *)btcDecimalBalance
{
    return [NSNumberFormatter formatSatoshiInLocalCurrency:[app.wallet getTotalActiveBalance]];
}

- (NSDecimalNumber *)ethDecimalBalance
{
    NSLocale *currentLocale = app.localCurrencyFormatter.locale;
    app.localCurrencyFormatter.locale = [NSLocale localeWithLocaleIdentifier:LOCALE_IDENTIFIER_EN_US];
    
    NSString *fiatString = [NSNumberFormatter formatEthToFiat:[app.wallet getEthBalance] exchangeRate:app.tabControllerManager.latestEthExchangeRate];
    NSString *separator = [app.localCurrencyFormatter.locale objectForKey:NSLocaleGroupingSeparator];
    fiatString = [fiatString stringByReplacingOccurrencesOfString:separator withString:@""];
    NSDecimalNumber *balance = [NSDecimalNumber decimalNumberWithString:fiatString ? : @"0"];
    app.localCurrencyFormatter.locale = currentLocale;
    return balance;
}

# pragma mark - Socket Delegate

- (void)webSocketDidOpen:(SRWebSocket *)webSocket
{
    if (webSocket == self.ethSocket) {
        DLog(@"eth websocket opened");
        for (NSString *message in [self.pendingEthSocketMessages reverseObjectEnumerator]) {
            DLog(@"Sending queued eth socket message %@", message);
            [self sendEthSocketMessage:message];
        }
        [self.pendingEthSocketMessages removeAllObjects];
    } else {
        DLog(@"websocket opened");
        NSString *message = self.swipeAddressToSubscribe ? [NSString stringWithFormat:@"{\"op\":\"addr_sub\",\"addr\":\"%@\"}", self.swipeAddressToSubscribe] : [[self.context evaluateScript:@"MyWallet.getSocketOnOpenMessage()"] toString];
        
        NSError *error;
        [webSocket sendString:message error:&error];
        if (error) DLog(@"Error subscribing to address: %@", [error localizedDescription]);
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    DLog(@"%@ failed with error: %@", webSocket == self.ethSocket ? @"eth socket" : @"web socket", [error localizedDescription]);
    if ([error.localizedDescription isEqualToString:WEBSOCKET_ERROR_INVALID_SERVER_CERTIFICATE]) {
        [app failedToValidateCertificate:[error localizedDescription]];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
    if (webSocket == self.ethSocket) {
        DLog(@"eth websocket closed: code %li, reason: %@", code, reason);
    } else if (webSocket == self.webSocket) {
        if (code == WEBSOCKET_CODE_BACKGROUNDED_APP || code == WEBSOCKET_CODE_LOGGED_OUT || code == WEBSOCKET_CODE_RECEIVED_TO_SWIPE_ADDRESS) {
            // Socket will reopen when app becomes active and after decryption
            return;
        }
        
        DLog(@"websocket closed: code %li, reason: %@", code, reason);
        if (self.webSocket.readyState != 1 && [[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
            DLog(@"reconnecting websocket");
            [self setupWebSocket];
        }
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessageWithString:(NSString *)string
{
    if (webSocket == self.ethSocket) {
        DLog(@"received eth socket message string");
        [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.didReceiveEthSocketMessage(\"%@\")", [string escapeStringForJS]]];
    } else if (webSocket == self.webSocket) {
        DLog(@"received websocket message string");
        [self.context evaluateScript:[NSString stringWithFormat:@"MyWallet.getSocketOnMessage(\"%@\", { checksum: null })", [string escapeStringForJS]]];
        
        if (self.swipeAddressToSubscribe) {
            NSDictionary *message = [string getJSONObject];
            NSString *hash = message[@"x"][DICTIONARY_KEY_HASH];
            NSURL *URL = [NSURL URLWithString:[URL_SERVER stringByAppendingString:[NSString stringWithFormat:TRANSACTION_RESULT_URL_SUFFIX_HASH_ARGUMENT_ADDRESS_ARGUMENT, hash, self.swipeAddressToSubscribe]]];
            NSURLRequest *request = [NSURLRequest requestWithURL:URL];
            
            NSURLSessionDataTask *task = [[SessionManager sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                
                if (error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // TODO: add alert for error here
                    });
                    return;
                }
                
                uint64_t amountReceived = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] longLongValue];
                if (amountReceived > 0) {
                    if ([delegate respondsToSelector:@selector(paymentReceivedOnPINScreen:)]) {
                        if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
                            [delegate paymentReceivedOnPINScreen:[NSNumberFormatter formatMoney:amountReceived localCurrency:NO]];
                        }
                    } else {
                        DLog(@"Error: delegate of class %@ does not respond to selector paymentReceivedOnPINScreen:!", [delegate class]);
                    }
                }
            }];
            
            [task resume];
            
            self.swipeAddressToSubscribe = nil;
            
            [self.webSocket closeWithCode:WEBSOCKET_CODE_RECEIVED_TO_SWIPE_ADDRESS reason:WEBSOCKET_CLOSE_REASON_RECEIVED_TO_SWIPE_ADDRESS];
        }
    }
}

# pragma mark - Calls from Obj-C to JS

- (BOOL)isInitialized
{
    // Initialized when the webView is loaded and the wallet is initialized (decrypted and in-memory wallet built)
    BOOL isInitialized = [[self.context evaluateScript:@"MyWallet.getIsInitialized()"] toBool];
    if (!isInitialized) {
        DLog(@"Warning: Wallet not initialized!");
    }
    
    return isInitialized;
}

- (NSString *)getAPICode
{
    return [[self.context evaluateScript:@"MyWalletPhone.getAPICode()"] toString];
}

- (BOOL)hasEncryptedWalletData
{
    if ([self isInitialized])
    return [[self.context evaluateScript:@"MyWalletPhone.hasEncryptedWalletData()"] toBool];
    else
    return NO;
}

- (void)pinServerPutKeyOnPinServerServer:(NSString*)key value:(NSString*)value pin:(NSString*)pin
{
    if (![self isInitialized]) {
        return;
    }
    [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.pinServerPutKeyOnPinServerServer(\"%@\", \"%@\", \"%@\")", key, value, pin]];
}

- (NSString*)encrypt:(NSString*)data password:(NSString*)_password pbkdf2_iterations:(int)pbkdf2_iterations
{
    return [[self.context evaluateScript:[NSString stringWithFormat:@"WalletCrypto.encrypt(\"%@\", \"%@\", %d)", [data escapeStringForJS], [_password escapeStringForJS], pbkdf2_iterations]] toString];
}

- (NSString*)decrypt:(NSString*)data password:(NSString*)_password pbkdf2_iterations:(int)pbkdf2_iterations
{
    return [[self.context evaluateScript:[NSString stringWithFormat:@"WalletCrypto.decryptPasswordWithProcessedPin(\"%@\", \"%@\", %d)", [data escapeStringForJS], [_password escapeStringForJS], pbkdf2_iterations]] toString];
}

- (float)getStrengthForPassword:(NSString *)passwordString
{
    return [[self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.getPasswordStrength(\"%@\")", [passwordString escapeStringForJS]]] toDouble];
}

- (void)getHistory
{
    if ([self isInitialized])
    [self.context evaluateScript:@"MyWalletPhone.get_history()"];
}

- (void)getHistoryWithoutBusyView
{
    if ([self isInitialized])
        [self.context evaluateScript:@"MyWalletPhone.get_history(true)"];
}

- (void)getWalletAndHistory
{
    if ([self isInitialized])
    [self.context evaluateScript:@"MyWalletPhone.get_wallet_and_history()"];
}

- (void)getHistoryIfNoTransactionMessage
{
    if (!self.didReceiveMessageForLastTransaction) {
        DLog(@"Did not receive tx message for %f seconds - getting history", DELAY_GET_HISTORY_BACKUP);
        [self getHistoryWithoutBusyView];
    }
}

- (void)fetchMoreTransactions
{
    if ([self isInitialized]) {
        self.isFetchingTransactions = YES;
        [self.context evaluateScript:@"MyWalletPhone.fetchMoreTransactions()"];
    }
}

- (int)getAllTransactionsCount
{
    if (![self isInitialized]) {
        return 0;
    }
    
    return [[[self.context evaluateScript:@"MyWalletPhone.getAllTransactionsCount()"] toNumber] intValue];
}

- (void)getAllCurrencySymbols
{
    [self.context evaluateScript:@"JSON.stringify(MyWalletPhone.getAllCurrencySymbols())"];
}

- (void)changeLocalCurrency:(NSString *)currencyCode
{
    if (![self isInitialized]) {
        return;
    }
    
    [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.changeLocalCurrency(\"%@\")", [currencyCode escapeStringForJS]]];
}

- (void)changeBtcCurrency:(NSString *)btcCode
{
    if (![self isInitialized]) {
        return;
    }
    
    [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.changeBtcCurrency(\"%@\")", [btcCode escapeStringForJS]]];
}

- (void)getAccountInfo
{
    if (![self isInitialized]) {
        return;
    }
    
    [self.context evaluateScript:@"JSON.stringify(MyWalletPhone.getAccountInfo())"];
}

- (NSString *)getEmail
{
    if (![self isInitialized]) {
        return nil;
    }
    
    return [[self.context evaluateScript:@"MyWalletPhone.getEmail()"] toString];
}

- (NSString *)getSMSNumber
{
    if (![self isInitialized]) {
        return nil;
    }
    
    JSValue *smsNumber = [self.context evaluateScript:@"MyWalletPhone.getSMSNumber()"];
    
    if ([smsNumber isUndefined]) return @"";
    
    return [smsNumber toString];
}

- (BOOL)getSMSVerifiedStatus
{
    if (![self isInitialized]) {
        return NO;
    }
    
    return [[self.context evaluateScript:@"MyWalletPhone.getSMSVerifiedStatus()"] toBool];
}

- (NSDictionary *)getFiatCurrencies
{
    if (![self isInitialized]) {
        return nil;
    }
    
    return [CurrencySymbol currencyNames];
}

- (NSDictionary *)getBtcCurrencies
{
    if (![self isInitialized]) {
        return nil;
    }
    
    return self.accountInfo[DICTIONARY_KEY_ACCOUNT_SETTINGS_BTC_CURRENCIES];
}

- (int)getTwoStepType
{
    if (![self isInitialized]) {
        return -1;
    }
    
    return [self.accountInfo[DICTIONARY_KEY_ACCOUNT_SETTINGS_TWO_STEP_TYPE] intValue];
}

- (BOOL)getEmailVerifiedStatus
{
    if (![self isInitialized]) {
        return NO;
    }
    
    return [[self.context evaluateScript:@"MyWalletPhone.getEmailVerifiedStatus()"] toBool];
}

- (BOOL)getTorBlockingStatus
{
    if (![self isInitialized]) {
        return NO;
    }
    
    return [self.accountInfo[DICTIONARY_KEY_ACCOUNT_SETTINGS_TOR_BLOCKING] boolValue];
}

- (void)changeEmail:(NSString *)newEmail
{
    if (![self isInitialized]) {
        return;
    }
    
    [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.changeEmail(\"%@\")", [newEmail escapeStringForJS]]];
}

- (void)resendVerificationEmail:(NSString *)email
{
    if (![self isInitialized]) {
        return;
    }
    
    [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.resendEmailConfirmation(\"%@\")", [email escapeStringForJS]]];
}

- (void)changeMobileNumber:(NSString *)newMobileNumber
{
    if (![self isInitialized]) {
        return;
    }
    
    [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.changeMobileNumber(\"%@\")", [newMobileNumber escapeStringForJS]]];
}

- (void)verifyMobileNumber:(NSString *)code
{
    if (![self isInitialized]) {
        return;
    }
    
    [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.verifyMobile(\"%@\")", [code escapeStringForJS]]];
}

- (void)enableTwoStepVerificationForSMS
{
    if (![self isInitialized]) {
        return;
    }
    
    [self.context evaluateScript:@"MyWalletPhone.setTwoFactorSMS()"];
}

- (void)disableTwoStepVerification
{
    if (![self isInitialized]) {
        return;
    }
    
    [self.context evaluateScript:@"MyWalletPhone.unsetTwoFactor()"];
}

- (void)changePassword:(NSString *)changedPassword
{
    if (![self isInitialized]) {
        return;
    }
    
    [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.changePassword(\"%@\")", [changedPassword escapeStringForJS]]];
}

- (BOOL)isCorrectPassword:(NSString *)inputedPassword
{
    if (![self isInitialized]) {
        return NO;
    }
    
    return [[self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.isCorrectMainPassword(\"%@\")", [inputedPassword escapeStringForJS]]] toBool];
}

- (void)sendPaymentWithListener:(transactionProgressListeners*)listener secondPassword:(NSString *)secondPassword
{
    NSString * txProgressID = [[self.context evaluateScript:@"MyWalletPhone.createTxProgressId()"] toString];
    
    if (listener) {
        [self.transactionProgressListeners setObject:listener forKey:txProgressID];
    }
    
    if (secondPassword) {
        [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.quickSend(\"%@\", true, \"%@\")", [txProgressID escapeStringForJS], [secondPassword escapeStringForJS]]];
    } else {
        [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.quickSend(\"%@\", true)", [txProgressID escapeStringForJS]]];
    }
}

- (void)transferFundsBackupWithListener:(transactionProgressListeners*)listener secondPassword:(NSString *)secondPassword
{
    NSString * txProgressID = [[self.context evaluateScript:@"MyWalletPhone.createTxProgressId()"] toString];
    
    if (listener) {
        [self.transactionProgressListeners setObject:listener forKey:txProgressID];
    }
    
    if (secondPassword) {
        [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.quickSend(\"%@\", false, \"%@\")", [txProgressID escapeStringForJS], [secondPassword escapeStringForJS]]];
    } else {
        [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.quickSend(\"%@\", false)", [txProgressID escapeStringForJS]]];
    }
}

- (uint64_t)parseBitcoinValueFromTextField:(UITextField *)textField
{
    return [self parseBitcoinValueFromString:textField.text];
}

- (uint64_t)parseBitcoinValueFromString:(NSString *)inputString
{
    NSString *requestedAmountString = [NSNumberFormatter convertedDecimalString:inputString];

    return [[[self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.precisionToSatoshiBN(\"%@\", %lld).toString()", [requestedAmountString escapeStringForJS], app.latestResponse.symbol_btc.conversion]] toNumber] longLongValue];
}

// Make a request to blockchain.info to get the session id SID in a cookie. This cookie is around for new instances of UIWebView and will be used to let the server know the user is trying to gain access from a new device. The device is recognized based on the SID.
- (void)loadWalletLogin
{
    if (!self.sessionToken) {
        [self getSessionToken];
    }
}

- (void)parsePairingCode:(NSString*)code
{
    [self useDebugSettingsIfSet];
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:USER_DEFAULTS_KEY_HAS_SEEN_ALL_CARDS];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:USER_DEFAULTS_KEY_SHOULD_HIDE_ALL_CARDS];
    
    [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.parsePairingCode(\"%@\");", [code escapeStringForJS]]];
}

// Pairing code JS callbacks

- (void)didParsePairingCode:(NSDictionary *)dict
{
    DLog(@"didParsePairingCode:");
    
    if ([delegate respondsToSelector:@selector(didParsePairingCode:)]) {
        [delegate didParsePairingCode:dict];
    } else {
        DLog(@"Error: delegate of class %@ does not respond to selector didParsePairingCode:!", [delegate class]);
    }
}

- (void)errorParsingPairingCode:(NSString *)message
{
    DLog(@"errorParsingPairingCode:");
    
    if ([delegate respondsToSelector:@selector(errorParsingPairingCode:)]) {
        [delegate errorParsingPairingCode:message];
    } else {
        DLog(@"Error: delegate of class %@ does not respond to selector errorParsingPairingCode:!", [delegate class]);
    }
}

- (void)makePairingCode
{
    [self.context evaluateScript:@"MyWalletPhone.makePairingCode();"];
}

- (void)didMakePairingCode:(NSString *)pairingCode
{
    DLog(@"didMakePairingCode");

    if ([delegate respondsToSelector:@selector(didMakePairingCode:)]) {
        [delegate didMakePairingCode:pairingCode];
    } else {
        DLog(@"Error: delegate of class %@ does not respond to selector didMakePairingCode:!", [delegate class]);
    }
}

- (void)errorMakingPairingCode:(NSString *)message
{
    DLog(@"errorMakingPairingCode:");

    if ([delegate respondsToSelector:@selector(errorMakingPairingCode:)]) {
        [delegate errorMakingPairingCode:message];
    } else {
        DLog(@"Error: delegate of class %@ does not respond to selector errorMakingPairingCode:!", [delegate class]);
    }
}

- (void)newAccount:(NSString*)__password email:(NSString *)__email
{
    [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.newAccount(\"%@\", \"%@\", \"%@\")", [__password escapeStringForJS], [__email escapeStringForJS], BC_STRING_MY_BITCOIN_WALLET]];
}

- (BOOL)needsSecondPassword
{
    if (![self isInitialized]) {
        return false;
    }
    
    return [[self.context evaluateScript:[NSString stringWithFormat:@"MyWallet.wallet.isDoubleEncrypted"]] toBool];
}

- (BOOL)validateSecondPassword:(NSString*)secondPassword
{
    if (![self isInitialized]) {
        return FALSE;
    }
    
    return [[self.context evaluateScript:[NSString stringWithFormat:@"MyWallet.wallet.validateSecondPassword(\"%@\")", [secondPassword escapeStringForJS]]] toBool];
}

- (void)getFinalBalance
{
    if (![self isInitialized]) {
        return;
    }
    
    self.final_balance = [[[self.context evaluateScript:@"MyWallet.wallet.finalBalance"] toNumber] longLongValue];
}

- (void)getTotalSent
{
    if (![self isInitialized]) {
        return;
    }
    
    self.total_sent = [[[self.context evaluateScript:@"MyWallet.wallet.totalSent"] toNumber] longLongValue];
}

- (BOOL)isWatchOnlyLegacyAddress:(NSString*)address
{
    if (![self isInitialized]) {
        return false;
    }
    
    if ([self checkIfWalletHasAddress:address]) {
        return [[self.context evaluateScript:[NSString stringWithFormat:@"MyWallet.wallet.key(\"%@\").isWatchOnly", [address escapeStringForJS]]] toBool];
    } else {
        return NO;
    }
}

- (NSString*)labelForLegacyAddress:(NSString*)address
{
    if (![self isInitialized]) {
        return nil;
    }
    
    if ([self checkIfWalletHasAddress:address]) {
        return [[self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.labelForLegacyAddress(\"%@\")", [address escapeStringForJS]]] toString];
    } else {
        return nil;
    }
}

- (Boolean)isAddressArchived:(NSString *)address
{
    if (![self isInitialized] || !address) {
        return FALSE;
    }
    
    return [[self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.isArchived(\"%@\")", [address escapeStringForJS]]] toBool];
}

- (Boolean)isActiveAccountArchived:(int)account
{
    if (![self isInitialized]) {
        return FALSE;
    }
    
    return [[self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.isArchived(MyWalletPhone.getIndexOfActiveAccount(%d))", account]] toBool];
}

- (Boolean)isAccountArchived:(int)account
{
    if (![self isInitialized]) {
        return FALSE;
    }
    
    return [[self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.isArchived(%d)", account]] toBool];
}

- (BOOL)isBitcoinAddress:(NSString*)string
{
    if (![self isInitialized]) {
        return false;
    }
    
    return [[self.context evaluateScript:[NSString stringWithFormat:@"Helpers.isBitcoinAddress(\"%@\");", [string escapeStringForJS]]] toBool];
}

- (NSArray*)allLegacyAddresses
{
    if (![self isInitialized]) {
        return nil;
    }
    
    NSString * allAddressesJSON = [[self.context evaluateScript:@"JSON.stringify(MyWallet.wallet.addresses)"] toString];
    
    return [allAddressesJSON getJSONObject];
}

- (NSArray*)activeLegacyAddresses
{
    if (![self isInitialized]) {
        return nil;
    }
    
    NSString *activeAddressesJSON = [[self.context evaluateScript:@"JSON.stringify(MyWallet.wallet.activeAddresses)"] toString];
    
    return [activeAddressesJSON getJSONObject];
}

- (NSArray*)spendableActiveLegacyAddresses
{
    if (![self isInitialized]) {
        return nil;
    }
    
    NSString *spendableActiveAddressesJSON = [[self.context evaluateScript:@"JSON.stringify(MyWallet.wallet.spendableActiveAddresses)"] toString];
    
    return [spendableActiveAddressesJSON getJSONObject];
}

- (NSArray*)archivedLegacyAddresses
{
    if (![self isInitialized]) {
        return nil;
    }
    
    NSString *activeAddressesJSON = [[self.context evaluateScript:@"JSON.stringify(MyWalletPhone.getLegacyArchivedAddresses())"] toString];
    
    return [activeAddressesJSON getJSONObject];
}

- (void)setLabel:(NSString*)label forLegacyAddress:(NSString*)address
{
    if (![self isInitialized] || ![app checkInternetConnection]) {
        return;
    }
    
    self.isSyncing = YES;
    
    [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.setLabelForAddress(\"%@\", \"%@\")", [address escapeStringForJS], [label escapeStringForJS]]];
}

- (void)toggleArchiveLegacyAddress:(NSString*)address
{
    if (![self isInitialized] || ![app checkInternetConnection]) {
        return;
    }
    
    self.isSyncing = YES;
    
    [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.toggleArchived(\"%@\")", [address escapeStringForJS]]];
}

- (void)toggleArchiveAccount:(int)account
{
    if (![self isInitialized] || ![app checkInternetConnection]) {
        return;
    }
    
    self.isSyncing = YES;
    
    [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.toggleArchived(%d)", account]];
}

- (void)archiveTransferredAddresses:(NSArray *)transferredAddresses
{
    if (![self isInitialized]) {
        return;
    }
    
    [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.archiveTransferredAddresses(\"%@\")", [[transferredAddresses jsonString] escapeStringForJS]]];
}

- (uint64_t)getLegacyAddressBalance:(NSString*)address
{
    uint64_t errorBalance = 0;
    if (![self isInitialized]) {
        return errorBalance;
    }
    
    if ([self checkIfWalletHasAddress:address]) {
        return [[[self.context evaluateScript:[NSString stringWithFormat:@"MyWallet.wallet.key(\"%@\").balance", [address escapeStringForJS]]] toNumber] longLongValue];
    } else {
        DLog(@"Wallet error: Tried to get balance of address %@, which was not found in this wallet", address);
        return errorBalance;
    }
}

- (BOOL)addKey:(NSString*)privateKeyString
{
    if (![self isInitialized]) {
        return false;
    }
    
    return [[self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.addKey(\"%@\")", [privateKeyString escapeStringForJS]]] toBool];
}

- (BOOL)addKey:(NSString*)privateKeyString toWatchOnlyAddress:(NSString *)watchOnlyAddress
{
    if (![self isInitialized]) {
        return false;
    }
    
    return [[self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.addKeyToLegacyAddress(\"%@\", \"%@\")", [privateKeyString escapeStringForJS], [watchOnlyAddress escapeStringForJS]]] toBool];
}

- (void)sendFromWatchOnlyAddress:(NSString *)watchOnlyAddress privateKey:(NSString *)privateKeyString
{
    if (![self isInitialized]) {
        return;
    }
    
    [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.sendFromWatchOnlyAddressWithPrivateKey(\"%@\", \"%@\")", [privateKeyString escapeStringForJS], [watchOnlyAddress escapeStringForJS]]];
}

- (NSDictionary*)addressBook
{
    if (![self isInitialized]) {
        return [[NSDictionary alloc] init];
    }
    
    NSString * addressBookJSON = [[self.context evaluateScript:@"JSON.stringify(MyWallet.wallet.addressBook)"] toString];
    
    return [addressBookJSON getJSONObject];
}

- (void)addToAddressBook:(NSString*)address label:(NSString*)label
{
    if (![self isInitialized]) {
        return;
    }
    
    [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.addAddressBookEntry(\"%@\", \"%@\")", [address escapeStringForJS], [label escapeStringForJS]]];
}

- (NSString*)detectPrivateKeyFormat:(NSString*)privateKeyString
{
    if (![self isInitialized]) {
        return nil;
    }
    
    return [[self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.detectPrivateKeyFormat(\"%@\")", [privateKeyString escapeStringForJS]]] toString];
}

- (void)createNewBitcoinPayment
{
    if (![self isInitialized]) {
        return;
    }
    
    [self.context evaluateScript:@"MyWalletPhone.createNewBitcoinPayment()"];
}

- (void)changePaymentFromAccount:(int)fromInt isAdvanced:(BOOL)isAdvanced
{
    if (![self isInitialized]) {
        return;
    }
    
    [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.changePaymentFrom(%d, %d)", fromInt, isAdvanced]];
}

- (void)changePaymentFromAddress:(NSString *)fromString isAdvanced:(BOOL)isAdvanced
{
    if (![self isInitialized]) {
        return;
    }
    
    [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.changePaymentFrom(\"%@\", %d)", [fromString escapeStringForJS], isAdvanced]];
}

- (void)changePaymentToAccount:(int)toInt
{
    if (![self isInitialized]) {
        return;
    }
    
    [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.changePaymentTo(%d)", toInt]];
}

- (void)changePaymentToAddress:(NSString *)toString
{
    if (![self isInitialized]) {
        return;
    }
    
    [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.changePaymentTo(\"%@\")", [toString escapeStringForJS]]];
}

- (void)changePaymentAmount:(uint64_t)amount
{
    if (![self isInitialized]) {
        return;
    }
    
    [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.changePaymentAmount(%lld)", amount]];
}

- (void)getInfoForTransferAllFundsToAccount
{
    if (![self isInitialized]) {
        return;
    }
    
    [self.context evaluateScript:@"MyWalletPhone.getInfoForTransferAllFundsToAccount()"];
}

- (void)setupFirstTransferForAllFundsToAccount:(int)account address:(NSString *)address secondPassword:(NSString *)secondPassword useSendPayment:(BOOL)useSendPayment
{
    if (![self isInitialized]) {
        return;
    }
    
    [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.transferAllFundsToAccount(%d, true, \"%@\", \"%@\", %d)", account, [address escapeStringForJS], [secondPassword escapeStringForJS], useSendPayment]];
}

- (void)setupFollowingTransferForAllFundsToAccount:(int)account address:(NSString *)address secondPassword:(NSString *)secondPassword useSendPayment:(BOOL)useSendPayment
{
    if (![self isInitialized]) {
        return;
    }
    
    [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.transferAllFundsToAccount(%d, false, \"%@\", \"%@\", %d)", account, [address escapeStringForJS], [secondPassword escapeStringForJS], useSendPayment]];
}

- (void)transferFundsToDefaultAccountFromAddress:(NSString *)address
{
    if (![self isInitialized]) {
        return;
    }
    
    [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.transferFundsToDefaultAccountFromAddress(\"%@\")", [address escapeStringForJS]]];
}

- (void)changeLastUsedReceiveIndexOfDefaultAccount
{
    if (![self isInitialized]) {
        return;
    }
    
    [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.changeLastUsedReceiveIndexOfDefaultAccount()"]];
}

- (void)sweepPaymentRegular
{
    if (![self isInitialized]) {
        return;
    }
    
    [self.context evaluateScript:@"MyWalletPhone.sweepPaymentRegular()"];
}

- (void)sweepPaymentRegularThenConfirm
{
    if (![self isInitialized]) {
        return;
    }
    
    [self.context evaluateScript:@"MyWalletPhone.sweepPaymentRegularThenConfirm()"];
}

- (void)sweepPaymentAdvanced
{
    if (![self isInitialized]) {
        return;
    }
    
    [self.context evaluateScript:@"MyWalletPhone.sweepPaymentAdvanced()"];
}

- (void)sweepPaymentAdvancedThenConfirm:(uint64_t)fee
{
    if (![self isInitialized]) {
        return;
    }
    
    [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.sweepPaymentAdvancedThenConfirm(%lld)", fee]];
}

- (void)sweepPaymentThenConfirm:(BOOL)willConfirm isAdvanced:(BOOL)isAdvanced
{
    if (![self isInitialized]) {
        return;
    }
    
    [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.sweepPaymentThenConfirm(%d, %d)", willConfirm, isAdvanced]];
}

- (void)checkIfOverspending
{
    if (![self isInitialized]) {
        return;
    }
    
    [self.context evaluateScript:@"MyWalletPhone.checkIfUserIsOverSpending()"];
}

- (void)changeSatoshiPerByte:(uint64_t)satoshiPerByte updateType:(FeeUpdateType)updateType
{
    if (![self isInitialized]) {
        return;
    }
    
    [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.changeSatoshiPerByte(%lld, %ld)", satoshiPerByte, (long)updateType]];
}

- (void)getTransactionFeeWithUpdateType:(FeeUpdateType)updateType
{
    if (![self isInitialized]) {
        return;
    }
    
    [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.getTransactionFeeWithUpdateType(%ld)", (long)updateType]];
}

- (void)updateTotalAvailableAndFinalFee
{
    if (![self isInitialized]) {
        return;
    }
    
    [self.context evaluateScript:@"MyWalletPhone.updateTotalAvailableAndFinalFee()"];
}

- (void)getSurgeStatus
{
    if (![self isInitialized]) {
        return;
    }
    
    [self.context evaluateScript:@"MyWalletPhone.getSurgeStatus()"];
}

- (uint64_t)dust
{
    if (![self isInitialized]) {
        return 0;
    }
    
    return [[[self.context evaluateScript:@"MyWalletPhone.dust()"] toNumber] longLongValue];
}

- (void)generateNewKey
{
    if (![self isInitialized]) {
        return;
    }
    
    [self.context evaluateScript:@"MyWalletPhone.generateNewAddress()"];
}

- (BOOL)checkIfWalletHasAddress:(NSString *)address
{
    if (![self isInitialized]) {
        return NO;
    }
    
    return [[self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.checkIfWalletHasAddress(\"%@\")", [address escapeStringForJS]] ] toBool];
}

- (void)recoverWithEmail:(NSString *)email password:(NSString *)recoveryPassword passphrase:(NSString *)passphrase
{
    [self useDebugSettingsIfSet];
    
    self.emptyAccountIndex = 0;
    self.recoveredAccountIndex = 0;
    [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.recoverWithPassphrase(\"%@\",\"%@\",\"%@\")", [email escapeStringForJS], [recoveryPassword escapeStringForJS], [passphrase escapeStringForJS]]];
}

- (void)resendTwoFactorSMS
{
    [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.resendTwoFactorSms(\"%@\", \"%@\")", [self.guid escapeStringForJS], [self.sessionToken escapeStringForJS]]];
}

- (NSString *)get2FAType
{
    return [[self.context evaluateScript:@"MyWalletPhone.get2FAType()"] toString];
}

- (void)enableEmailNotifications
{
    if (![self isInitialized]) {
        return;
    }
    
    [self.context evaluateScript:@"MyWalletPhone.enableEmailNotifications()"];
}

- (void)disableEmailNotifications
{
    if (![self isInitialized]) {
        return;
    }
    
    [self.context evaluateScript:@"MyWalletPhone.disableEmailNotifications()"];
}

- (void)enableSMSNotifications
{
    if (![self isInitialized]) {
        return;
    }
    
    [self.context evaluateScript:@"MyWalletPhone.enableSMSNotifications()"];
}

- (void)disableSMSNotifications
{
    if (![self isInitialized]) {
        return;
    }
    
    [self.context evaluateScript:@"MyWalletPhone.disableSMSNotifications()"];
}

- (void)updateServerURL:(NSString *)newURL
{
    [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.updateServerURL(\"%@\")", [newURL escapeStringForJS]]];
}

- (void)updateWebSocketURL:(NSString *)newURL
{
    [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.updateWebsocketURL(\"%@\")", [newURL escapeStringForJS]]];
}

- (void)updateAPIURL:(NSString *)newURL
{
    [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.updateAPIURL(\"%@\")", [newURL escapeStringForJS]]];
}

- (NSDictionary *)filteredWalletJSON
{
    if (![self isInitialized]) {
        return nil;
    }
    
    NSString * filteredWalletJSON = [[self.context evaluateScript:@"JSON.stringify(MyWalletPhone.filteredWalletJSON())"] toString];
    
    return [filteredWalletJSON getJSONObject];
}

- (NSString *)getXpubForAccount:(int)accountIndex
{
    if (![self isInitialized]) {
        return nil;
    }
    
    return [[self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.getXpubForAccount(%d)", accountIndex]] toString];
}

- (BOOL)isAccountNameValid:(NSString *)name
{
    if (![self isInitialized]) {
        return NO;
    }
    
    return [[self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.isAccountNameValid(\"%@\")", [name escapeStringForJS]]] toBool];
}

- (BOOL)isAddressAvailable:(NSString *)address
{
    if (![self isInitialized]) {
        return NO;
    }
    
    return [[self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.isAddressAvailable(\"%@\")", [address escapeStringForJS]]] toBool];
}

- (BOOL)isAccountAvailable:(int)account
{
    if (![self isInitialized]) {
        return NO;
    }
    
    return [[self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.isAccountAvailable(%d)", account]] toBool];
}

- (int)getIndexOfActiveAccount:(int)account
{
    if (![self isInitialized]) {
        return 0;
    }
    
    return [[[self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.getIndexOfActiveAccount(%d)", account]] toNumber] intValue];
}

- (void)getSessionToken
{
    [self.context evaluateScript:@"MyWalletPhone.getSessionToken()"];
}

- (BOOL)emailNotificationsEnabled
{
    if (![self isInitialized]) {
        return NO;
    }
    
    return [[self.context evaluateScript:@"MyWalletPhone.emailNotificationsEnabled()"] toBool];
}

- (BOOL)SMSNotificationsEnabled
{
    if (![self isInitialized]) {
        return NO;
    }
    
    return [[self.context evaluateScript:@"MyWalletPhone.SMSNotificationsEnabled()"] toBool];
}

- (void)saveNote:(NSString *)note forTransaction:(NSString *)hash
{
    NSString *text = [note stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (text.length == 0) {
        [self.context evaluateScript:[NSString stringWithFormat:@"MyWallet.wallet.deleteNote(\"%@\")", [hash escapeStringForJS]]];
    } else {
        [self.context evaluateScript:[NSString stringWithFormat:@"MyWallet.wallet.setNote(\"%@\", \"%@\")", [hash escapeStringForJS], [note escapeStringForJS]]];
    }
}

- (void)saveEtherNote:(NSString *)note forTransaction:(NSString *)hash
{
    if ([self isInitialized]) {
        [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.saveEtherNote(\"%@\", \"%@\")", [hash escapeStringForJS], [note escapeStringForJS]]];
    }
}

- (void)getFiatAtTime:(uint64_t)time value:(NSDecimalNumber *)value currencyCode:(NSString *)currencyCode assetType:(AssetType)assetType
{
    NSString *symbol;
    if (assetType == AssetTypeBitcoin) {
        symbol = CURRENCY_SYMBOL_BTC;
    } else if (assetType == AssetTypeEther) {
        symbol = CURRENCY_SYMBOL_ETH;
    }
    
    NSURL *URL = [NSURL URLWithString:[URL_API stringByAppendingString:[NSString stringWithFormat:URL_SUFFIX_PRICE_INDEX_ARGUMENTS_BASE_QUOTE_TIME, symbol, currencyCode, time]]];

    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    NSURLSessionDataTask *task = [[SessionManager sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [self on_get_fiat_at_time_error:[error localizedDescription]];
            } else {
                NSError *jsonError;
                NSDictionary *dictResult = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                if (jsonError) DLog(@"JSON error getting fiat at time: %@", [error localizedDescription]);
                if ([dictResult objectForKey:DICTIONARY_KEY_ERROR]) return;
                
                NSNumber *result = [dictResult objectForKey:DICTIONARY_KEY_PRICE];
                NSDecimalNumber *amount = [value decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithDecimal:[result decimalValue]]];
                
                [self on_get_fiat_at_time_success:amount currencyCode:currencyCode assetType:assetType];
            }
        });
    }];
    
    [task resume];
}

- (NSString *)getNotePlaceholderForTransactionHash:(NSString *)myHash
{
    return [[self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.getNotePlaceholder(\"%@\")", myHash]] toString];
}

- (NSArray *)getSwipeAddresses:(int)numberOfAddresses label:(NSString *)label
{
    return [[self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.getSwipeAddresses(%d, \"%@\")", numberOfAddresses, label]] toArray];
}

- (int)getDefaultAccountLabelledAddressesCount
{
    return [[[self.context evaluateScript:@"MyWalletPhone.getDefaultAccountLabelledAddressesCount()"] toNumber] intValue];
}

- (BOOL)isBuyEnabled
{
    return [[self.context evaluateScript:@"MyWalletPhone.isBuyFeatureEnabled()"] toBool];
}

- (void)setupBuySellWebview
{
    [self.context evaluateScript:@"MyWalletPhone.setupBuySellWebview()"];
}

- (NSString *)buySellWebviewRootURLString
{
    JSValue *result = [self.context evaluateScript:@"MyWalletPhone.getBuySellWebviewRootURL()"];
    return [result isNull] ? nil : [result toString];
}

- (void)watchPendingTrades:(BOOL)shouldSync
{
    if (shouldSync) {
        [app showBusyViewWithLoadingText:BC_STRING_LOADING_SYNCING_WALLET];
    }
    
    [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.getPendingTrades(%d)", shouldSync]];
}

- (void)showCompletedTrade:(NSString *)txHash
{
    if ([self.delegate respondsToSelector:@selector(showCompletedTrade:)]) {
        [self.delegate showCompletedTrade:txHash];
    } else {
        DLog(@"Error: delegate of class %@ does not respond to selector showCompletedTrade!", [delegate class]);
    }
}

- (JSValue *)executeJSSynchronous:(NSString *)command
{
    return [self.context evaluateScript:command];
}

- (BOOL)isWaitingOnEtherTransaction
{
    if ([self isInitialized]) {
        return [[self.context evaluateScript:@"MyWalletPhone.isWaitingOnTransaction()"] toBool];
    }
    
    return NO;
}

- (NSString *)getMobileMessage
{
    if ([self isInitialized]) {
        JSValue *message = [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.getMobileMessage(\"%@\")", [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode]]];
        if ([message isUndefined] || [message isNull]) return nil;
        return [message toString];
    }
    
    return nil;
}

#pragma mark - Exchange

- (BOOL)isExchangeEnabled
{
    if ([self isInitialized]) {
        return [[self.context evaluateScript:@"MyWalletPhone.isExchangeEnabled()"] toBool];
    }
    
    return NO;
}

- (NSArray *)availableUSStates
{
    if ([self isInitialized]) {
        NSArray *states = [[self.context evaluateScript:@"MyWalletPhone.availableUSStates()"] toArray];
        return states.count > 0 ? states : nil;
    }
    
    return nil;
}

- (BOOL)isStateWhitelistedForShapeshift:(NSString *)stateCode
{
    if ([self isInitialized]) {
        return [[self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.isStateWhitelistedForShapeshift(\"%@\")", [stateCode escapeStringForJS]]] toBool];
    }
    
    return NO;
}

- (void)selectState:(NSString *)name code:(NSString *)code
{
    if ([self isInitialized]) {
        [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.setStateForShapeshift(\"%@\", \"%@\")", [name escapeStringForJS], [code escapeStringForJS]]];
    }
}

- (void)getExchangeTrades
{
     if ([self isInitialized]) [self.context evaluateScript:@"MyWalletPhone.getExchangeTrades()"];
}

- (void)getRate:(NSString *)coinPair
{
    if ([self isInitialized]) [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.getRate(\"%@\")", [coinPair escapeStringForJS]]];
}

- (NSURLSessionDataTask *)getApproximateQuote:(NSString *)coinPair usingFromField:(BOOL)usingFromField amount:(NSString *)amount completion:(void (^)(NSDictionary *, NSURLResponse *, NSError *))completion
{
    if ([self isInitialized]) {
        DLog(@"Getting approximate quote");
        
        NSString *convertedAmount = [NSNumberFormatter convertedDecimalString:amount];
        
        NSURL *URL = [NSURL URLWithString:@"https://shapeshift.io/sendamount"];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
        
        NSString *apiKey = [[self.context evaluateScript:@"MyWalletPhone.getShapeshiftApiKey()"] toString];
        
        NSString *depositOrWithdrawParameter = usingFromField ? @"depositAmount" : @"withdrawalAmount";
        
        NSString *postParameters = [NSString stringWithFormat:@"{\"pair\":\"%@\",\"%@\":\"%@\",\"apiKey\":\"%@\"}", [coinPair escapeStringForJS], [depositOrWithdrawParameter escapeStringForJS], [convertedAmount escapeStringForJS], [apiKey escapeStringForJS]];
        NSData *postData = [postParameters dataUsingEncoding:NSUTF8StringEncoding];
        
        [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:postData];

        NSURLSessionDataTask *task = [[SessionManager sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error) {
                DLog(@"Error getting approximate quote: %@", error);
                NSInteger cancelledErrorCode = -999;
                if (error.code != cancelledErrorCode) [app standardNotify:[NSString stringWithFormat:BC_STRING_ERROR_GETTING_APPROXIMATE_QUOTE_ARGUMENT_MESSAGE, error]];
            } else {
                NSError *jsonError;
                NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                if (result[DICTIONARY_KEY_ERROR] && [result[DICTIONARY_KEY_ERROR] isKindOfClass:[NSDictionary class]]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [app standardNotify:[NSString stringWithFormat:BC_STRING_ERROR_GETTING_APPROXIMATE_QUOTE_ARGUMENT_MESSAGE, result[DICTIONARY_KEY_ERROR][DICTIONARY_KEY_MESSAGE]]];
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (completion) completion(result, response, error);
                    });
                }
            }
        }];
        
        [task resume];
        
        return task;
    }
    
    return nil;
}

- (void)getAvailableBtcBalanceForAccount:(int)account
{
    if ([self isInitialized]) [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.getAvailableBtcBalanceForAccount(\"%d\")", account]];
}

- (void)getAvailableEthBalance
{
    if ([self isInitialized]) [self.context evaluateScript:@"MyWalletPhone.getAvailableEthBalance()"];
}

- (void)buildExchangeTradeFromAccount:(int)fromAccount toAccount:(int)toAccount coinPair:(NSString *)coinPair amount:(NSString *)amount fee:(NSString *)fee
{
    if ([self isInitialized]) {
        
        NSString *convertedAmount = [NSNumberFormatter convertedDecimalString:amount];
        
        [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.buildExchangeTrade(%d, %d, \"%@\", \"%@\", \"%@\")", fromAccount, toAccount, [[coinPair lowercaseString] escapeStringForJS], [convertedAmount escapeStringForJS], [fee escapeStringForJS]]];
    }
}

- (void)shiftPayment
{
    if ([self isInitialized]) {
        [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.shiftPayment()"]];
    }
}

- (BOOL)isDepositTransaction:(NSString *)txHash
{
    if ([self isInitialized]) {
        return [[self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.isDepositTransaction(\"%@\")", [txHash escapeStringForJS]]] toBool];
    }
    
    return NO;
}

- (BOOL)isWithdrawalTransaction:(NSString *)txHash
{
    if ([self isInitialized]) {
        return [[self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.isWithdrawalTransaction(\"%@\")", [txHash escapeStringForJS]]] toBool];
    }
    
    return NO;
}

#pragma mark - Contacts

- (void)loadContacts
{
#ifdef ENABLE_CONTACTS
    [self.context evaluateScript:@"MyWalletPhone.loadContacts()"];
#endif
}

- (void)loadContactsThenGetMessages
{
#ifdef ENABLE_CONTACTS
    [self.context evaluateScript:@"MyWalletPhone.loadContactsThenGetMessages()"];
#endif
}

- (void)getUpdatedContacts:(BOOL)isFirstLoad newMessages:(NSArray *)newMessages
{
    NSArray *contacts = [[[[JSContext currentContext] evaluateScript:@"MyWalletPhone.getContacts()"] toDictionary] allValues];
    
    self.pendingContactTransactions = [NSMutableArray new];
    self.completedContactTransactions = [NSMutableDictionary new];
    self.rejectedContactTransactions = [NSMutableArray new];

    [self iterateAndUpdateContacts:contacts];
    
    // Keep showing busy view to prevent user input while archiving/unarchiving addresses
    if (!self.isSyncing) {
        [self loading_stop];
    }
    
    if (isFirstLoad) {
        if ([self.delegate respondsToSelector:@selector(didGetMessagesOnFirstLoad)]) {
            
            [self.delegate didGetMessagesOnFirstLoad];
        } else {
            DLog(@"Error: delegate of class %@ does not respond to selector didGetMessagesOnFirstLoad!", [delegate class]);
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(didGetNewMessages:)]) {
            
            [self.delegate didGetNewMessages:newMessages];
        } else {
            DLog(@"Error: delegate of class %@ does not respond to selector didGetNewMessages!", [delegate class]);
        }
    }
}
    
- (void)createContactWithName:(NSString *)name ID:(NSString *)idString
{
    [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.createContact(\"%@\", \"%@\")", [name escapeStringForJS], [idString escapeStringForJS]]];
}

- (void)readInvitation:(NSString *)invitation
{
    NSString *string = [NSString stringWithFormat:@"MyWalletPhone.readInvitation(%@, \"%@\")", invitation, [invitation escapeStringForJS]];
    [self.context evaluateScript:string];
}

- (void)completeRelation:(NSString *)identifier
{
    [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.completeRelation(\"%@\")", [identifier escapeStringForJS]]];
}

- (void)acceptRelation:(NSString *)invitation name:(NSString *)name identifier:(NSString *)identifier
{
    [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.acceptRelation(\"%@\", \"%@\", \"%@\")", [invitation escapeStringForJS], [name escapeStringForJS], [identifier escapeStringForJS]]];
}

- (void)fetchExtendedPublicKey:(NSString *)contactIdentifier
{
    [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.fetchExtendedPublicKey(\"%@\")",[contactIdentifier escapeStringForJS]]];
}

- (void)getMessages
{
#ifdef ENABLE_CONTACTS
    [self.context evaluateScript:@"MyWalletPhone.getMessages()"];
#endif
}

- (void)changeName:(NSString *)newName forContact:(NSString *)contactIdentifier
{
    [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.changeName(\"%@\", \"%@\")", [newName escapeStringForJS], [contactIdentifier escapeStringForJS]]];
}

- (void)deleteContact:(NSString *)contactIdentifier
{
    [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.deleteContact(\"%@\")", [contactIdentifier escapeStringForJS]]];
}

- (void)deleteContactAfterStoringInfo:(NSString *)contactIdentifier
{
    [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.deleteContactAfterStoringInfo(\"%@\")", [contactIdentifier escapeStringForJS]]];
}

- (void)sendPaymentRequest:(NSString *)userId amount:(uint64_t)amount requestId:(NSString *)requestId note:(NSString *)note initiatorSource:(id)initiatorSource
{
    NSString *requestIdArgument = requestId ? [NSString stringWithFormat:@"\"%@\"", [requestId escapeStringForJS]] : @"undefined";
    
    NSString *escapedInitiatorSourceString;
    if ([initiatorSource isKindOfClass:[NSString class]]) {
        escapedInitiatorSourceString = [NSString stringWithFormat:@"\"%@\"", [initiatorSource escapeStringForJS]];
    } else {
        escapedInitiatorSourceString = initiatorSource;
    }
    
    if (note && note.length > 0) {
        [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.sendPaymentRequest(\"%@\", %lld, %@, \"%@\", %@)", [userId escapeStringForJS], amount, requestIdArgument, [note escapeStringForJS], escapedInitiatorSourceString]];
    } else {
        [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.sendPaymentRequest(\"%@\", %lld, %@, null, %@)", [userId escapeStringForJS], amount, requestIdArgument, escapedInitiatorSourceString]];
    }
}

- (void)requestPaymentRequest:(NSString *)userId amount:(uint64_t)amount requestId:(NSString *)requestId note:(NSString *)note initiatorSource:(id)initiatorSource
{
    NSString *requestIdArgument = requestId ? [NSString stringWithFormat:@"\"%@\"", [requestId escapeStringForJS]] : @"undefined";
    
    NSString *escapedInitiatorSourceString;
    if ([initiatorSource isKindOfClass:[NSString class]]) {
        escapedInitiatorSourceString = [NSString stringWithFormat:@"\"%@\"", [initiatorSource escapeStringForJS]];
    } else {
        escapedInitiatorSourceString = initiatorSource;
    }
    
    if (note && note.length > 0) {
        [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.requestPaymentRequest(\"%@\", %lld, %@, \"%@\")", [userId escapeStringForJS], amount, requestIdArgument, [note escapeStringForJS]]];
    } else {
        [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.requestPaymentRequest(\"%@\", %lld, %@)", [userId escapeStringForJS], amount, requestIdArgument]];
    }
}

- (void)sendPaymentRequestResponse:(NSString *)userId transactionHash:(NSString *)hash transactionIdentifier:(NSString *)transactionIdentifier
{
    [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.sendPaymentRequestResponse(\"%@\", \"%@\", \"%@\")", [userId escapeStringForJS], [hash escapeStringForJS], [transactionIdentifier escapeStringForJS]]];
}

- (void)sendDeclination:(ContactTransaction *)transaction
{
    [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.sendDeclination(\"%@\", \"%@\")", [transaction.contactIdentifier escapeStringForJS], [transaction.identifier escapeStringForJS]]];
}

- (void)sendCancellation:(ContactTransaction *)transaction
{
    [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.sendCancellation(\"%@\", \"%@\")", [transaction.contactIdentifier escapeStringForJS], [transaction.identifier escapeStringForJS]]];
}

- (void)iterateAndUpdateContacts:(NSArray *)allContacts
{
    int actionCount = 0;
    ContactActionRequired firstAction;
    
    NSMutableDictionary *allContactsDict = [NSMutableDictionary new];
    
    for (NSDictionary *contactDict in allContacts) {
        Contact *contact = [[Contact alloc] initWithDictionary:contactDict];
        [allContactsDict setObject:contact forKey:contact.identifier];
        
        // Check for any pending invitations
        if (!contact.mdid) {
            
            [self completeRelation:contact.identifier];
            
            if (contact.invitationReceived &&
                ![contact.invitationReceived isEqualToString:@""]) {
                actionCount++;
                firstAction = ContactActionRequiredSingleRequest;
            }
        }
        
        int actionCountForContact = [self iterateThroughTransactionsForContact:contact];
        
        if (actionCountForContact > 0) firstAction = ContactActionRequiredSinglePayment;
        actionCount = actionCount + actionCountForContact;
    }
    
    if (actionCount == 0) {
        self.contactsActionRequired = ContactActionRequiredNone;
    } else if (actionCount == 1) {
        self.contactsActionRequired = firstAction;
    } else if (actionCount > 1) {
        self.contactsActionRequired = ContactActionRequiredMultiple;
    }
    
    self.contactsActionCount = [NSNumber numberWithInt:actionCount];
    
    self.contacts = [[NSDictionary alloc] initWithDictionary:allContactsDict];
}

- (int)iterateThroughTransactionsForContact:(Contact *)contact
{
    int numberOfActionsRequired = 0;
    // Check for any pending requests
    for (ContactTransaction *transaction in [contact.transactionList allValues]) {
        if (transaction.transactionState == ContactTransactionStateReceiveAcceptOrDeclinePayment || transaction.transactionState == ContactTransactionStateSendReadyToSend) {
            numberOfActionsRequired++;
        }
        
        if (transaction.transactionState == ContactTransactionStateDeclined || transaction.transactionState == ContactTransactionStateCancelled) {
            [self.rejectedContactTransactions addObject:transaction];
        } else if (transaction.transactionState != ContactTransactionStateCompletedSend && transaction.transactionState != ContactTransactionStateCompletedReceive) {
            [self.pendingContactTransactions addObject:transaction];
        } else if (transaction.transactionState == ContactTransactionStateCompletedSend || transaction.transactionState == ContactTransactionStateCompletedReceive) {
            [self.completedContactTransactions setObject:transaction forKey:transaction.myHash];
        }
    }
    
    [self.pendingContactTransactions sortUsingSelector:@selector(reverseCompareLastUpdated:)];
    
    return numberOfActionsRequired;
}

- (BOOL)actionRequiredForContact:(Contact *)contact
{
    // Check for any pending requests
    for (ContactTransaction *transaction in [contact.transactionList allValues]) {
        if (transaction.transactionState == ContactTransactionStateReceiveAcceptOrDeclinePayment || transaction.transactionState == ContactTransactionStateSendReadyToSend) {
            return YES;
        }
    }
    
    return NO;
}

# pragma mark - Ethereum

- (void)createEthAccountForExchange:(NSString *)secondPassword
{
    if ([self isInitialized]) {
        NSString *setupHelperText = BC_STRING_ETHER_ACCOUNT_SECOND_PASSWORD_PROMPT;
        [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.createEthAccountForExchange(\"%@\", \"%@\")", [secondPassword escapeStringForJS], [setupHelperText escapeStringForJS]]];
    }
}

- (NSArray *)getEthTransactions
{
    if ([self isInitialized]) {
        NSArray *transactions = [[self.context evaluateScript:@"MyWalletPhone.getEthTransactions()"] toArray];
        NSMutableArray *convertedTransactions = [NSMutableArray new];
        for (NSDictionary *dict in transactions) {
            EtherTransaction *transaction = [EtherTransaction fromJSONDict:dict];
            [convertedTransactions addObject:transaction];
        }
        self.etherTransactions = [convertedTransactions copy];
        return self.etherTransactions;
    } else {
        DLog(@"Warning: getting eth transactions when not initialized - returning nil");
        return nil;
    }
}

- (NSString *)getEthBalance
{
    if ([self isInitialized] && [app.wallet hasEthAccount]) {
        return [[self.context evaluateScript:@"MyWalletPhone.getEthBalance()"] toString];
    } else {
        DLog(@"Warning: getting eth balance when not initialized - returning 0");
        return 0;
    }
}

- (NSString *)getEthBalanceTruncated
{
    if ([self isInitialized] && [app.wallet hasEthAccount]) {
        NSNumber *balanceNumber = [[self.context evaluateScript:@"MyWalletPhone.getEthBalance()"] toNumber];
        return [app.btcFormatter stringFromNumber:balanceNumber];
    } else {
        DLog(@"Warning: getting eth balance when not initialized - returning 0");
        return @"0";
    }
}

- (void)getEthHistory
{
    if ([self isInitialized]) {
        [self.context evaluateScript:@"MyWalletPhone.getEthHistory()"];
    }
}

- (void)getEthExchangeRate
{
    if ([self isInitialized]) {
        [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.getEthExchangeRate(\"%@\")", app.latestResponse.symbol_local.code]];
    }
}

- (void)createNewEtherPayment
{
    if (![self isInitialized]) {
        return;
    }
    
    [self.context evaluateScript:@"MyWalletPhone.createNewEtherPayment()"];
}

- (void)changeEtherPaymentTo:(NSString *)to
{
    if ([self isInitialized]) {
        [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.setEtherPaymentTo(\"%@\")", [to escapeStringForJS]]];
    }
}

- (void)changeEtherPaymentAmount:(id)amount
{
    if ([self isInitialized]) {
        [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.setEtherPaymentAmount(\"%@\")", amount ? : @0]];
    }
}

- (BOOL)isEthAddress:(NSString *)address
{
    if ([self isInitialized]) {
        return [[self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.isEthAddress(\"%@\")", address]] toBool];
    }
    
    return NO;
}

- (void)sendEtherPaymentWithNote:(NSString *)note
{
    if ([self isInitialized]) {
        [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.sendEtherPaymentWithNote(\"%@\")", note ? [note escapeStringForJS] : @""]];
    }
}

- (NSString *)getEtherAddress
{
    if ([self isInitialized]) {
        NSString *setupHelperText = BC_STRING_ETHER_ACCOUNT_SECOND_PASSWORD_PROMPT;
        JSValue *result = [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.getEtherAddress(\"%@\")", [setupHelperText escapeStringForJS]]];
        if ([result isUndefined]) return nil;
        NSString *etherAddress = [result toString];
        return etherAddress;
    }
    
    return nil;
}

- (void)isEtherContractAddress:(NSString *)address completion:(void (^ _Nullable)(NSData *, NSURLResponse *, NSError *))completion
{
    NSURL *URL = [NSURL URLWithString:[URL_API stringByAppendingString:[NSString stringWithFormat:URL_SUFFIX_ETH_IS_CONTRACT_ADDRESS_ARGUMENT, address]]];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    NSURLSessionDataTask *task = [[SessionManager sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) completion(data, response, error);
        });
    }];
    [task resume];
}

- (void)sweepEtherPayment
{
    if ([self isInitialized]) {
        [self.context evaluateScript:@"MyWalletPhone.sweepEtherPayment()"];
    }
}

- (BOOL)hasEthAccount
{
    if ([self isInitialized]) {
        return [[self.context evaluateScript:@"MyWalletPhone.hasEthAccount()"] toBool];
    }
    
    return NO;
}

- (NSString *)getLabelForEthAccount
{
    if ([self isInitialized] && [self hasEthAccount]) {
        return [[self.context evaluateScript:@"MyWalletPhone.getLabelForEthAccount()"] toString];
    }
    
    return nil;
}

# pragma mark - Transaction handlers

- (void)tx_on_start:(NSString*)txProgressID
{
    transactionProgressListeners *listener = [self.transactionProgressListeners objectForKey:txProgressID];
    
    if (listener) {
        if (listener.on_start) {
            listener.on_start();
        }
    }
}

- (void)tx_on_begin_signing:(NSString*)txProgressID
{
    transactionProgressListeners *listener = [self.transactionProgressListeners objectForKey:txProgressID];
    
    if (listener) {
        if (listener.on_begin_signing) {
            listener.on_begin_signing();
        }
    }
}

- (void)tx_on_sign_progress:(NSString*)txProgressID input:(NSString*)input
{
    transactionProgressListeners *listener = [self.transactionProgressListeners objectForKey:txProgressID];
    
    if (listener) {
        if (listener.on_sign_progress) {
            listener.on_sign_progress([input intValue]);
        }
    }
}

- (void)tx_on_finish_signing:(NSString*)txProgressID
{
    transactionProgressListeners *listener = [self.transactionProgressListeners objectForKey:txProgressID];
    
    if (listener) {
        if (listener.on_finish_signing) {
            listener.on_finish_signing();
        }
    }
}

- (void)tx_on_success:(NSString*)txProgressID secondPassword:(NSString *)secondPassword transactionHash:(NSString *)hash
{
    transactionProgressListeners *listener = [self.transactionProgressListeners objectForKey:txProgressID];
    
    if (listener) {
        if (listener.on_success) {
            listener.on_success(secondPassword, hash);
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(didPushTransaction)]) {
        [self.delegate didPushTransaction];
    } else {
        DLog(@"Error: delegate of class %@ does not respond to selector didPushTransaction!", [delegate class]);
    }
}

- (void)tx_on_error:(NSString*)txProgressID error:(NSString*)error secondPassword:(NSString *)secondPassword
{
    transactionProgressListeners *listener = [self.transactionProgressListeners objectForKey:txProgressID];
    
    if (listener) {
        if (listener.on_error) {
            listener.on_error(error, secondPassword);
        }
    }
}

#pragma mark - Callbacks from JS to Obj-C dealing with loading texts

- (void)loading_start_download_wallet
{
    [app showBusyViewWithLoadingText:BC_STRING_LOADING_DOWNLOADING_WALLET];
}

- (void)loading_start_decrypt_wallet
{
    [app updateBusyViewLoadingText:BC_STRING_LOADING_DECRYPTING_WALLET];
}

- (void)loading_start_build_wallet
{
    [app updateBusyViewLoadingText:BC_STRING_LOADING_LOADING_BUILD_HD_WALLET];
}

- (void)loading_start_multiaddr
{
    [app updateBusyViewLoadingText:BC_STRING_LOADING_LOADING_TRANSACTIONS];
}

- (void)loading_start_get_history
{
    [app showBusyViewWithLoadingText:BC_STRING_LOADING_LOADING_TRANSACTIONS];
}

- (void)loading_start_get_wallet_and_history
{
    [app showBusyViewWithLoadingText:BC_STRING_LOADING_CHECKING_WALLET_UPDATES];
}

- (void)loading_start_upgrade_to_hd
{
    [app showBusyViewWithLoadingText:BC_STRING_LOADING_CREATING_V3_WALLET];
}

- (void)loading_start_create_account
{
    [app showBusyViewWithLoadingText:BC_STRING_LOADING_CREATING];
}

- (void)loading_start_new_account
{
    [app showBusyViewWithLoadingText:BC_STRING_LOADING_CREATING_WALLET];
}

- (void)loading_start_create_new_address
{
    [app showBusyViewWithLoadingText:BC_STRING_LOADING_CREATING_NEW_ADDRESS];
}

- (void)loading_start_generate_uuids
{
    [app updateBusyViewLoadingText:BC_STRING_LOADING_RECOVERY_CREATING_WALLET];
}

- (void)loading_start_recover_wallet
{
    [app showBusyViewWithLoadingText:BC_STRING_LOADING_RECOVERING_WALLET];
}

- (void)loading_start_transfer_all:(NSNumber *)addressIndex totalAddresses:(NSNumber *)totalAddresses
{
    [app showBusyViewWithLoadingText:[NSString stringWithFormat:BC_STRING_TRANSFER_ALL_CALCULATING_AMOUNTS_AND_FEES_ARGUMENT_OF_ARGUMENT, addressIndex, totalAddresses]];
}

- (void)loading_stop
{
    DLog(@"Stop loading");
    [app hideBusyView];
}

- (void)upgrade_success
{
    [app standardNotify:BC_STRING_UPGRADE_SUCCESS title:BC_STRING_UPGRADE_SUCCESS_TITLE];
}

#pragma mark - Callbacks from JS to Obj-C

- (void)log:(NSString*)message
{
    DLog(@"console.log: %@", [message description]);
}

- (void)ws_on_open
{
    DLog(@"ws_on_open");
}

- (void)ws_on_close
{
    DLog(@"ws_on_close");
}

- (void)on_fetch_needs_two_factor_code
{
    DLog(@"on_fetch_needs_two_factor_code");
    int twoFactorType = [[app.wallet get2FAType] intValue];
    if (twoFactorType == TWO_STEP_AUTH_TYPE_GOOGLE) {
        [app verifyTwoFactorGoogle];
    } else if (twoFactorType == TWO_STEP_AUTH_TYPE_SMS) {
        [app verifyTwoFactorSMS];
    } else if (twoFactorType == TWO_STEP_AUTH_TYPE_YUBI_KEY) {
        [app verifyTwoFactorYubiKey];
    } else {
        [app standardNotifyAutoDismissingController:BC_STRING_INVALID_AUTHENTICATION_TYPE];
    }
}

- (void)did_set_latest_block
{
    if (![self isInitialized]) {
        return;
    }
    
    DLog(@"did_set_latest_block");
    
    [self parseLatestBlockJSON:[[self.context evaluateScript:@"MyWalletPhone.didSetLatestBlock()"] toString]];
}

- (void)parseLatestBlockJSON:(NSString*)latestBlockJSON
{
    if ([latestBlockJSON isEqualToString:@""]) {
        return;
    }
    
    id dict = [latestBlockJSON getJSONObject];
    
    if (dict && [dict isKindOfClass:[NSDictionary class]]) {
        LatestBlock *latestBlock = [[LatestBlock alloc] init];
        
        latestBlock.height = [[dict objectForKey:@"height"] intValue];
        latestBlock.time = [[dict objectForKey:@"time"] longLongValue];
        latestBlock.blockIndex = [[dict objectForKey:@"block_index"] intValue];
        
        if ([delegate respondsToSelector:@selector(didSetLatestBlock:)]) {
            [delegate didSetLatestBlock:latestBlock];
        } else {
            DLog(@"Error: delegate of class %@ does not respond to selector didSetLatestBlock:!", [delegate class]);
        }
    } else {
        DLog(@"Error: could not get JSON object from latest block JSON");
    }
}

- (void)reloadFilter
{
    self.isFilteringTransactions = YES;
    [self did_multiaddr];
}

- (void)did_multiaddr
{
    if (![self isInitialized]) {
        return;
    }
    
    DLog(@"did_multiaddr");
    
    [self getFinalBalance];
    
    NSString *filter = @"";
#ifdef ENABLE_TRANSACTION_FILTERING
    
    TransactionsBitcoinViewController *transactionsBitcoinViewController = app.tabControllerManager.transactionsBitcoinViewController;
    
    int filterIndex = transactionsBitcoinViewController ? (int)app.tabControllerManager.transactionsBitcoinViewController.filterIndex : FILTER_INDEX_ALL;
    
    if (filterIndex == FILTER_INDEX_ALL) {
        filter = @"";
    } else if (filterIndex == FILTER_INDEX_IMPORTED_ADDRESSES) {
        filter = TRANSACTION_FILTER_IMPORTED;
    } else {
        filter = [NSString stringWithFormat:@"%d", filterIndex];
    }
#endif
    
    NSString *multiAddrJSON = [[self.context evaluateScript:[NSString stringWithFormat:@"JSON.stringify(MyWalletPhone.getMultiAddrResponse(\"%@\"))", filter]] toString];
    
    MultiAddressResponse *response = [self parseMultiAddrJSON:multiAddrJSON];
    
    if (!self.isSyncing) {
        [self loading_stop];
    }
    
    if ([delegate respondsToSelector:@selector(didGetMultiAddressResponse:)]) {
        [delegate didGetMultiAddressResponse:response];
    } else {
        DLog(@"Error: delegate of class %@ does not respond to selector didGetMultiAddressResponse:!", [delegate class]);
    }
}

- (MultiAddressResponse *)parseMultiAddrJSON:(NSString*)multiAddrJSON
{
    if (multiAddrJSON == nil)
    return nil;
    
    NSDictionary *dict = [multiAddrJSON getJSONObject];
    
    MultiAddressResponse *response = [[MultiAddressResponse alloc] init];
    
    response.final_balance = [[dict objectForKey:DICTIONARY_KEY_MULTIADDRESS_FINAL_BALANCE] longLongValue];
    response.total_received = [[dict objectForKey:DICTIONARY_KEY_MULTIADDRESS_TOTAL_RECEIVED] longLongValue];
    response.n_transactions = [[dict objectForKey:DICTIONARY_KEY_MULTIADDRESS_NUMBER_TRANSACTIONS] unsignedIntValue];
    response.total_sent = [[dict objectForKey:DICTIONARY_KEY_MULTIADDRESS_TOTAL_SENT] longLongValue];
    response.addresses = [dict objectForKey:DICTIONARY_KEY_MULTIADDRESS_ADDRESSES];
    response.transactions = [NSMutableArray array];
    
    NSArray *transactionsArray = [dict objectForKey:DICTIONARY_KEY_MULTIADDRESS_TRANSACTIONS];
    
    for (NSDictionary *dict in transactionsArray) {
        Transaction *tx = [Transaction fromJSONDict:dict];
        
        [response.transactions addObject:tx];
    }
    
    return response;
}

- (void)on_tx_received
{
    DLog(@"on_tx_received");
    
    self.didReceiveMessageForLastTransaction = YES;
    
    if ([delegate respondsToSelector:@selector(receivedTransactionMessage)]) {
        [delegate receivedTransactionMessage];
    } else {
        DLog(@"Error: delegate of class %@ does not respond to selector receivedTransactionMessage!", [delegate class]);
    }
}

- (void)getPrivateKeyPassword:(NSString *)canDiscard success:(JSValue *)success error:(void(^)(id))_error
{
    [app getPrivateKeyPassword:^(NSString *privateKeyPassword) {
        [success callWithArguments:@[privateKeyPassword]];
    } error:_error];
}

- (void)getSecondPassword:(NSString *)canDiscard success:(JSValue *)success error:(void(^)(id))_error helperText:(NSString *)helperText
{
    [app getSecondPassword:^(NSString *secondPassword) {
        [success callWithArguments:@[secondPassword]];
    } error:_error helperText:(NSString *)helperText];
}

- (void)setLoadingText:(NSString*)message
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_LOADING_TEXT object:message];
}

- (void)makeNotice:(NSString*)type id:(NSString*)_id message:(NSString*)message
{
    // This is kind of ugly. When the wallet fails to load, usually because of a connection problem, wallet.js throws two errors in the setGUID function and we only want to show one. This filters out the one we don't want to show.
    if ([message isEqualToString:@"Error changing wallet identifier"]) {
        return;
    }
    
    // Don't display an error message for this notice, instead show a note in the sideMenu
    if ([message isEqualToString:@"For Improved security add an email address to your account."]) {
        return;
    }
    
    NSRange invalidEmailStringRange = [message rangeOfString:@"update-email-error" options:NSCaseInsensitiveSearch range:NSMakeRange(0, message.length) locale:[NSLocale currentLocale]];
    if (invalidEmailStringRange.location != NSNotFound) {
        [self performSelector:@selector(on_update_email_error) withObject:nil afterDelay:DELAY_KEYBOARD_DISMISSAL];
        return;
    }
    
    NSRange updateCurrencyErrorStringRange = [message rangeOfString:@"currency-error" options:NSCaseInsensitiveSearch range:NSMakeRange(0, message.length) locale:[NSLocale currentLocale]];
    if (updateCurrencyErrorStringRange.location != NSNotFound) {
        [self performSelector:@selector(on_change_currency_error) withObject:nil afterDelay:0.1f];
        return;
    }
    
    NSRange updateSMSErrorStringRange = [message rangeOfString:@"sms-error" options:NSCaseInsensitiveSearch range:NSMakeRange(0, message.length) locale:[NSLocale currentLocale]];
    if (updateSMSErrorStringRange.location != NSNotFound) {
        [self performSelector:@selector(on_change_mobile_number_error) withObject:nil afterDelay:0.1f];
        return;
    }
    
    NSRange incorrectPasswordErrorStringRange = [message rangeOfString:@"please check that your password is correct" options:NSCaseInsensitiveSearch range:NSMakeRange(0, message.length) locale:[NSLocale currentLocale]];
    if (incorrectPasswordErrorStringRange.location != NSNotFound && ![KeychainItemWrapper guid]) {
        // Error message shown in error_other_decrypting_wallet without guid
        return;
    }
    
    NSRange errorSavingWalletStringRange = [message rangeOfString:@"Error Saving Wallet" options:NSCaseInsensitiveSearch range:NSMakeRange(0, message.length) locale:[NSLocale currentLocale]];
    if (errorSavingWalletStringRange.location != NSNotFound) {
        [app standardNotify:BC_STRING_ERROR_SAVING_WALLET_CHECK_FOR_OTHER_DEVICES];
        return;
    }
    
    if ([type isEqualToString:@"error"]) {
        [app standardNotify:message title:BC_STRING_ERROR];
    } else if ([type isEqualToString:@"info"]) {
        [app standardNotify:message title:BC_STRING_INFORMATION];
    }
}

- (void)error_other_decrypting_wallet:(NSString *)message
{
    DLog(@"error_other_decrypting_wallet");
    
    // This error message covers the case where the GUID is 36 characters long but is not valid. This can only be checked after JS has been loaded. To avoid multiple error messages, it finds a localized "identifier" substring in the error description. Currently, different manual pairing error messages are sent to both my-wallet.js and wallet-ios.js (in this case, also to the same error callback), so a cleaner approach that avoids a substring search would either require more distinguishable error callbacks (separated by scope) or thorough refactoring.
    
    if (message != nil) {
        NSRange identifierRange = [message rangeOfString:BC_STRING_IDENTIFIER options:NSCaseInsensitiveSearch range:NSMakeRange(0, message.length) locale:[NSLocale currentLocale]];
        NSRange connectivityErrorRange = [message rangeOfString:ERROR_FAILED_NETWORK_REQUEST options:NSCaseInsensitiveSearch range:NSMakeRange(0, message.length) locale:[NSLocale currentLocale]];
        if (identifierRange.location != NSNotFound) {
            [app standardNotify:message title:BC_STRING_ERROR];
            [self error_restoring_wallet];
            return;
        } else if (connectivityErrorRange.location != NSNotFound) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(ANIMATION_DURATION_LONG * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [app standardNotify:BC_STRING_REQUEST_FAILED_PLEASE_CHECK_INTERNET_CONNECTION title:BC_STRING_ERROR];
            });
            [self error_restoring_wallet];
            return;
        }
        
        if (![KeychainItemWrapper guid]) {
            // This error is used whe trying to login with incorrect passwords or when the account is locked, so present an alert if the app has no guid, since it currently conflicts with makeNotice when backgrounding after changing password in-app
            [app standardNotifyAutoDismissingController:message];
        }
    }
}

- (void)error_restoring_wallet
{
    DLog(@"error_restoring_wallet");
    if ([delegate respondsToSelector:@selector(walletFailedToDecrypt)]) {
        [delegate walletFailedToDecrypt];
    } else {
        DLog(@"Error: delegate of class %@ does not respond to selector walletFailedToDecrypt!", [delegate class]);
    }
}

- (void)did_decrypt
{
    DLog(@"did_decrypt");
    
    if (self.webSocket) {
        [self.webSocket closeWithCode:WEBSOCKET_CODE_DECRYPTED_WALLET reason:WEBSOCKET_CLOSE_REASON_DECRYPTED_WALLET];
    } else {
        [self setupWebSocket];
    }
    
    [self setupEthSocket];
    
    self.sharedKey = [[self.context evaluateScript:@"MyWallet.wallet.sharedKey"] toString];
    self.guid = [[self.context evaluateScript:@"MyWallet.wallet.guid"] toString];
    
    if ([delegate respondsToSelector:@selector(walletDidDecrypt)]) {
        [delegate walletDidDecrypt];
    } else {
        DLog(@"Error: delegate of class %@ does not respond to selector walletDidDecrypt!", [delegate class]);
    }
}

- (void)did_load_wallet
{
    DLog(@"did_load_wallet");
    
    if (self.isNew) {
        
        NSString *currencyCode = [[NSLocale currentLocale] objectForKey:NSLocaleCurrencyCode];
        
        if ([[self.currencySymbols allKeys] containsObject:currencyCode]) {
            [self changeLocalCurrency:[[NSLocale currentLocale] objectForKey:NSLocaleCurrencyCode]];
        }
    }
    
    [self watchPendingTrades:NO];
        
    if ([delegate respondsToSelector:@selector(walletDidFinishLoad)]) {
        
        [delegate walletDidFinishLoad];
    } else {
        DLog(@"Error: delegate of class %@ does not respond to selector walletDidFinishLoad!", [delegate class]);
    }
}

- (void)on_create_new_account:(NSString*)_guid sharedKey:(NSString*)_sharedKey password:(NSString*)_password
{
    DLog(@"on_create_new_account:");
    
    if ([delegate respondsToSelector:@selector(didCreateNewAccount:sharedKey:password:)]) {
        [delegate didCreateNewAccount:_guid sharedKey:_sharedKey password:_password];
    } else {
        DLog(@"Error: delegate of class %@ does not respond to selector didCreateNewAccount:sharedKey:password:!", [delegate class]);
    }
}

- (void)on_add_private_key_start
{
    DLog(@"on_add_private_key_start");
    self.isSyncing = YES;
    
    [app showBusyViewWithLoadingText:BC_STRING_LOADING_IMPORT_KEY];
}

- (void)on_add_key:(NSString*)address
{
    DLog(@"on_add_private_key");
    self.isSyncing = YES;
    
    if (![self isWatchOnlyLegacyAddress:address]) {
        [self subscribeToAddress:address];
    }
    
    if ([delegate respondsToSelector:@selector(didImportKey:)]) {
        [delegate didImportKey:address];
    } else {
        DLog(@"Error: delegate of class %@ does not respond to selector didImportKey:!", [delegate class]);
    }
}

- (void)on_add_incorrect_private_key:(NSString *)address
{
    DLog(@"on_add_incorrect_private_key:");
    self.isSyncing = YES;
    
    if ([delegate respondsToSelector:@selector(didImportIncorrectPrivateKey:)]) {
        [delegate didImportIncorrectPrivateKey:address];
    } else {
        DLog(@"Error: delegate of class %@ does not respond to selector didImportIncorrectPrivateKey:!", [delegate class]);
    }
}

- (void)on_add_private_key_to_legacy_address:(NSString *)address
{
    DLog(@"on_add_private_key_to_legacy_address:");
    self.isSyncing = YES;
    
    [self subscribeToAddress:address];
    
    if ([delegate respondsToSelector:@selector(didImportPrivateKeyToLegacyAddress)]) {
        [delegate didImportPrivateKeyToLegacyAddress];
    } else {
        DLog(@"Error: delegate of class %@ does not respond to selector didImportPrivateKeyToLegacyAddress!", [delegate class]);
    }
}

- (void)on_error_adding_private_key:(NSString*)error
{
    if ([delegate respondsToSelector:@selector(didFailToImportPrivateKey:)]) {
        [delegate didFailToImportPrivateKey:error];
    } else {
        DLog(@"Error: delegate of class %@ does not respond to selector didFailToImportPrivateKey:!", [delegate class]);
    }
}

- (void)on_error_adding_private_key_watch_only:(NSString*)error
{
    if ([delegate respondsToSelector:@selector(didFailToImportPrivateKeyForWatchOnlyAddress:)]) {
        [delegate didFailToImportPrivateKeyForWatchOnlyAddress:error];
    } else {
        DLog(@"Error: delegate of class %@ does not respond to selector didFailToImportPrivateKeyForWatchOnlyAddress:!", [delegate class]);
    }
}

- (void)on_error_creating_new_account:(NSString*)message
{
    DLog(@"on_error_creating_new_account:");
    
    if ([delegate respondsToSelector:@selector(errorCreatingNewAccount:)]) {
        [delegate errorCreatingNewAccount:message];
    } else {
        DLog(@"Error: delegate of class %@ does not respond to selector errorCreatingNewAccount:!", [delegate class]);
    }
}

- (void)on_error_pin_code_put_error:(NSString*)message
{
    DLog(@"on_error_pin_code_put_error:");
    
    if ([delegate respondsToSelector:@selector(didFailPutPin:)]) {
        [delegate didFailPutPin:message];
    } else {
        DLog(@"Error: delegate of class %@ does not respond to selector didFailPutPin:!", [delegate class]);
    }
}

- (void)on_pin_code_put_response:(NSDictionary*)responseObject
{
    DLog(@"on_pin_code_put_response: %@", responseObject);
    
    if ([delegate respondsToSelector:@selector(didPutPinSuccess:)]) {
        [delegate didPutPinSuccess:responseObject];
    } else {
        DLog(@"Error: delegate of class %@ does not respond to selector didPutPinSuccess:!", [delegate class]);
    }
}

- (void)on_error_pin_code_get_timeout
{
    DLog(@"on_error_pin_code_get_timeout");
    
    if ([delegate respondsToSelector:@selector(didFailGetPinTimeout)]) {
        [delegate didFailGetPinTimeout];
    } else {
        DLog(@"Error: delegate of class %@ does not respond to selector didFailGetPinTimeout!", [delegate class]);
    }
}

- (void)on_error_pin_code_get_empty_response
{
    DLog(@"on_error_pin_code_get_empty_response");
    
    if ([delegate respondsToSelector:@selector(didFailGetPinNoResponse)]) {
        [delegate didFailGetPinNoResponse];
    } else {
        DLog(@"Error: delegate of class %@ does not respond to selector didFailGetPinNoResponse!", [delegate class]);
    }
}

- (void)on_error_pin_code_get_invalid_response
{
    DLog(@"on_error_pin_code_get_invalid_response");
    
    if ([delegate respondsToSelector:@selector(didFailGetPinInvalidResponse)]) {
        [delegate didFailGetPinInvalidResponse];
    } else {
        DLog(@"Error: delegate of class %@ does not respond to selector didFailGetPinInvalidResponse!", [delegate class]);
    }
}

- (void)on_pin_code_get_response:(NSDictionary*)responseObject
{
    DLog(@"on_pin_code_get_response:");
    
    if ([delegate respondsToSelector:@selector(didGetPinResponse:)]) {
        [delegate didGetPinResponse:responseObject];
    } else {
        DLog(@"Error: delegate of class %@ does not respond to selector didGetPinResponse:!", [delegate class]);
    }
}

- (void)on_error_maintenance_mode
{
    DLog(@"on_error_maintenance_mode");
    [self loading_stop];
    [app.pinEntryViewController reset];
    [app standardNotify:BC_STRING_MAINTENANCE_MODE];
}

- (void)on_backup_wallet_start
{
    DLog(@"on_backup_wallet_start");
}

- (void)on_backup_wallet_error
{
    DLog(@"on_backup_wallet_error");
    
    if ([delegate respondsToSelector:@selector(didFailBackupWallet)]) {
        [delegate didFailBackupWallet];
    } else {
        DLog(@"Error: delegate of class %@ does not respond to selector didFailBackupWallet!", [delegate class]);
    }
    
    [self resetSyncStatus];
}

- (void)on_backup_wallet_success
{
    DLog(@"on_backup_wallet_success");
    if ([delegate respondsToSelector:@selector(didBackupWallet)]) {
        [delegate didBackupWallet];
    } else {
        DLog(@"Error: delegate of class %@ does not respond to selector didBackupWallet!", [delegate class]);
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_BACKUP_SUCCESS object:nil];
    // Hide the busy view if previously syncing
    [self loading_stop];
    self.isSyncing = NO;
    
    if (self.isSettingDefaultAccount) {
        if ([self.delegate respondsToSelector:@selector(didSetDefaultAccount)]) {
            [self.delegate didSetDefaultAccount];
        } else {
            DLog(@"Error: delegate of class %@ does not respond to selector didSetDefaultAccount!", [delegate class]);
        }
    }
}

- (void)did_fail_set_guid
{
    DLog(@"did_fail_set_guid");
    
    if ([delegate respondsToSelector:@selector(walletFailedToLoad)]) {
        [delegate walletFailedToLoad];
    } else {
        DLog(@"Error: delegate of class %@ does not respond to selector walletFailedToLoad!", [delegate class]);
    }
}

- (void)on_change_local_currency_success
{
    DLog(@"on_change_local_currency_success");
    [self getHistory];
    
    if ([delegate respondsToSelector:@selector(didChangeLocalCurrency)]) {
        [delegate didChangeLocalCurrency];
    } else {
        DLog(@"Error: delegate of class %@ does not respond to selector didChangeLocalCurrency!", [delegate class]);
    }
}

- (void)on_change_currency_error
{
    DLog(@"on_change_local_currency_error");
    [app standardNotify:BC_STRING_SETTINGS_ERROR_LOADING_MESSAGE title:BC_STRING_SETTINGS_ERROR_UPDATING_TITLE];
}

- (void)on_get_account_info_success:(NSString *)accountInfo
{
    DLog(@"on_get_account_info");
    self.accountInfo = [accountInfo getJSONObject];
    self.hasLoadedAccountInfo = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_GET_ACCOUNT_INFO_SUCCESS object:nil];
}

- (void)on_get_all_currency_symbols_success:(NSString *)currencies
{
    DLog(@"on_get_all_currency_symbols_success");
    NSDictionary *allCurrencySymbolsDictionary = [currencies getJSONObject];
    NSMutableDictionary *currencySymbolsWithNames = [[NSMutableDictionary alloc] initWithDictionary:allCurrencySymbolsDictionary];
    NSDictionary *currencyNames = [CurrencySymbol currencyNames];
    
    for (NSString *abbreviatedFiatString in [allCurrencySymbolsDictionary allKeys]) {
        NSDictionary *values = [allCurrencySymbolsDictionary objectForKey:abbreviatedFiatString]; // should never be nil
        NSMutableDictionary *valuesWithName = [[NSMutableDictionary alloc] initWithDictionary:values]; // create a mutable dictionary of the current dictionary values
        NSString *currencyName = [currencyNames objectForKey:abbreviatedFiatString];
        if (currencyName) {
            [valuesWithName setObject:currencyName forKey:DICTIONARY_KEY_NAME];
            [currencySymbolsWithNames setObject:valuesWithName forKey:abbreviatedFiatString];
        } else {
            DLog(@"Warning: no name found for currency %@", abbreviatedFiatString);
        }
    }
    
    self.currencySymbols = currencySymbolsWithNames;
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_GET_ALL_CURRENCY_SYMBOLS_SUCCESS object:nil];
}

- (void)on_change_email_success
{
    DLog(@"on_change_email_success");
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_CHANGE_EMAIL_SUCCESS object:nil];
}

- (void)on_resend_verification_email_success
{
    DLog(@"on_resend_verification_email_success");
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_RESEND_VERIFICATION_EMAIL_SUCCESS object:nil];
}

- (void)on_change_mobile_number_success
{
    DLog(@"on_change_mobile_number_success");
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_CHANGE_MOBILE_NUMBER_SUCCESS object:nil];
}

- (void)on_change_mobile_number_error
{
    DLog(@"on_change_mobile_number_error");
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_CHANGE_MOBILE_NUMBER_ERROR object:nil];
}

- (void)on_verify_mobile_number_success
{
    DLog(@"on_verify_mobile_number_success");
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_VERIFY_MOBILE_NUMBER_SUCCESS object:nil];
}

- (void)on_verify_mobile_number_error
{
    DLog(@"on_verify_mobile_number_error");
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_VERIFY_MOBILE_NUMBER_ERROR object:nil];
}

- (void)on_change_two_step_success
{
    DLog(@"on_change_two_step_success");
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_CHANGE_TWO_STEP_SUCCESS object:nil];
}

- (void)on_change_two_step_error
{
    DLog(@"on_change_two_step_error");
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_CHANGE_TWO_STEP_ERROR object:nil];
}

- (void)on_change_password_success
{
    DLog(@"on_change_password_success");
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_CHANGE_PASSWORD_SUCCESS object:nil];
}

- (void)on_change_password_error
{
    DLog(@"on_change_password_error");
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_CHANGE_PASSWORD_ERROR object:nil];
}

- (void)on_get_history_success
{
    DLog(@"on_get_history_success");
    
    [self getMessages];
}

- (void)did_get_fee:(NSNumber *)fee dust:(NSNumber *)dust txSize:(NSNumber *)txSize
{
    DLog(@"update_fee");
    DLog(@"Wallet: fee is %@", fee);
    if ([self.delegate respondsToSelector:@selector(didGetFee:dust:txSize:)]) {
        [self.delegate didGetFee:fee dust:dust txSize:txSize];
    }
}

- (void)did_change_satoshi_per_byte:(NSNumber *)sweepAmount fee:(NSNumber *)fee dust:(NSNumber *)dust updateType:(FeeUpdateType)updateType
{
    DLog(@"did_change_satoshi_per_byte");
    if ([self.delegate respondsToSelector:@selector(didChangeSatoshiPerByte:fee:dust:updateType:)]) {
        [self.delegate didChangeSatoshiPerByte:sweepAmount fee:fee dust:dust updateType:updateType];
    }
}

- (void)update_surge_status:(NSNumber *)surgeStatus
{
    DLog(@"update_surge_status");
    if ([self.delegate respondsToSelector:@selector(didGetSurgeStatus:)]) {
        [self.delegate didGetSurgeStatus:[surgeStatus boolValue]];
    }
}

- (void)update_max_amount:(NSNumber *)amount fee:(NSNumber *)fee dust:(NSNumber *)dust willConfirm:(NSNumber *)willConfirm
{
    DLog(@"update_max_amount");
    DLog(@"Wallet: max amount is %@ with fee %@", amount, fee);
    
    if ([self.delegate respondsToSelector:@selector(didGetMaxFee:amount:dust:willConfirm:)]) {
        [self.delegate didGetMaxFee:fee amount:amount dust:dust willConfirm:[willConfirm boolValue]];
    }
}

- (void)update_total_available:(NSNumber *)sweepAmount final_fee:(NSNumber *)finalFee
{
    DLog(@"update_total_available:minus_fee:");

    if ([self.delegate respondsToSelector:@selector(didUpdateTotalAvailable:finalFee:)]) {
        [self.delegate didUpdateTotalAvailable:sweepAmount finalFee:finalFee];
    }
}

- (void)check_max_amount:(NSNumber *)amount fee:(NSNumber *)fee
{
    DLog(@"check_max_amount");
    if ([self.delegate respondsToSelector:@selector(didCheckForOverSpending:fee:)]) {
        [self.delegate didCheckForOverSpending:amount fee:fee];
    }
}

- (void)on_error_update_fee:(NSDictionary *)error updateType:(FeeUpdateType)updateType
{
    DLog(@"on_error_update_fee");
    NSString *message;
    if ([error[DICTIONARY_KEY_MESSAGE] isKindOfClass:[NSString class]]) {
        message = error[DICTIONARY_KEY_MESSAGE];
    } else {
        id errorObject = error[DICTIONARY_KEY_MESSAGE][DICTIONARY_KEY_ERROR];
        message = [errorObject isKindOfClass:[NSString class]] ? errorObject : errorObject[DICTIONARY_KEY_ERROR];
    }
    
    if (updateType == FeeUpdateTypeConfirm) {
        if ([message isEqualToString:ERROR_NO_UNSPENT_OUTPUTS] || [message isEqualToString:ERROR_AMOUNTS_ADDRESSES_MUST_EQUAL]) {
            [app standardNotifyAutoDismissingController:BC_STRING_NO_AVAILABLE_FUNDS];
        } else if ([message isEqualToString:ERROR_BELOW_DUST_THRESHOLD]) {
            id errorObject = error[DICTIONARY_KEY_MESSAGE][DICTIONARY_KEY_ERROR];
            uint64_t threshold = [errorObject isKindOfClass:[NSString class]] ? [error[DICTIONARY_KEY_MESSAGE][DICTIONARY_KEY_THRESHOLD] longLongValue] : [error[DICTIONARY_KEY_MESSAGE][DICTIONARY_KEY_ERROR][DICTIONARY_KEY_THRESHOLD] longLongValue];
            [app standardNotifyAutoDismissingController:[NSString stringWithFormat:BC_STRING_MUST_BE_ABOVE_OR_EQUAL_TO_DUST_THRESHOLD, threshold]];
        } else if ([message isEqualToString:ERROR_FETCH_UNSPENT]) {
            [app standardNotifyAutoDismissingController:BC_STRING_SOMETHING_WENT_WRONG_CHECK_INTERNET_CONNECTION];
        } else {
            [app standardNotifyAutoDismissingController:message];
        }
        
        if ([self.delegate respondsToSelector:@selector(enableSendPaymentButtons)]) {
            [self.delegate enableSendPaymentButtons];
        }
    } else {
        [self updateTotalAvailableAndFinalFee];
    }
}

- (void)on_payment_notice:(NSString *)notice
{
    if ([delegate respondsToSelector:@selector(didReceivePaymentNotice:)]) {
        [delegate didReceivePaymentNotice:notice];
    } else {
        DLog(@"Delegate of class %@ does not respond to selector didReceivePaymentNotice!", [delegate class]);
    }
}

- (void)on_generate_key
{
    DLog(@"on_generate_key");
    if ([delegate respondsToSelector:@selector(didGenerateNewAddress)]) {
        [delegate didGenerateNewAddress];
    } else {
        DLog(@"Error: delegate of class %@ does not respond to selector didGenerateNewAddress!", [delegate class]);
    }
}

- (void)on_error_creating_new_address:(NSString*)error
{
    DLog(@"on_error_creating_new_address");
    [app standardNotify:error];
}

- (void)on_add_new_account
{
    DLog(@"on_add_new_account");
    
    [self subscribeToXPub:[self getXpubForAccount:[self getActiveAccountsCount] - 1]];
    
    [app showBusyViewWithLoadingText:BC_STRING_LOADING_SYNCING_WALLET];
}

- (void)on_error_add_new_account:(NSString*)error
{
    DLog(@"on_error_generating_new_address");
    [app standardNotify:error];
}

- (void)on_success_get_recovery_phrase:(NSString*)phrase
{
    DLog(@"on_success_get_recovery_phrase:");
    self.recoveryPhrase = phrase;
}

- (void)on_success_recover_with_passphrase:(NSDictionary *)recoveredWalletDictionary
{
    DLog(@"on_recover_with_passphrase_success_guid:sharedKey:password:");
    
    if ([delegate respondsToSelector:@selector(didRecoverWallet)]) {
        [delegate didRecoverWallet];
    } else {
        DLog(@"Error: delegate of class %@ does not respond to selector didRecoverWallet!", [delegate class]);
    }
    
    [self loadWalletWithGuid:recoveredWalletDictionary[@"guid"] sharedKey:recoveredWalletDictionary[@"sharedKey"] password:recoveredWalletDictionary[@"password"]];
}

- (void)on_error_recover_with_passphrase:(NSString *)error
{
    DLog(@"on_error_recover_with_passphrase:");
    [self loading_stop];
    if ([error isEqualToString:ERROR_INVALID_PASSPHRASE]) {
        [app standardNotifyAutoDismissingController:BC_STRING_INVALID_RECOVERY_PHRASE];
    } else if ([error isEqualToString:@""]) {
        [app standardNotifyAutoDismissingController:BC_STRING_NO_INTERNET_CONNECTION];
    } else if ([error isEqualToString:ERROR_TIMEOUT_REQUEST]){
        [app standardNotifyAutoDismissingController:BC_STRING_TIMED_OUT];
    } else {
        [app standardNotifyAutoDismissingController:error];
    }
    if ([delegate respondsToSelector:@selector(didFailRecovery)]) {
        [delegate didFailRecovery];
    } else {
        DLog(@"Error: delegate of class %@ does not respond to selector didFailRecovery!", [delegate class]);
    }
}

- (void)on_progress_recover_with_passphrase:(NSString *)totalReceived finalBalance:(NSString *)finalBalance
{
    uint64_t fundsInAccount = [finalBalance longLongValue];
    
    if ([totalReceived longLongValue] == 0) {
        self.emptyAccountIndex++;
        [app updateBusyViewLoadingText:[NSString stringWithFormat:BC_STRING_LOADING_RECOVERING_WALLET_CHECKING_ARGUMENT_OF_ARGUMENT, self.emptyAccountIndex, self.emptyAccountIndex > RECOVERY_ACCOUNT_DEFAULT_NUMBER ? self.emptyAccountIndex : RECOVERY_ACCOUNT_DEFAULT_NUMBER]];
    } else {
        self.emptyAccountIndex = 0;
        self.recoveredAccountIndex++;
        [app updateBusyViewLoadingText:[NSString stringWithFormat:BC_STRING_LOADING_RECOVERING_WALLET_ARGUMENT_FUNDS_ARGUMENT, self.recoveredAccountIndex, [NSNumberFormatter formatMoney:fundsInAccount]]];
    }
}

- (void)on_error_downloading_account_settings
{
    DLog(@"on_error_downloading_account_settings");
    [app standardNotify:BC_STRING_SETTINGS_ERROR_LOADING_MESSAGE title:BC_STRING_SETTINGS_ERROR_LOADING_TITLE];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:USER_DEFAULTS_KEY_LOADED_SETTINGS];
}

- (void)on_update_email_error
{
    [app standardNotify:BC_STRING_INVALID_EMAIL_ADDRESS title:BC_STRING_ERROR];
}

- (void)on_error_get_history:(NSString *)error
{
    [self loading_stop];
    if ([self.delegate respondsToSelector:@selector(didFailGetHistory:)]) {
        [self.delegate didFailGetHistory:error];
    }
}

- (void)on_resend_two_factor_sms_success
{
    [app verifyTwoFactorSMS];
}

- (void)on_resend_two_factor_sms_error:(NSString *)error
{
    [app standardNotifyAutoDismissingController:error];
}

- (void)wrong_two_factor_code:(NSString *)error
{
    self.twoFactorInput = nil;
    [app standardNotifyAutoDismissingController:error];
}

- (void)on_change_notifications_success
{
    DLog(@"on_change_notifications_success");
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_CHANGE_NOTIFICATIONS_SUCCESS object:nil];
}

- (void)on_change_notifications_error
{
    DLog(@"on_change_notifications_error");
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_CHANGE_NOTIFICATIONS_ERROR object:nil];
}

- (void)return_to_addresses_screen
{
    DLog(@"return_to_addresses_screen");
    if ([self.delegate respondsToSelector:@selector(returnToAddressesScreen)]) {
        [self.delegate returnToAddressesScreen];
    }
}

- (void)on_error_account_name_in_use
{
    DLog(@"on_error_account_name_in_use");
    if ([self.delegate respondsToSelector:@selector(alertUserOfInvalidAccountName)]) {
        [self.delegate alertUserOfInvalidAccountName];
    }
}

- (void)on_success_import_key_for_sending_from_watch_only
{
    [self loading_stop];
    
    DLog(@"on_success_import_key_for_sending_from_watch_only");
    if ([self.delegate respondsToSelector:@selector(sendFromWatchOnlyAddress)]) {
        [self.delegate sendFromWatchOnlyAddress];
    }
}

- (void)on_error_import_key_for_sending_from_watch_only:(NSString *)error
{
    [self loading_stop];
    
    DLog(@"on_error_import_key_for_sending_from_watch_only");
    if ([error isEqualToString:ERROR_WRONG_PRIVATE_KEY]) {
        if ([self.delegate respondsToSelector:@selector(alertUserOfInvalidPrivateKey)]) {
            [self.delegate alertUserOfInvalidPrivateKey];
        }
    } else if ([error isEqualToString:ERROR_WRONG_BIP_PASSWORD]) {
        [app standardNotifyAutoDismissingController:BC_STRING_WRONG_BIP38_PASSWORD];
    } else {
        [app standardNotifyAutoDismissingController:error];
    }
}

- (void)update_send_balance:(NSNumber *)balance fees:(NSDictionary *)fees
{
    DLog(@"update_send_balance");
    if ([self.delegate respondsToSelector:@selector(updateSendBalance:fees:)]) {
        [self.delegate updateSendBalance:balance fees:fees];
    }
}

- (void)update_transfer_all_amount:(NSNumber *)amount fee:(NSNumber *)fee addressesUsed:(NSArray *)addressesUsed
{
    DLog(@"update_transfer_all_amount:fee:");
    
    if ([self.delegate respondsToSelector:@selector(updateTransferAllAmount:fee:addressesUsed:)]) {
        [self.delegate updateTransferAllAmount:amount fee:fee addressesUsed:addressesUsed];
    }
}

- (void)on_error_transfer_all:(NSString *)error secondPassword:(NSString *)secondPassword
{
    DLog(@"on_error_transfer_all");
    if ([self.delegate respondsToSelector:@selector(didErrorDuringTransferAll:secondPassword:)]) {
        [self.delegate didErrorDuringTransferAll:error secondPassword:secondPassword];
    }
}

- (void)show_summary_for_transfer_all
{
    DLog(@"show_summary_for_transfer_all");
    if ([self.delegate respondsToSelector:@selector(showSummaryForTransferAll)]) {
        [self.delegate showSummaryForTransferAll];
    }
}

- (void)send_transfer_all:(NSString *)secondPassword
{
    DLog(@"send_transfer_all");
    if ([self.delegate respondsToSelector:@selector(sendDuringTransferAll:)]) {
        [self.delegate sendDuringTransferAll:secondPassword];
    }
}

- (void)update_loaded_all_transactions:(NSNumber *)loadedAll
{
    DLog(@"loaded_all_transactions");
    
    if ([self.delegate respondsToSelector:@selector(updateLoadedAllTransactions:)]) {
        [self.delegate updateLoadedAllTransactions:loadedAll];
    }
}

- (void)on_get_session_token:(NSString *)token
{
    DLog(@"on_get_session_token:");
    self.sessionToken = token;
}

- (void)show_email_authorization_alert
{
    DLog(@"show_email_authorization_alert");
    [app authorizationRequired];
}

- (void)on_get_fiat_at_time_success:(NSNumber *)fiatAmount currencyCode:(NSString *)currencyCode assetType:(AssetType)assetType
{
    DLog(@"on_get_fiat_at_time_success");
    if ([self.delegate respondsToSelector:@selector(didGetFiatAtTime:currencyCode:assetType:)]) {
        [self.delegate didGetFiatAtTime:fiatAmount currencyCode:currencyCode assetType:assetType];
    } else {
        DLog(@"Error: delegate of class %@ does not respond to selector didGetFiatAtTime:currencyCode!", [delegate class]);
    }
}

- (void)on_get_fiat_at_time_error:(NSString *)error
{
    DLog(@"on_get_fiat_at_time_error");
    if ([self.delegate respondsToSelector:@selector(didErrorWhenGettingFiatAtTime:)]) {
        [self.delegate didErrorWhenGettingFiatAtTime:error];
    } else {
        DLog(@"Error: delegate of class %@ does not respond to selector didErrorWhenGettingFiatAtTime!", [delegate class]);
    }
}

- (void)on_create_invitation_success:(JSValue *)invitation
{
    DLog(@"on_create_invitation_success");
    if ([self.delegate respondsToSelector:@selector(didCreateInvitation:)]) {
        [self.delegate didCreateInvitation:[invitation toDictionary]];
    } else {
        DLog(@"Error: delegate of class %@ does not respond to selector didCreateInvitation!", [delegate class]);
    }
}

- (void)on_create_invitation_error:(JSValue *)error
{
    DLog(@"on_create_invitation_error");
    
    [app hideBusyView];
    
    [app standardNotify:[error toString]];
}

- (void)on_read_invitation_success:(JSValue *)invitation identifier:(NSString *)identifier
{
    DLog(@"on_read_invitation_success");
    if ([self.delegate respondsToSelector:@selector(didReadInvitation:identifier:)]) {
        [self.delegate didReadInvitation:[invitation toDictionary] identifier:identifier];
    } else {
        DLog(@"Error: delegate of class %@ does not respond to selector didReadInvitation!", [delegate class]);
    }
}

- (void)on_complete_relation_success
{
    DLog(@"on_read_invitation_sent_success");
    if ([self.delegate respondsToSelector:@selector(didCompleteRelation)]) {
        [self.delegate didCompleteRelation];
    } else {
        DLog(@"Error: delegate of class %@ does not respond to selector didReadInvitationSent!", [delegate class]);
    }
}

- (void)on_accept_relation_error:(NSString *)name
{
    DLog(@"on_accept_relation_error");
    if ([self.delegate respondsToSelector:@selector(didFailAcceptRelation:)]) {
        [self.delegate didFailAcceptRelation:name];
    } else {
        DLog(@"Error: delegate of class %@ does not respond to selector didFailAcceptRelation!", [delegate class]);
    }
}

- (void)on_complete_relation_error
{
    DLog(@"on_complete_relation_error");
    if ([self.delegate respondsToSelector:@selector(didFailCompleteRelation)]) {
        [self.delegate didFailCompleteRelation];
    } else {
        DLog(@"Error: delegate of class %@ does not respond to selector didFailCompleteRelation!", [delegate class]);
    }
}

- (void)on_accept_relation_success:(NSString *)invitation name:(NSString *)name
{
    DLog(@"on_accept_relation_success");
    if ([self.delegate respondsToSelector:@selector(didAcceptRelation:name:)]) {
        [self.delegate didAcceptRelation:invitation name:name];
    } else {
        DLog(@"Error: delegate of class %@ does not respond to selector didAcceptInvitation!", [delegate class]);
    }
}

- (void)on_fetch_xpub_success:(NSString *)xpub
{
    DLog(@"on_fetch_xpub_success");
    if ([self.delegate respondsToSelector:@selector(didFetchExtendedPublicKey)]) {
        [self.delegate didFetchExtendedPublicKey];
    } else {
        DLog(@"Error: delegate of class %@ does not respond to selector didFetchExtendedPublicKey!", [delegate class]);
    }
}

- (void)on_get_messages_success:(JSValue *)messages firstLoad:(JSValue *)isFirstLoad
{
    DLog(@"on_get_messages_success");
    [self getUpdatedContacts:[isFirstLoad toBool] newMessages:[messages toArray]];
}

- (void)on_get_messages_error:(NSString *)error
{
    DLog(@"on_get_messages_error");
    [self getUpdatedContacts:NO newMessages:nil];
}

- (void)on_send_payment_request_success:(JSValue *)info amount:(JSValue *)intendedAmount identifier:(JSValue *)userId requestId:(JSValue *)requestId
{
    DLog(@"on_send_payment_request_success");
    
    [self getMessages];

    if ([self.delegate respondsToSelector:@selector(didSendPaymentRequest:amount:name:requestId:)]) {
        [self.delegate didSendPaymentRequest:[info toDictionary]
                                      amount:[[intendedAmount toNumber] longLongValue]
                                        name:[app.wallet.contacts objectForKey:[userId toString]].name
                                   requestId:[requestId isUndefined] ? nil : [requestId toString]];
    } else {
        DLog(@"Error: delegate of class %@ does not respond to selector didSendPaymentRequest:name:!", [delegate class]);
    }
}

- (void)on_send_payment_request_error:(JSValue *)error
{
    DLog(@"on_send_payment_request_error");
    
    [app hideBusyView];
    
    NSString *message = [error toString];
    
    if ([message containsString:ERROR_GAP]) {
        message = BC_STRING_CONTACTS_TOO_MANY_OPEN_REQUESTS;
    }
    
    [app standardNotify:message];
}

- (void)on_request_payment_request_error:(JSValue *)error
{
    DLog(@"on_request_payment_request_error");
    
    NSString *message = [error toString];
    
    if ([message containsString:ERROR_GAP]) {
        message = BC_STRING_CONTACTS_TOO_MANY_OPEN_REQUESTS;
    }
    
    [app standardNotify:[error toString]];
}

- (void)on_send_payment_request_response_error:(JSValue *)error
{
    DLog(@"on_send_payment_request_response_error");
    
    [app hideBusyView];
    [app standardNotify:[error toString]];
}

- (void)on_request_payment_request_success:(JSValue *)info identifier:(JSValue *)userId
{
    DLog(@"on_request_payment_request_success");
    
    [self getMessages];

    if ([self.delegate respondsToSelector:@selector(didRequestPaymentRequest:name:)]) {
        [self.delegate didRequestPaymentRequest:[info toDictionary] name:[app.wallet.contacts objectForKey:[userId toString]].name];
    } else {
        DLog(@"Error: delegate of class %@ does not respond to selector didRequestPaymentRequest:name!", [delegate class]);
    }
}

- (void)on_send_payment_request_response_success:(JSValue *)info
{
    DLog(@"on_send_payment_request_response_success");
    
    if ([self.delegate respondsToSelector:@selector(didSendPaymentRequestResponse)]) {
        [self.delegate didSendPaymentRequestResponse];
    } else {
        DLog(@"Error: delegate of class %@ does not respond to selector didSendPaymentRequestResponse!", [delegate class]);
    }
}

- (void)on_change_contact_name_success:(JSValue *)info
{
    DLog(@"on_change_contact_name_success");
    
    if ([self.delegate respondsToSelector:@selector(didChangeContactName:)]) {
        [self.delegate didChangeContactName:[info toDictionary]];
    } else {
        DLog(@"Error: delegate of class %@ does not respond to selector didChangeContactName!", [delegate class]);
    }
}

- (void)on_send_cancellation_success
{
    DLog(@"on_send_cancellation_success");
    
    if ([self.delegate respondsToSelector:@selector(didRejectContactTransaction)]) {
        [self.delegate didRejectContactTransaction];
    } else {
        DLog(@"Error: delegate of class %@ does not respond to selector didRejectContactTransaction!", [delegate class]);
    }
}

- (void)on_send_cancellation_error:(JSValue *)info
{
    DLog(@"on_send_cancellation_error");
}

- (void)on_send_declination_success
{
    DLog(@"on_send_declination_success");

    if ([self.delegate respondsToSelector:@selector(didRejectContactTransaction)]) {
        [self.delegate didRejectContactTransaction];
    } else {
        DLog(@"Error: delegate of class %@ does not respond to selector didRejectContactTransaction!", [delegate class]);
    }
}

- (void)on_send_declination_error:(JSValue *)info
{
    DLog(@"on_send_declination_error");
}

- (void)on_delete_contact_success:(JSValue *)info
{
    DLog(@"on_delete_contact_success");

    if ([self.delegate respondsToSelector:@selector(didDeleteContact:)]) {
        [self.delegate didDeleteContact:[info toDictionary]];
    } else {
        DLog(@"Error: delegate of class %@ does not respond to selector didDeleteContact!", [delegate class]);
    }
}

- (void)on_delete_contact_after_storing_info_success:(JSValue *)info
{
    DLog(@"on_delete_contact_after_storing_info_success");
    
    if ([self.delegate respondsToSelector:@selector(didDeleteContactAfterStoringInfo:)]) {
        [self.delegate didDeleteContactAfterStoringInfo:[info toDictionary]];
    } else {
        DLog(@"Error: delegate of class %@ does not respond to selector didDeleteContactAfterStoringInfo!", [delegate class]);
    }
}

- (void)did_archive_or_unarchive
{
    DLog(@"did_archive_or_unarchive");
    
    [self.webSocket closeWithCode:WEBSOCKET_CODE_ARCHIVE_UNARCHIVE reason:WEBSOCKET_CLOSE_REASON_ARCHIVED_UNARCHIVED];
}

- (void)did_get_swipe_addresses:(NSArray *)swipeAddresses
{
    DLog(@"did_get_swipe_addresses");
    
    if ([self.delegate respondsToSelector:@selector(didGetSwipeAddresses:)]) {
        [self.delegate didGetSwipeAddresses:swipeAddresses];
    } else {
        DLog(@"Error: delegate of class %@ does not respond to selector didGetSwipeAddresses!", [delegate class]);
    }
}

- (void)show_completed_trade:(JSValue *)trade
{
    NSDictionary *tradeDict = [trade toDictionary];
    DLog(@"show_completed_trade %@", tradeDict);
    
    if ([self.delegate respondsToSelector:@selector(didCompleteTrade:)]) {
        [self.delegate didCompleteTrade:tradeDict];
    } else {
        DLog(@"Error: delegate of class %@ does not respond to selector didCompleteTrade:!", [delegate class]);
    }
}

- (void)on_get_pending_trades_error:(JSValue *)error
{
    [app standardNotify:[error toString]];
}

- (void)initialize_webview
{
    [app initializeWebview];
}

- (void)on_fetch_eth_history_success
{
    if ([self.delegate respondsToSelector:@selector(didFetchEthHistory)]) {
        [self.delegate didFetchEthHistory];
    } else {
        DLog(@"Error: delegate of class %@ does not respond to selector didFetchEthHistory!", [delegate class]);
    }
}

- (void)on_fetch_eth_history_error:(NSString *)error
{
    
}

- (void)on_create_eth_account_for_exchange_success
{
    if ([self.delegate respondsToSelector:@selector(didCreateEthAccountForExchange)]) {
        [self.delegate didCreateEthAccountForExchange];
    } else {
        DLog(@"Error: delegate of class %@ does not respond to selector didCreateEthAccountForExchange!", [delegate class]);
    }
}

- (void)on_update_eth_payment:(NSDictionary *)payment
{
    if ([self.delegate respondsToSelector:@selector(didUpdateEthPayment:)]) {
        [self.delegate didUpdateEthPayment:payment];
    } else {
        DLog(@"Error: delegate of class %@ does not respond to selector didUpdateEthPayment!", [delegate class]);
    }
}

- (void)on_fetch_eth_exchange_rate_success:(JSValue *)rate code:(JSValue *)code
{
    if ([self.delegate respondsToSelector:@selector(didFetchEthExchangeRate:)]) {
        NSDictionary *codeDict = [[rate toDictionary] objectForKey:[code toString]];
        self.latestEthExchangeRate = [NSDecimalNumber decimalNumberWithDecimal:[[codeDict objectForKey:DICTIONARY_KEY_LAST] decimalValue]];
        [self.delegate didFetchEthExchangeRate:self.latestEthExchangeRate];
    } else {
        DLog(@"Error: delegate of class %@ does not respond to selector didUpdateEthPayment!", [delegate class]);
    }
}

- (void)eth_socket_send:(NSString *)message
{
    if (self.ethSocket && self.ethSocket.readyState == SR_OPEN) {
        DLog(@"Sending eth socket message %@", message);
        [self sendEthSocketMessage:message];
    } else {
        DLog(@"Will send eth socket message %@", message);
        [self.pendingEthSocketMessages insertObject:message atIndex:0];
        [self.ethSocket open];
    }
}

- (void)sendEthSocketMessage:(NSString *)message
{
    NSError *error;
    [self.ethSocket sendString:message error:&error];
    if (error) DLog(@"Error sending eth socket message: %@", [error localizedDescription]);
}

- (void)on_send_ether_payment_success
{
    if ([self.delegate respondsToSelector:@selector(didSendEther)]) {
        [self.delegate didSendEther];
    } else {
        DLog(@"Error: delegate of class %@ does not respond to selector didSendEther!", [delegate class]);
    }
}

- (void)on_send_ether_payment_error:(JSValue *)error
{
    if ([self.delegate respondsToSelector:@selector(didErrorDuringEtherSend:)]) {
        [self.delegate didErrorDuringEtherSend:[error toString]];
    } else {
        DLog(@"Error: delegate of class %@ does not respond to selector didErrorDuringEtherSend!", [delegate class]);
    }
}

- (void)did_get_ether_address_with_second_password
{
    if ([self.delegate respondsToSelector:@selector(didGetEtherAddressWithSecondPassword)]) {
        [self.delegate didGetEtherAddressWithSecondPassword];
    } else {
        DLog(@"Error: delegate of class %@ does not respond to selector didGetEtherAddressWithSecondPassword!", [delegate class]);
    }
}

- (void)on_get_exchange_trades_success:(NSArray *)trades
{
    NSMutableArray *exchangeTrades = [NSMutableArray new];
    for (NSDictionary *trade in trades) {
        ExchangeTrade *exchangeTrade = [ExchangeTrade fetchedTradeFromJSONDict:trade];
        [exchangeTrades addObject:exchangeTrade];
    }
    
    if ([self.delegate respondsToSelector:@selector(didGetExchangeTrades:)]) {
        [self.delegate didGetExchangeTrades:exchangeTrades];
    } else {
        DLog(@"Error: delegate of class %@ does not respond to selector didGetExchangeTrades:!", [delegate class]);
    }
}

- (void)on_get_exchange_rate_success:(NSDictionary *)result
{
    NSNumber *btcRateNumber = [[[self.context evaluateScript:@"MyWalletPhone.currencyCodeForHardLimit()"] toString] isEqualToString:CURRENCY_CODE_USD] ? [[[app.wallet currencySymbols] objectForKey:CURRENCY_CODE_USD] objectForKey:DICTIONARY_KEY_LAST] : [[[app.wallet currencySymbols] objectForKey:CURRENCY_CODE_EUR] objectForKey:DICTIONARY_KEY_LAST];
    
    NSDecimalNumber *btcRate = [NSDecimalNumber decimalNumberWithDecimal:[btcRateNumber decimalValue]];
    NSDecimalNumber *ethRate = [NSDecimalNumber decimalNumberWithString:[result objectForKey:DICTIONARY_KEY_ETH_HARD_LIMIT_RATE]];
    
    NSDecimalNumber *fiatHardLimit = [NSDecimalNumber decimalNumberWithString:[[self.context evaluateScript:@"MyWalletPhone.fiatExchangeHardLimit()"] toString]];
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setMaximumFractionDigits:8];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [numberFormatter setLocale:[NSLocale localeWithLocaleIdentifier:LOCALE_IDENTIFIER_EN_US]];
    
    NSString *btcHardLimit = [numberFormatter stringFromNumber:[fiatHardLimit decimalNumberByDividingBy:btcRate]];
    NSString *ethHardLimit = [numberFormatter stringFromNumber:[fiatHardLimit decimalNumberByDividingBy:ethRate]];
    
    NSMutableDictionary *mutableCopy = [result mutableCopy];
    [mutableCopy setObject:btcHardLimit forKey:DICTIONARY_KEY_BTC_HARD_LIMIT];
    [mutableCopy setObject:ethHardLimit forKey:DICTIONARY_KEY_ETH_HARD_LIMIT];

    if ([self.delegate respondsToSelector:@selector(didGetExchangeRate:)]) {
        [self.delegate didGetExchangeRate:mutableCopy];
    } else {
        DLog(@"Error: delegate of class %@ does not respond to selector didGetExchangeRate:!", [delegate class]);
    }
}

- (void)on_get_available_btc_balance_success:(NSDictionary *)result
{
    if ([self.delegate respondsToSelector:@selector(didGetAvailableBtcBalance:)]) {
        [self.delegate didGetAvailableBtcBalance:result];
    } else {
        DLog(@"Error: delegate of class %@ does not respond to selector didGetAvailableBtcBalance:!", [delegate class]);
    }
}

- (void)on_get_available_balance_error:(NSString *)error symbol:(NSString *)currencySymbol
{
    if ([error isEqualToString:ERROR_NO_FREE_OUTPUTS_TO_SPEND]) {
        [self.delegate didGetAvailableBtcBalance:nil];
    } else {
        [app standardNotify:[NSString stringWithFormat:BC_STRING_ERROR_GETTING_BALANCE_ARGUMENT_ASSET_ARGUMENT_MESSAGE, currencySymbol, error]];
    }
}

- (void)on_get_available_eth_balance_success:(NSDictionary *)result
{
    if ([self.delegate respondsToSelector:@selector(didGetAvailableEthBalance:)]) {
        [self.delegate didGetAvailableEthBalance:result];
    } else {
        DLog(@"Error: delegate of class %@ does not respond to selector didGetAvailableEthBalance:!", [delegate class]);
    }
}

- (void)on_shift_payment_success:(NSDictionary *)result
{
    if ([self.delegate respondsToSelector:@selector(didShiftPayment:)]) {
        [self.delegate didShiftPayment:result];
    } else {
        DLog(@"Error: delegate of class %@ does not respond to selector didShiftPayment:!", [delegate class]);
    }
}

- (void)on_shift_payment_error:(NSDictionary *)result
{
    [app hideBusyView];
    
    NSString *errorMessage = [result objectForKey:DICTIONARY_KEY_MESSAGE];
    [app standardNotify:errorMessage];
}

- (void)on_build_exchange_trade_success_from:(NSString *)from depositAmount:(NSString *)depositAmount fee:(NSNumber *)fee rate:(NSString *)rate minerFee:(NSString *)minerFee withdrawalAmount:(NSString *)withdrawalAmount expiration:(NSDate *)expirationDate
{
    NSDictionary *tradeInfo = @{
        DICTIONARY_KEY_DEPOSIT_AMOUNT : depositAmount,
        DICTIONARY_KEY_FEE : [[from lowercaseString] isEqualToString:[CURRENCY_SYMBOL_BTC lowercaseString]] ? [NSNumberFormatter satoshiToBTC:[fee longLongValue]] : [fee stringValue],
        DICTIONARY_KEY_RATE : rate,
        DICTIONARY_KEY_MINER_FEE : minerFee,
        DICTIONARY_KEY_WITHDRAWAL_AMOUNT : withdrawalAmount,
        DICTIONARY_KEY_EXPIRATION_DATE : expirationDate
    };
    
    if ([self.delegate respondsToSelector:@selector(didBuildExchangeTrade:)]) {
        [self.delegate didBuildExchangeTrade:tradeInfo];
    } else {
        DLog(@"Error: delegate of class %@ does not respond to selector didBuildExchangeTrade:!", [delegate class]);
    }
}

# pragma mark - Calls from Obj-C to JS for HD wallet

- (void)upgradeToV3Wallet
{
    if (![self isInitialized]) {
        return;
    }
    
    DLog(@"Creating HD Wallet");
    [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.upgradeToV3(\"%@\");", NSLocalizedString(@"My Bitcoin Wallet", nil)]];
}

- (Boolean)hasAccount
{
    if (![self isInitialized]) {
        return NO;
    }
    
    return [[self.context evaluateScript:@"MyWallet.wallet.isUpgradedToHD"] toBool];
}

- (Boolean)didUpgradeToHd
{
    if (![self isInitialized]) {
        return NO;
    }
    
    return [[self.context evaluateScript:@"MyWallet.wallet.isUpgradedToHD"] toBool];
}

- (void)getRecoveryPhrase:(NSString *)secondPassword;
{
    if (![self isInitialized]) {
        return;
    }
    
    [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.getRecoveryPhrase(\"%@\")", [secondPassword escapeStringForJS]]];
}

- (BOOL)isRecoveryPhraseVerified {
    if (![self isInitialized]) {
        return NO;
    }
    
    if (![self didUpgradeToHd]) {
        return NO;
    }
    
    return [[self.context evaluateScript:@"MyWallet.wallet.hdwallet.isMnemonicVerified"] toBool];
}

- (void)markRecoveryPhraseVerified
{
    if (![self isInitialized]) {
        return;
    }
    
    [self.context evaluateScript:@"MyWallet.wallet.hdwallet.verifyMnemonic()"];
}

- (int)getActiveAccountsCount
{
    if (![self isInitialized]) {
        return 0;
    }
    
    return [[[self.context evaluateScript:@"MyWalletPhone.getActiveAccountsCount()"] toNumber] intValue];
}

- (int)getAllAccountsCount
{
    if (![self isInitialized]) {
        return 0;
    }
    
    return [[[self.context evaluateScript:@"MyWalletPhone.getAllAccountsCount()"] toNumber] intValue];
}

- (int)getFilteredOrDefaultAccountIndex
{
    if (![self isInitialized]) {
        return 0;
    }
    
    NSInteger filterIntex = [app filterIndex];
    
    if (filterIntex != FILTER_INDEX_ALL && filterIntex!= FILTER_INDEX_IMPORTED_ADDRESSES && 0 <= filterIntex < [self getActiveAccountsCount]) {
        return (int)filterIntex;
    }
    
    return [[self.context evaluateScript:@"MyWalletPhone.getDefaultAccountIndex()"] toInt32];
}

- (int)getDefaultAccountIndex
{
    if (![self isInitialized]) {
        return 0;
    }
    
    return [[[self.context evaluateScript:@"MyWalletPhone.getDefaultAccountIndex()"] toNumber] intValue];
}

- (void)setDefaultAccount:(int)index
{
    if (![self isInitialized]) {
        return;
    }
    
    [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.setDefaultAccount(%d)", index]];
    
    self.isSettingDefaultAccount = YES;
}

- (BOOL)hasLegacyAddresses
{
    if (![self isInitialized]) {
        return false;
    }
    
    return [[self.context evaluateScript:@"MyWallet.wallet.addresses.length > 0"] toBool];
}

- (uint64_t)getTotalActiveBalance
{
    if (![self isInitialized]) {
        return 0;
    }
    
    return [[[self.context evaluateScript:@"MyWallet.wallet.balanceActive"] toNumber] longLongValue];
}

- (uint64_t)getTotalBalanceForActiveLegacyAddresses
{
    if (![self isInitialized]) {
        return 0;
    }
    
    return [[[self.context evaluateScript:@"MyWallet.wallet.balanceActiveLegacy"] toNumber] longLongValue];
}

- (uint64_t)getTotalBalanceForSpendableActiveLegacyAddresses
{
    if (![self isInitialized]) {
        return 0;
    }
    
    return [[[self.context evaluateScript:@"MyWallet.wallet.balanceSpendableActiveLegacy"] toNumber] longLongValue];
}

- (uint64_t)getBalanceForAccount:(int)account
{
    if (![self isInitialized]) {
        return 0;
    }
    
    return [[[self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.getBalanceForAccount(%d)", account]] toNumber] longLongValue];
}

- (NSString *)getLabelForAccount:(int)account
{
    if (![self isInitialized]) {
        return nil;
    }
    
    return [[self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.getLabelForAccount(%d)", account]] toString];
}

- (void)setLabelForAccount:(int)account label:(NSString *)label
{
    if ([self isInitialized] && [app checkInternetConnection]) {
        self.isSyncing = YES;
        
        [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.setLabelForAccount(%d, \"%@\")", account, [label escapeStringForJS]]];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSetLabelForAccount) name:NOTIFICATION_KEY_BACKUP_SUCCESS object:nil];
    }
}

- (void)didSetLabelForAccount
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_KEY_BACKUP_SUCCESS object:nil];
    
    [self getHistory];
}

- (void)createAccountWithLabel:(NSString *)label
{
    if ([self isInitialized] && [app checkInternetConnection]) {
        // Show loading text
        [self loading_start_create_account];
        
        self.isSyncing = YES;
        
        // Wait a little bit to make sure the loading text is showing - then execute the blocking and kind of long create account
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(ANIMATION_DURATION * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.createAccount(\"%@\")", [label escapeStringForJS]]];
        });
    }
}

- (NSString *)getReceiveAddressOfDefaultAccount
{
    return [[self.context evaluateScript:@"MyWalletPhone.getReceiveAddressOfDefaultAccount()"] toString];
}

- (NSString *)getReceiveAddressForAccount:(int)account
{
    if (![self isInitialized]) {
        return nil;
    }
    
    return [[self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.getReceivingAddressForAccount(%d)", account]] toString];
}

- (void)setPbkdf2Iterations:(int)iterations
{
    DLog(@"Setting PBKDF2 Iterations");
    
    [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.setPbkdf2Iterations(%d)", iterations]];
}

#pragma mark - Callbacks from JS to Obj-C for HD wallet

- (void)reload
{
    DLog(@"reload");
    
    [app reload];
}

- (void)logging_out
{
    DLog(@"logging_out");
    
    [app logoutAndShowPasswordModal];
}

#pragma mark - Callbacks from javascript localstorage

- (void)getKey:(NSString*)key success:(void (^)(NSString*))success
{
    id value = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    
    DLog(@"getKey:%@", key);
    
    success(value);
}

- (void)saveKey:(NSString*)key value:(NSString*)value
{
    DLog(@"saveKey:%@", key);
    
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)removeKey:(NSString*)key
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)clearKeys
{
    NSString * appDomain = [[NSBundle mainBundle] bundleIdentifier];
    
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

# pragma mark - Cyrpto helpers, called from JS

- (void)crypto_scrypt:(id)_password salt:(id)salt n:(NSNumber*)N r:(NSNumber*)r p:(NSNumber*)p dkLen:(NSNumber*)derivedKeyLen success:(JSValue *)_success error:(JSValue *)_error
{
    [app showBusyViewWithLoadingText:BC_STRING_DECRYPTING_PRIVATE_KEY];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData * data = [self _internal_crypto_scrypt:_password salt:salt n:[N unsignedLongLongValue] r:[r unsignedIntValue] p:[p unsignedIntValue] dkLen:[derivedKeyLen unsignedIntValue]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data) {
                [_success callWithArguments:@[[data hexadecimalString]]];
            } else {
                [app hideBusyView];
                [_error callWithArguments:@[@"Scrypt Error"]];
            }
        });
    });
}

- (NSData*)_internal_crypto_scrypt:(id)_password salt:(id)_salt n:(uint64_t)N r:(uint32_t)r p:(uint32_t)p dkLen:(uint32_t)derivedKeyLen
{
    uint8_t * _passwordBuff = NULL;
    size_t _passwordBuffLen = 0;
    if ([_password isKindOfClass:[NSArray class]]) {
        _passwordBuff = alloca([_password count]);
        _passwordBuffLen = [_password count];
        
        {
            int ii = 0;
            for (NSNumber * number in _password) {
                _passwordBuff[ii] = [number shortValue];
                ++ii;
            }
        }
    } else if ([_password isKindOfClass:[NSString class]]) {
        const char *passwordUTF8String = [_password UTF8String];
        _passwordBuff = (uint8_t*)passwordUTF8String;
        _passwordBuffLen = strlen(passwordUTF8String);
    } else {
        DLog(@"Scrypt password unsupported type");
        return nil;
    }
    
    uint8_t * _saltBuff = NULL;
    size_t _saltBuffLen = 0;
    
    if ([_salt isKindOfClass:[NSArray class]]) {
        _saltBuff = alloca([_salt count]);
        _saltBuffLen = [_salt count];
        
        {
            int ii = 0;
            for (NSNumber * number in _salt) {
                _saltBuff[ii] = [number shortValue];
                ++ii;
            }
        }
    } else if ([_salt isKindOfClass:[NSString class]]) {
        const char *saltUTF8String = [_salt UTF8String];
        _saltBuff = (uint8_t*)saltUTF8String;
        _saltBuffLen = strlen(saltUTF8String);
    } else {
        DLog(@"Scrypt salt unsupported type");
        return nil;
    }
    
    uint8_t * derivedBytes = malloc(derivedKeyLen);
    
    if (crypto_scrypt((uint8_t*)_passwordBuff, _passwordBuffLen, (uint8_t*)_saltBuff, _saltBuffLen, N, r, p, derivedBytes, derivedKeyLen) == -1) {
        return nil;
    }
    
    return [NSData dataWithBytesNoCopy:derivedBytes length:derivedKeyLen];
}

#pragma mark - JS Exception handler

- (void)jsUncaughtException:(NSString*)message url:(NSString*)url lineNumber:(NSNumber*)lineNumber
{
    
    NSString * decription = [NSString stringWithFormat:@"Javscript Exception: %@ File: %@ lineNumber: %@", message, url, lineNumber];
    
#ifndef DEBUG
    NSException * exception = [[NSException alloc] initWithName:@"Uncaught Exception" reason:decription userInfo:nil];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul), ^{
        [UncaughtExceptionHandler logException:exception walletIsLoaded:YES walletIsInitialized:[self isInitialized]];
    });
#endif
    
    [app standardNotify:decription];
}

#pragma mark - Settings Helpers

- (BOOL)hasVerifiedEmail
{
    return [self getEmailVerifiedStatus];
}

- (BOOL)hasVerifiedMobileNumber
{
    return [self getSMSVerifiedStatus];
}

- (BOOL)hasEnabledTwoStep
{
    return [self getTwoStepType] != 0;
}

- (int)securityCenterScore
{
    if (self.isRecoveryPhraseVerified && [self hasEnabledTwoStep] && [self hasVerifiedEmail]) {
        return 2;
    } else if (self.isRecoveryPhraseVerified && [self hasEnabledTwoStep]) {
        return 2;
    } else if (self.isRecoveryPhraseVerified && [self hasVerifiedEmail]) {
        return 1;
    } else if ([self hasEnabledTwoStep] && [self hasVerifiedEmail]) {
        return 1;
    } else {
        return 0;
    }
}

- (int)securityCenterCompletedItemsCount
{
    int count = 0;
    
    if (self.isRecoveryPhraseVerified) count++;
    if ([self hasEnabledTwoStep]) count++;
    if ([self hasVerifiedEmail]) count++;
    
    return count;
}

#pragma mark - Debugging

- (void)useDebugSettingsIfSet
{
#ifdef ENABLE_DEBUG_MENU
    [self updateServerURL:URL_SERVER];
    
    [self updateWebSocketURL:URL_WEBSOCKET];
    
    [self updateAPIURL:URL_API];
    
    BOOL testnetOn = [[[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_KEY_ENV] isEqual:ENV_INDEX_TESTNET];
    NSString *network;
    if (testnetOn) {
        network = NETWORK_TESTNET;
    } else {
        network = NETWORK_MAINNET;
    }
    
    [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.changeNetwork(\"%@\")", [network escapeStringForJS]]];
#endif
}

@end
