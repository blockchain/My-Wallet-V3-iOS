
//
//  Wallet.m
//  Blockchain
//
//  Created by Ben Reeves on 16/03/2012.`
//  Copyright (c) 2012 Blockchain Luxembourg S.A. All rights reserved.
//

#import "Wallet.h"
#import "Transaction.h"
#import "EtherTransaction.h"
#import "MultiAddressResponse.h"
#import "UncaughtExceptionHandler.h"
#import "NSString+JSONParser_NSString.h"
#import "crypto_scrypt.h"
#import "NSData+Hex.h"
#import "TransactionsBitcoinViewController.h"
#import "NSArray+EncodedJSONString.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "ModuleXMLHttpRequest.h"
#import "KeychainItemWrapper+Credentials.h"
#import <openssl/evp.h>
#import "NSURLRequest+SRWebSocket.h"
#import <CommonCrypto/CommonKeyDerivation.h>
#import "HDNode.h"
#import "PrivateHeaders.h"
#import "Assets.h"
#import "ExchangeTrade.h"
#import "Blockchain-Swift.h"
#import "BTCKey.h"
#import "BTCData.h"
#import "KeyPair.h"
#import "NSData+BTCData.h"
#import "NSNumberFormatter+Currencies.h"

#define DICTIONARY_KEY_CURRENCY @"currency"

@interface Wallet ()
@property (nonatomic) JSContext *context;
@property (nonatomic) BOOL isSettingDefaultAccount;
@property (nonatomic) NSMutableDictionary *timers;
@property (nonatomic) NSDictionary *bitcoinCashExchangeRates;
@property (nonatomic) uint64_t bitcoinCashConversion;
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

    self.context[@"objc_on_error_pin_code_put_error"] = ^(NSString *error){
        [weakSelf on_error_pin_code_put_error:error];
    };

    self.context[@"objc_on_error_creating_new_account"] = ^(NSString *error) {
        [weakSelf on_error_creating_new_account:error];
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
        [weakSelf getSecondPasswordSuccess:secondPassword error:nil helperText:[helperText isUndefined] ? nil :  [helperText toString]];
    };

    self.context[@"objc_get_private_key_password"] = ^(JSValue *privateKeyPassword) {
        [weakSelf getPrivateKeyPasswordSuccess:privateKeyPassword error:nil];
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

    self.context[@"objc_did_get_btc_swipe_addresses"] = ^(NSArray *swipeAddresses) {
        [weakSelf did_get_swipe_addresses:swipeAddresses asset_type:LegacyAssetTypeBitcoin];
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

#pragma mark Settings
    
    self.context[@"objc_on_get_account_info_and_exchange_rates"] = ^() {
        [weakSelf on_get_account_info_and_exchange_rates];
    };
    
    self.context[@"objc_on_get_account_info_success"] = ^(NSString *accountInfo) {
        [weakSelf on_get_account_info_success:accountInfo];
    };
    
    self.context[@"objc_on_get_btc_exchange_rates_success"] = ^(NSString *currencies) {
        [weakSelf on_get_btc_exchange_rates_success:currencies];
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

#pragma mark Bitcoin Cash

    self.context[@"objc_on_fetch_bch_history_success"] = ^() {
        [weakSelf did_fetch_bch_history];
    };

    self.context[@"objc_on_fetch_bch_history_error"] = ^(JSValue *error) {
        [[AlertViewPresenter sharedInstance] standardNotifyWithMessage:[error toString] title:BC_STRING_ERROR in:nil handler: nil];
    };
    
    self.context[@"objc_did_get_bitcoin_cash_exchange_rates"] = ^(JSValue *result) {
        [weakSelf did_get_bitcoin_cash_exchange_rates:[result toDictionary]];
    };

    self.context[@"objc_did_get_bch_swipe_addresses"] = ^(NSArray *swipeAddresses) {
        [weakSelf did_get_swipe_addresses:swipeAddresses asset_type:LegacyAssetTypeBitcoinCash];
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
    _ethSocket = [[SRWebSocket alloc] initWithURLRequest:[self getWebSocketRequest:LegacyAssetTypeEther]];
    _ethSocket.delegate = self;
}

- (void)setupSocket:(LegacyAssetType)assetType
{
    if (assetType == LegacyAssetTypeBitcoin) {
        self.btcSocket = [[SRWebSocket alloc] initWithURLRequest:[self getWebSocketRequest:LegacyAssetTypeBitcoin]];
        self.btcSocket.delegate = self;

        [self.btcSocketTimer invalidate];
        self.btcSocketTimer = nil;
        self.btcSocketTimer = [NSTimer scheduledTimerWithTimeInterval:15.0
                                                               target:self
                                                             selector:@selector(pingBtcSocket)
                                                             userInfo:nil
                                                              repeats:YES];

        [self.btcSocket open];
    } else {
        self.bchSocket = [[SRWebSocket alloc] initWithURLRequest:[self getWebSocketRequest:LegacyAssetTypeBitcoinCash]];
        self.bchSocket.delegate = self;

        [self.bchSocketTimer invalidate];
        self.bchSocketTimer = nil;
        self.bchSocketTimer = [NSTimer scheduledTimerWithTimeInterval:15.0
                                                               target:self
                                                             selector:@selector(pingBchSocket)
                                                             userInfo:nil
                                                              repeats:YES];

        [self.bchSocket open];
    }
}

- (NSURLRequest *)getWebSocketRequest:(LegacyAssetType)assetType
{
    NSString *websocketURL;

    if (assetType == LegacyAssetTypeBitcoin) {
        websocketURL = [[BlockchainAPI sharedInstance] webSocketUri];
    } else if (assetType == LegacyAssetTypeEther) {
        websocketURL = [[BlockchainAPI sharedInstance] ethereumWebSocketUri];
    } else if (assetType == LegacyAssetTypeBitcoinCash) {
        websocketURL = [[BlockchainAPI sharedInstance] bitcoinCashWebSocketUri];
    }

    NSMutableURLRequest *webSocketRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:websocketURL]];
    [webSocketRequest addValue:[[BlockchainAPI sharedInstance] walletUrl] forHTTPHeaderField:@"Origin"];

    // TODO: migrate to CertificatePinner class
#if CERTIFICATE_PINNING == YES
    NSString *cerPath = [[CertificatePinner sharedInstance] localCertificatePath];
    NSData *certData = [[NSData alloc] initWithContentsOfFile:cerPath];
    CFDataRef certDataRef = (__bridge CFDataRef)certData;
    SecCertificateRef certRef = SecCertificateCreateWithData(NULL, certDataRef);
    id certificate = (__bridge id)certRef;

    [webSocketRequest setSR_SSLPinnedCertificates:@[certificate]];
    [webSocketRequest setSR_comparesPublicKeys:YES];

    CFRelease(certRef);
#endif

    return webSocketRequest;
}

- (void)pingBtcSocket
{
    if (self.btcSocket.readyState == 1) {
        NSError *error;
        [self.btcSocket sendPing:[@"{ op: \"ping\" }" dataUsingEncoding:NSUTF8StringEncoding] error:&error];
        if (error) DLog(@"Error sending ping: %@", [error localizedDescription]);
    } else {
        DLog(@"reconnecting websocket");
        [self setupSocket:LegacyAssetTypeBitcoin];
    }
}

- (void)pingBchSocket
{
    if (self.bchSocket.readyState == 1) {
        NSError *error;
        [self.bchSocket sendPing:[@"{ op: \"ping\" }" dataUsingEncoding:NSUTF8StringEncoding] error:&error];
        if (error) DLog(@"Error sending ping: %@", [error localizedDescription]);
    } else {
        DLog(@"reconnecting websocket");
        [self setupSocket:LegacyAssetTypeBitcoinCash];
    }
}

- (void)subscribeToXPub:(NSString *)xPub assetType:(LegacyAssetType)assetType
{
    SRWebSocket *socket = assetType == LegacyAssetTypeBitcoin ? self.btcSocket : self.bchSocket;

    if (socket && socket.readyState == 1) {
        NSError *error;
        [socket sendString:[NSString stringWithFormat:@"{\"op\":\"xpub_sub\",\"xpub\":\"%@\"}", xPub] error:&error];
        if (error) DLog(@"Error subscribing to xpub: %@", [error localizedDescription]);
    } else {
        [self setupSocket:assetType];
    }
}

- (void)subscribeToAddress:(NSString *)address assetType:(LegacyAssetType)assetType
{
    SRWebSocket *socket = assetType == LegacyAssetTypeBitcoin ? self.btcSocket : self.bchSocket;

    if (socket && socket.readyState == 1) {
        NSError *error;
        [socket sendString:[NSString stringWithFormat:@"{\"op\":\"addr_sub\",\"addr\":\"%@\"}", address] error:&error];
        if (error) DLog(@"Error subscribing to address: %@", [error localizedDescription]);
    } else {
        [self setupSocket:assetType];
    }
}

- (void)subscribeToSwipeAddress:(NSString *)address assetType:(LegacyAssetType)assetType
{
    if (assetType == LegacyAssetTypeBitcoin) {
        self.btcSwipeAddressToSubscribe = address;
    } else if (assetType == LegacyAssetTypeBitcoinCash) {
        self.bchSwipeAddressToSubscribe = address;
    }

    [self subscribeToAddress:address assetType:assetType];
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

        NSString *escapedSharedKey = self.sharedKey == nil ? @"" : [self.sharedKey escapedForJS];
        NSString *escapedSessionToken = self.sessionToken == nil ? @"" : [self.sessionToken escapedForJS];
        NSString *escapedTwoFactorInput = self.twoFactorInput == nil ? @"" : [self.twoFactorInput escapedForJS];

        [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.login(\"%@\", \"%@\", false, \"%@\", \"%@\", \"%@\")", [self.guid escapedForJS], escapedSharedKey, [self.password escapedForJS], escapedSessionToken, escapedTwoFactorInput]];
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
    return [NSNumberFormatter formatSatoshiInLocalCurrency:[WalletManager.sharedInstance.wallet getTotalActiveBalance]];
}

- (NSDecimalNumber *)ethDecimalBalance
{
    TabControllerManager *tabControllerManager = [AppCoordinator sharedInstance].tabControllerManager;
    NSString *fiatString = [NSNumberFormatter formatEthToFiat:[WalletManager.sharedInstance.wallet getEthBalance] exchangeRate:tabControllerManager.latestEthExchangeRate localCurrencyFormatter:[NSNumberFormatter localCurrencyFormatterWithUSLocale]];
    NSDecimalNumber *balance = [NSDecimalNumber decimalNumberWithString:fiatString ? : @"0"];
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
    } else if (webSocket == self.btcSocket) {
        DLog(@"btc websocket opened");
        NSString *message = self.btcSwipeAddressToSubscribe ? [NSString stringWithFormat:@"{\"op\":\"addr_sub\",\"addr\":\"%@\"}", [self.btcSwipeAddressToSubscribe escapedForJS]] : [[self.context evaluateScript:@"MyWallet.getSocketOnOpenMessage()"] toString];

        NSError *error;
        [webSocket sendString:message error:&error];
        if (error) DLog(@"Error subscribing to address: %@", [error localizedDescription]);
    } else if (webSocket == self.bchSocket) {
        DLog(@"bch websocket opened");
        NSString *message = self.bchSwipeAddressToSubscribe ? [NSString stringWithFormat:@"{\"op\":\"addr_sub\",\"addr\":\"%@\"}", [self fromBitcoinCash:[self.bchSwipeAddressToSubscribe escapedForJS]]] : [[self.context evaluateScript:@"MyWalletPhone.bch.getSocketOnOpenMessage()"] toString];
        NSError *error;
        [webSocket sendString:message error:&error];
        if (error) DLog(@"Error subscribing to address: %@", [error localizedDescription]);
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    DLog(@"%@ failed with error: %@", webSocket == self.ethSocket ? @"eth socket" : @"web socket", [error localizedDescription]);
    if ([error.localizedDescription isEqualToString:WEBSOCKET_ERROR_INVALID_SERVER_CERTIFICATE]) {
        // TODO: add failedToValidateCertificate function
        // [app failedToValidateCertificate:[error localizedDescription]];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
    if (webSocket == self.ethSocket) {
        DLog(@"eth websocket closed: code %li, reason: %@", code, reason);
    } else if (webSocket == self.btcSocket || webSocket == self.bchSocket) {
        if (code == WEBSOCKET_CODE_BACKGROUNDED_APP || code == WEBSOCKET_CODE_LOGGED_OUT || code == WEBSOCKET_CODE_RECEIVED_TO_SWIPE_ADDRESS) {
            // Socket will reopen when app becomes active and after decryption
            return;
        }

        DLog(@"websocket closed: code %li, reason: %@", code, reason);
        if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
            if (self.btcSocket.readyState != 1) {
                DLog(@"reconnecting websocket");
                [self setupSocket:LegacyAssetTypeBitcoin];
            }
            if (self.bchSocket.readyState != 1) {
                DLog(@"reconnecting websocket");
                [self setupSocket:LegacyAssetTypeBitcoinCash];
            }
        }
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessageWithString:(NSString *)string
{
    if (webSocket == self.ethSocket) {
        DLog(@"received eth socket message string");
        [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.didReceiveEthSocketMessage(\"%@\")", [string escapedForJS]]];
    } else {
        DLog(@"received websocket message string");

        if (webSocket == self.btcSocket) {
            [self.context evaluateScript:[NSString stringWithFormat:@"MyWallet.getSocketOnMessage(\"%@\", { checksum: null })", [string escapedForJS]]];
        } else if (webSocket == self.bchSocket) {
            [self.context evaluateScript:@"MyWalletPhone.bch.didGetTxMessage()"];
        }

        NSDictionary *message = [string getJSONObject];
        NSDictionary *transaction = message[@"x"];

        if (webSocket == self.btcSocket && self.btcSwipeAddressToSubscribe) {
            NSString *hash = transaction[DICTIONARY_KEY_HASH];
            [self getAmountReceivedForTransactionHash:hash socket:webSocket];
        } else if (webSocket == self.bchSocket && self.bchSwipeAddressToSubscribe) {
            NSArray *outputs = transaction[DICTIONARY_KEY_OUT];
            NSString *address = [self fromBitcoinCash:self.bchSwipeAddressToSubscribe];
            uint64_t amountReceived = 0;
            for (NSDictionary *output in outputs) {
                if ([[output objectForKey:DICTIONARY_KEY_ADDRESS_OUTPUT] isEqualToString:address]) amountReceived = amountReceived + [[output objectForKey:DICTIONARY_KEY_VALUE] longLongValue];
            };

            self.bchSwipeAddressToSubscribe = nil;

            if (amountReceived > 0) {
                if ([delegate respondsToSelector:@selector(paymentReceivedOnPINScreen:assetType:)]) {
                    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
                        NSString *amountString = [NSNumberFormatter formatBchWithSymbol:amountReceived localCurrency:NO];
                        [delegate paymentReceivedOnPINScreen:amountString assetType:LegacyAssetTypeBitcoinCash];
                    }
                } else {
                    DLog(@"Error: delegate of class %@ does not respond to selector paymentReceivedOnPINScreen:!", [delegate class]);
                }
            }

            [webSocket closeWithCode:WEBSOCKET_CODE_RECEIVED_TO_SWIPE_ADDRESS reason:WEBSOCKET_CLOSE_REASON_RECEIVED_TO_SWIPE_ADDRESS];
        }
    }
}

- (void)getAmountReceivedForTransactionHash:(NSString *)txHash socket:(SRWebSocket *)webSocket
{
    NSURL *URL = [NSURL URLWithString:[[[BlockchainAPI sharedInstance] walletUrl] stringByAppendingString:[NSString stringWithFormat:TRANSACTION_RESULT_URL_SUFFIX_HASH_ARGUMENT_ADDRESS_ARGUMENT, txHash, self.btcSwipeAddressToSubscribe]]];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];

    NSURLSessionDataTask *task = [[[NetworkManager sharedInstance] session] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                // TODO: add alert for error here
            });
            return;
        }

        uint64_t amountReceived = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] longLongValue];

        NSString *amountString = [NSNumberFormatter formatMoney:amountReceived localCurrency:NO];
        self.btcSwipeAddressToSubscribe = nil;

        if (amountReceived > 0) {
            if ([delegate respondsToSelector:@selector(paymentReceivedOnPINScreen:assetType:)]) {
                if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
                    [delegate paymentReceivedOnPINScreen:amountString assetType:LegacyAssetTypeBitcoin];
                }
            } else {
                DLog(@"Error: delegate of class %@ does not respond to selector paymentReceivedOnPINScreen:!", [delegate class]);
            }
        }

        [webSocket closeWithCode:WEBSOCKET_CODE_RECEIVED_TO_SWIPE_ADDRESS reason:WEBSOCKET_CLOSE_REASON_RECEIVED_TO_SWIPE_ADDRESS];
    }];

    [task resume];
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
    return [[self.context evaluateScript:[NSString stringWithFormat:@"WalletCrypto.encrypt(\"%@\", \"%@\", %d)", [data escapedForJS], [_password escapedForJS], pbkdf2_iterations]] toString];
}

- (NSString*)decrypt:(NSString*)data password:(NSString*)_password pbkdf2_iterations:(int)pbkdf2_iterations
{
    return [[self.context evaluateScript:[NSString stringWithFormat:@"WalletCrypto.decryptPasswordWithProcessedPin(\"%@\", \"%@\", %d)", [data escapedForJS], [_password escapedForJS], pbkdf2_iterations]] toString];
}

- (float)getStrengthForPassword:(NSString *)passwordString
{
    return [[self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.getPasswordStrength(\"%@\")", [passwordString escapedForJS]]] toDouble];
}

- (void)loadMetadata
{
    if ([self isInitialized]) {
        [self.context evaluateScript:@"MyWalletPhone.loadMetadata()"];
    }
}

- (void)getHistoryForAllAssets
{
    if ([self isInitialized])
        [self.context evaluateScript:@"MyWalletPhone.getHistoryForAllAssets()"];
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
        DLog(@"Did not receive btc tx message for %f seconds - getting history", DELAY_GET_HISTORY_BACKUP);
        [self getHistoryWithoutBusyView];
    }
}

- (void)getBitcoinCashHistoryIfNoTransactionMessage
{
    if (!self.didReceiveMessageForLastTransaction) {
        DLog(@"Did not receive bch tx message for %f seconds - getting history", DELAY_GET_HISTORY_BACKUP);
        [self getBitcoinCashHistoryAndRates];
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

- (void)getBtcExchangeRates
{
    [self.context evaluateScript:@"JSON.stringify(MyWalletPhone.getBtcExchangeRates())"];
}

- (void)changeLocalCurrency:(NSString *)currencyCode
{
    if (![self isInitialized]) {
        return;
    }

    [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.changeLocalCurrency(\"%@\")", [currencyCode escapedForJS]]];
}

- (void)changeBtcCurrency:(NSString *)btcCode
{
    if (![self isInitialized]) {
        return;
    }

    [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.changeBtcCurrency(\"%@\")", [btcCode escapedForJS]]];
}

- (uint64_t)conversionForBitcoinAssetType:(LegacyAssetType)assetType
{
    if (assetType == LegacyAssetTypeBitcoin) {
        return WalletManager.sharedInstance.latestMultiAddressResponse.symbol_local.conversion;
    } else if (assetType == LegacyAssetTypeBitcoinCash) {
        return [WalletManager.sharedInstance.wallet getBitcoinCashConversion];
    }
    return 0;
}

- (void)getAccountInfo
{
    if (![self isInitialized]) {
        return;
    }

    [self.context evaluateScript:@"JSON.stringify(MyWalletPhone.getAccountInfo())"];
}

- (void)getAccountInfoAndExchangeRates
{
    if (![self isInitialized]) {
        return;
    }
    
    [self.context evaluateScript:@"MyWalletPhone.getAccountInfoAndExchangeRates()"];
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

    [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.changeEmail(\"%@\")", [newEmail escapedForJS]]];
}

- (void)resendVerificationEmail:(NSString *)email
{
    if (![self isInitialized]) {
        return;
    }

    [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.resendEmailConfirmation(\"%@\")", [email escapedForJS]]];
}

- (void)changeMobileNumber:(NSString *)newMobileNumber
{
    if (![self isInitialized]) {
        return;
    }

    [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.changeMobileNumber(\"%@\")", [newMobileNumber escapedForJS]]];
}

- (void)verifyMobileNumber:(NSString *)code
{
    if (![self isInitialized]) {
        return;
    }

    [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.verifyMobile(\"%@\")", [code escapedForJS]]];
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

    [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.changePassword(\"%@\")", [changedPassword escapedForJS]]];
}

- (BOOL)isCorrectPassword:(NSString *)inputedPassword
{
    if (![self isInitialized]) {
        return NO;
    }

    return [[self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.isCorrectMainPassword(\"%@\")", [inputedPassword escapedForJS]]] toBool];
}

- (void)sendPaymentWithListener:(transactionProgressListeners*)listener secondPassword:(NSString *)secondPassword
{
    NSString * txProgressID = [[self.context evaluateScript:@"MyWalletPhone.createTxProgressId()"] toString];

    if (listener) {
        [self.transactionProgressListeners setObject:listener forKey:txProgressID];
    }

    if (secondPassword) {
        [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.quickSendBtc(\"%@\", true, \"%@\")", [txProgressID escapedForJS], [secondPassword escapedForJS]]];
    } else {
        [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.quickSendBtc(\"%@\", true)", [txProgressID escapedForJS]]];
    }
}

- (void)transferFundsBackupWithListener:(transactionProgressListeners*)listener secondPassword:(NSString *)secondPassword
{
    NSString * txProgressID = [[self.context evaluateScript:@"MyWalletPhone.createTxProgressId()"] toString];

    if (listener) {
        [self.transactionProgressListeners setObject:listener forKey:txProgressID];
    }

    if (secondPassword) {
        [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.quickSendBtc(\"%@\", false, \"%@\")", [txProgressID escapedForJS], [secondPassword escapedForJS]]];
    } else {
        [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.quickSendBtc(\"%@\", false)", [txProgressID escapedForJS]]];
    }
}

- (uint64_t)parseBitcoinValueFromTextField:(UITextField *)textField
{
    return [self parseBitcoinValueFromString:textField.text];
}

- (uint64_t)parseBitcoinValueFromString:(NSString *)inputString
{
    NSString *requestedAmountString = [NSNumberFormatter convertedDecimalString:inputString];

    return [[[self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.precisionToSatoshiBN(\"%@\", %lld).toString()", [requestedAmountString escapedForJS], WalletManager.sharedInstance.latestMultiAddressResponse.symbol_btc.conversion]] toNumber] longLongValue];
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

    BlockchainSettings.sharedOnboardingInstance.hasSeenAllCards = YES;

    [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.parsePairingCode(\"%@\");", [code escapedForJS]]];
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
    [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.newAccount(\"%@\", \"%@\", \"%@\")", [__password escapedForJS], [__email escapedForJS], BC_STRING_MY_BITCOIN_WALLET]];
}

- (BOOL)needsSecondPassword
{
    if (![self isInitialized]) {
        return NO;
    }

    return [[self.context evaluateScript:[NSString stringWithFormat:@"MyWallet.wallet.isDoubleEncrypted"]] toBool];
}

- (BOOL)validateSecondPassword:(NSString*)secondPassword
{
    if (![self isInitialized]) {
        return NO;
    }

    return [[self.context evaluateScript:[NSString stringWithFormat:@"MyWallet.wallet.validateSecondPassword(\"%@\")", [secondPassword escapedForJS]]] toBool];
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
        return NO;
    }

    if ([self checkIfWalletHasAddress:address]) {
        return [[self.context evaluateScript:[NSString stringWithFormat:@"MyWallet.wallet.key(\"%@\").isWatchOnly", [address escapedForJS]]] toBool];
    } else {
        return NO;
    }
}

- (NSString*)labelForLegacyAddress:(NSString*)address assetType:(LegacyAssetType)assetType
{
    if (![self isInitialized]) {
        return nil;
    }

    if (assetType == LegacyAssetTypeBitcoin) {
        if ([[WalletManager.sharedInstance.wallet.addressBook objectForKey:address] length] > 0) {
            return [WalletManager.sharedInstance.wallet.addressBook objectForKey:address];
        } else if ([[WalletManager.sharedInstance.wallet allLegacyAddresses:assetType] containsObject:address]) {
            NSString *label = [self checkIfWalletHasAddress:address] ? [[self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.labelForLegacyAddress(\"%@\")", [address escapedForJS]]] toString] : nil;
            if (label && ![label isEqualToString:@""])
                return label;
        }
        return address;
    } else if (assetType == LegacyAssetTypeBitcoinCash) {
        return address;
    }
    return nil;
}

- (Boolean)isAddressArchived:(NSString *)address
{
    if (![self isInitialized] || !address) {
        return FALSE;
    }

    return [[self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.isArchived(\"%@\")", [address escapedForJS]]] toBool];
}

- (BOOL)isAccountArchived:(int)account assetType:(LegacyAssetType)assetType
{
    if (![self isInitialized]) {
        return NO;
    }

    if (assetType == LegacyAssetTypeBitcoin) {
        return [[self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.isArchived(%d)", account]] toBool];
    } else if (assetType == LegacyAssetTypeBitcoinCash) {
        return [[self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.bch.isArchived(%d)", account]] toBool];
    }
    return NO;
}

// TODO: deprecate this method once dependencies are migrated to Swift
- (BOOL)isValidAddress:(NSString*)string assetType:(LegacyAssetType)assetType
{
    // NOTE: address validation should still be available if the wallet is not initialized

    if (![self isInitialized]) {
        return NO;
    }

    AddressValidator *validator = [[AddressValidator alloc] initWithContext:[WalletManager sharedInstance].wallet.context];

    if (assetType == LegacyAssetTypeBitcoin) {
        BitcoinAddress *address = [[BitcoinAddress alloc] initWithString:string];
        return [validator validateWithBitcoinAddress:address];
    } else if (assetType == LegacyAssetTypeBitcoinCash) {
        BitcoinCashAddress *address = [[BitcoinCashAddress alloc] initWithString:string];
        return [validator validateWithBitcoinCashAddress:address];
    } else if (assetType == LegacyAssetTypeEther) {
        EthereumAddress *address = [[EthereumAddress alloc] initWithString:string];
        return [validator validateWithEthereumAddress:address];
    }
    return NO;
}

- (NSArray*)allLegacyAddresses:(LegacyAssetType)assetType
{
    if (![self isInitialized]) {
        return nil;
    }

    NSString *allAddressesJSON;
    if (assetType == LegacyAssetTypeBitcoin) {
        allAddressesJSON = [[self.context evaluateScript:@"JSON.stringify(MyWallet.wallet.addresses)"] toString];
        return [allAddressesJSON getJSONObject];
    } else if (assetType == LegacyAssetTypeBitcoinCash) {
        allAddressesJSON = [[self.context evaluateScript:@"JSON.stringify(MyWalletPhone.bch.getActiveLegacyAddresses())"] toString];
        return [allAddressesJSON getJSONObject];
    }
    return nil;
}

- (NSArray*)activeLegacyAddresses:(LegacyAssetType)assetType
{
    if (![self isInitialized]) {
        return nil;
    }

    NSString *activeAddressesJSON;
    if (assetType == LegacyAssetTypeBitcoin) {
        activeAddressesJSON = [[self.context evaluateScript:@"JSON.stringify(MyWallet.wallet.activeAddresses)"] toString];
    } else if (assetType == LegacyAssetTypeBitcoinCash) {
        activeAddressesJSON = [[self.context evaluateScript:@"JSON.stringify(MyWalletPhone.bch.getActiveLegacyAddresses())"] toString];
    }

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
    if (![self isInitialized]) {
        return;
    }

    if (!Reachability.hasInternetConnection) {
        [AlertViewPresenter.sharedInstance showNoInternetConnectionAlert];
        return;
    }

    self.isSyncing = YES;

    [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.setLabelForAddress(\"%@\", \"%@\")", [address escapedForJS], [label escapedForJS]]];
}

- (void)toggleArchiveLegacyAddress:(NSString*)address
{
    if (![self isInitialized]) {
        return;
    }

    if (!Reachability.hasInternetConnection) {
        [AlertViewPresenter.sharedInstance showNoInternetConnectionAlert];
        return;
    }

    self.isSyncing = YES;

    [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.toggleArchived(\"%@\")", [address escapedForJS]]];
}

- (void)toggleArchiveAccount:(int)account assetType:(LegacyAssetType)assetType
{
    if (![self isInitialized]) {
        return;
    }

    if (!Reachability.hasInternetConnection) {
        [AlertViewPresenter.sharedInstance showNoInternetConnectionAlert];
        return;
    }

    self.isSyncing = YES;

    if (assetType == LegacyAssetTypeBitcoin) {
        [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.toggleArchived(%d)", account]];
    } else if (assetType == LegacyAssetTypeBitcoinCash) {
        [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.bch.toggleArchived(%d)", account]];
        [self reload];
    }
}

- (void)archiveTransferredAddresses:(NSArray *)transferredAddresses
{
    if (![self isInitialized]) {
        return;
    }

    [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.archiveTransferredAddresses(\"%@\")", [[transferredAddresses jsonString] escapedForJS]]];
}

- (id)getLegacyAddressBalance:(NSString*)address assetType:(LegacyAssetType)assetType
{
    NSNumber *errorBalance = @0;
    if (![self isInitialized]) {
        return errorBalance;
    }

    if (assetType == LegacyAssetTypeBitcoin) {
        if ([self checkIfWalletHasAddress:address]) {
            return [[self.context evaluateScript:[NSString stringWithFormat:@"MyWallet.wallet.key(\"%@\").balance", [address escapedForJS]]] toNumber];
        } else {
            DLog(@"Wallet error: Tried to get balance of address %@, which was not found in this wallet", address);
            return errorBalance;
        }
    } else if (assetType == LegacyAssetTypeBitcoinCash) {
        return [[self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.bch.getBalanceForAddress(\"%@\")", [address escapedForJS]]] toNumber];
    }
    return 0;
}

- (BOOL)addKey:(NSString*)privateKeyString
{
    if (![self isInitialized]) {
        return NO;
    }

    return [[self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.addKey(\"%@\")", [privateKeyString escapedForJS]]] toBool];
}

- (BOOL)addKey:(NSString*)privateKeyString toWatchOnlyAddress:(NSString *)watchOnlyAddress
{
    if (![self isInitialized]) {
        return NO;
    }

    return [[self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.addKeyToLegacyAddress(\"%@\", \"%@\")", [privateKeyString escapedForJS], [watchOnlyAddress escapedForJS]]] toBool];
}

- (void)sendFromWatchOnlyAddress:(NSString *)watchOnlyAddress privateKey:(NSString *)privateKeyString
{
    if (![self isInitialized]) {
        return;
    }

    [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.sendFromWatchOnlyAddressWithPrivateKey(\"%@\", \"%@\")", [privateKeyString escapedForJS], [watchOnlyAddress escapedForJS]]];
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

    [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.addAddressBookEntry(\"%@\", \"%@\")", [address escapedForJS], [label escapedForJS]]];
}

- (NSString*)detectPrivateKeyFormat:(NSString*)privateKeyString
{
    if (![self isInitialized]) {
        return nil;
    }

    return [[self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.detectPrivateKeyFormat(\"%@\")", [privateKeyString escapedForJS]]] toString];
}

- (void)createNewPayment:(LegacyAssetType)assetType
{
    if (![self isInitialized]) {
        return;
    }

    if (assetType == LegacyAssetTypeBitcoin) {
        [self.context evaluateScript:@"MyWalletPhone.createNewBitcoinPayment()"];
    } else if (assetType == LegacyAssetTypeBitcoinCash) {
        DLog(@"Bitcoin cash - creating payment is done in selecting from");
    } else if (assetType == LegacyAssetTypeEther) {
        [self.context evaluateScript:@"MyWalletPhone.createNewEtherPayment()"];
    }
}

- (void)changePaymentFromAddress:(NSString *)address isAdvanced:(BOOL)isAdvanced assetType:(LegacyAssetType)assetType
{
    if (assetType == LegacyAssetTypeBitcoin) {
        [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.changePaymentFrom(\"%@\", %d)", [address escapedForJS], isAdvanced]];
    } else if (assetType == LegacyAssetTypeBitcoinCash) {
        [self.context evaluateScript:@"MyWalletPhone.bch.changePaymentFromImportedAddresses()"];
    }
}

- (void)changePaymentFromAccount:(int)fromInt isAdvanced:(BOOL)isAdvanced assetType:(LegacyAssetType)assetType
{
    if (![self isInitialized]) {
        return;
    }

    if (assetType == LegacyAssetTypeBitcoin) {
        [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.changePaymentFrom(%d, %d)", fromInt, isAdvanced]];
    } else if (assetType == LegacyAssetTypeBitcoinCash) {
        [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.bch.changePaymentFromAccount(\"%d\")", fromInt]];
    }
}

- (void)changePaymentToAccount:(int)toInt assetType:(LegacyAssetType)assetType
{
    if (![self isInitialized]) {
        return;
    }

    if (assetType == LegacyAssetTypeBitcoin) {
        [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.changePaymentTo(%d)", toInt]];
    } else if (assetType == LegacyAssetTypeBitcoinCash) {
        [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.bch.changePaymentToAccount(%d)", toInt]];
    }
}

- (void)changePaymentToAddress:(NSString *)toString assetType:(LegacyAssetType)assetType
{
    if (![self isInitialized]) {
        return;
    }

    if (assetType == LegacyAssetTypeBitcoin) {
        [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.changePaymentTo(\"%@\")", [toString escapedForJS]]];
    } else if (assetType == LegacyAssetTypeBitcoinCash) {
        [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.bch.changePaymentToAddress(\"%@\")", [toString escapedForJS]]];
    } else if (assetType == LegacyAssetTypeEther) {
        [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.setEtherPaymentTo(\"%@\")", [toString escapedForJS]]];
    }
}

- (void)changePaymentAmount:(id)amount assetType:(LegacyAssetType)assetType
{
    if (![self isInitialized]) {
        return;
    }

    if (assetType == LegacyAssetTypeBitcoin) {
        [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.changePaymentAmount(%lld)", [amount longLongValue]]];
    } else if (assetType == LegacyAssetTypeBitcoinCash) {
        [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.bch.changePaymentAmount(%lld)", [amount longLongValue]]];
    } else if (assetType == LegacyAssetTypeEther) {
        [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.setEtherPaymentAmount(\"%@\")", amount ? : @0]];
    }
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

    [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.transferAllFundsToAccount(%d, true, \"%@\", \"%@\", %d)", account, [address escapedForJS], [secondPassword escapedForJS], useSendPayment]];
}

- (void)setupFollowingTransferForAllFundsToAccount:(int)account address:(NSString *)address secondPassword:(NSString *)secondPassword useSendPayment:(BOOL)useSendPayment
{
    if (![self isInitialized]) {
        return;
    }

    [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.transferAllFundsToAccount(%d, false, \"%@\", \"%@\", %d)", account, [address escapedForJS], [secondPassword escapedForJS], useSendPayment]];
}

- (void)transferFundsToDefaultAccountFromAddress:(NSString *)address
{
    if (![self isInitialized]) {
        return;
    }

    [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.transferFundsToDefaultAccountFromAddress(\"%@\")", [address escapedForJS]]];
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

    return [[self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.checkIfWalletHasAddress(\"%@\")", [address escapedForJS]] ] toBool];
}

- (void)recoverWithEmail:(NSString *)email password:(NSString *)recoveryPassword passphrase:(NSString *)passphrase
{
    [self useDebugSettingsIfSet];

    self.emptyAccountIndex = 0;
    self.recoveredAccountIndex = 0;
    [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.recoverWithPassphrase(\"%@\",\"%@\",\"%@\")", [email escapedForJS], [recoveryPassword escapedForJS], [passphrase escapedForJS]]];
}

- (void)resendTwoFactorSMS
{
    [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.resendTwoFactorSms(\"%@\", \"%@\")", [self.guid escapedForJS], [self.sessionToken escapedForJS]]];
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

- (void)updateServerURL:(NSString *)newURL
{
    [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.updateServerURL(\"%@\")", [newURL escapedForJS]]];
}

- (void)updateWebSocketURL:(NSString *)newURL
{
    [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.updateWebsocketURL(\"%@\")", [newURL escapedForJS]]];
}

- (void)updateAPIURL:(NSString *)newURL
{
    [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.updateAPIURL(\"%@\")", [newURL escapedForJS]]];
}

- (NSDictionary *)filteredWalletJSON
{
    if (![self isInitialized]) {
        return nil;
    }

    NSString * filteredWalletJSON = [[self.context evaluateScript:@"JSON.stringify(MyWalletPhone.filteredWalletJSON())"] toString];

    return [filteredWalletJSON getJSONObject];
}

- (NSString *)getXpubForAccount:(int)accountIndex assetType:(LegacyAssetType)assetType
{
    if (![self isInitialized]) {
        return nil;
    }

    if (assetType == LegacyAssetTypeBitcoin) {
        return [[self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.getXpubForAccount(%d)", accountIndex]] toString];
    } else if (assetType == LegacyAssetTypeBitcoinCash) {
        return [[self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.bch.getXpubForAccount(%d)", accountIndex]] toString];
    }
    return nil;
}

- (BOOL)isAccountNameValid:(NSString *)name
{
    if (![self isInitialized]) {
        return NO;
    }

    return [[self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.isAccountNameValid(\"%@\")", [name escapedForJS]]] toBool];
}

- (BOOL)isAddressAvailable:(NSString *)address
{
    if (![self isInitialized]) {
        return NO;
    }

    return [[self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.isAddressAvailable(\"%@\")", [address escapedForJS]]] toBool];
}

- (BOOL)isAccountAvailable:(int)account
{
    if (![self isInitialized]) {
        return NO;
    }

    return [[self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.isAccountAvailable(%d)", account]] toBool];
}

- (int)getIndexOfActiveAccount:(int)account assetType:(LegacyAssetType)assetType
{
    if (![self isInitialized]) {
        return 0;
    }

    if (assetType == LegacyAssetTypeBitcoin) {
        return [[[self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.getIndexOfActiveAccount(%d)", account]] toNumber] intValue];
    } else if (assetType == LegacyAssetTypeBitcoinCash) {
        return [[[self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.bch.getIndexOfActiveAccount(%d)", account]] toNumber] intValue];
    }
    return 0;
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

- (void)saveNote:(NSString *)note forTransaction:(NSString *)hash
{
    NSString *text = [note stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (text.length == 0) {
        [self.context evaluateScript:[NSString stringWithFormat:@"MyWallet.wallet.deleteNote(\"%@\")", [hash escapedForJS]]];
    } else {
        [self.context evaluateScript:[NSString stringWithFormat:@"MyWallet.wallet.setNote(\"%@\", \"%@\")", [hash escapedForJS], [note escapedForJS]]];
    }
}

- (void)saveEtherNote:(NSString *)note forTransaction:(NSString *)hash
{
    if ([self isInitialized]) {
        [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.saveEtherNote(\"%@\", \"%@\")", [hash escapedForJS], [note escapedForJS]]];
    }
}

- (void)getFiatAtTime:(uint64_t)time value:(NSDecimalNumber *)value currencyCode:(NSString *)currencyCode assetType:(LegacyAssetType)assetType
{
    NSString *symbol;
    if (assetType == LegacyAssetTypeBitcoin) {
        symbol = CURRENCY_SYMBOL_BTC;
    } else if (assetType == LegacyAssetTypeEther) {
        symbol = CURRENCY_SYMBOL_ETH;
    } else if (assetType == LegacyAssetTypeBitcoinCash) {
        symbol = CURRENCY_SYMBOL_BCH;
    }

    NSURL *URL = [NSURL URLWithString:[[[BlockchainAPI sharedInstance] apiUrl] stringByAppendingString:[NSString stringWithFormat:URL_SUFFIX_PRICE_INDEX_ARGUMENTS_BASE_QUOTE_TIME, symbol, currencyCode, time]]];

    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    NSURLSessionDataTask *task = [[[NetworkManager sharedInstance] session] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
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

- (void)getSwipeAddresses:(int)numberOfAddresses assetType:(LegacyAssetType)assetType
{
    if (assetType == LegacyAssetTypeBitcoin) {
        [[self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.getBtcSwipeAddresses(%d)", numberOfAddresses]] toArray];
    } else if (assetType == LegacyAssetTypeBitcoinCash) {
        [[self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.bch.getSwipeAddresses(%d)", numberOfAddresses]] toArray];
    }
}

- (int)getDefaultAccountLabelledAddressesCount
{
    return [[[self.context evaluateScript:@"MyWalletPhone.getDefaultAccountLabelledAddressesCount()"] toNumber] intValue];
}

- (BOOL)isBuyEnabled
{
    return [[self.context evaluateScript:@"MyWalletPhone.isBuyFeatureEnabled()"] toBool];
}

- (BOOL)canUseSfox
{
    return [[self.context evaluateScript:@"MyWalletPhone.canUseSfox()"] toBool];
}

- (void)watchPendingTrades:(BOOL)shouldSync
{
    if (shouldSync) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[LoadingViewPresenter sharedInstance] showBusyViewWithLoadingText:[LocalizationConstantsObjcBridge syncingWallet]];
        });
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
        return [[self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.isStateWhitelistedForShapeshift(\"%@\")", [stateCode escapedForJS]]] toBool];
    }

    return NO;
}

- (void)selectState:(NSString *)name code:(NSString *)code
{
    if ([self isInitialized]) {
        [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.setStateForShapeshift(\"%@\", \"%@\")", [name escapedForJS], [code escapedForJS]]];
    }
}

- (void)getExchangeTrades
{
     if ([self isInitialized]) [self.context evaluateScript:@"MyWalletPhone.getExchangeTrades()"];
}

- (void)getRate:(NSString *)coinPair
{
    if ([self isInitialized]) [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.getRate(\"%@\")", [coinPair escapedForJS]]];
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

        NSString *postParameters = [NSString stringWithFormat:@"{\"pair\":\"%@\",\"%@\":\"%@\",\"apiKey\":\"%@\"}", [coinPair escapedForJS], [depositOrWithdrawParameter escapedForJS], [convertedAmount escapedForJS], [apiKey escapedForJS]];
        NSData *postData = [postParameters dataUsingEncoding:NSUTF8StringEncoding];

        [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:postData];

        NSURLSessionDataTask *task = [[[NetworkManager sharedInstance] session] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error) {
                DLog(@"Error getting approximate quote: %@", error);
                NSInteger cancelledErrorCode = -999;
                if (error.code != cancelledErrorCode) {
                    [[AlertViewPresenter sharedInstance] standardNotifyWithMessage:[NSString stringWithFormat:BC_STRING_ERROR_GETTING_APPROXIMATE_QUOTE_ARGUMENT_MESSAGE, error] title:BC_STRING_ERROR in:nil handler:nil];
                }
            } else {
                NSError *jsonError;
                NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                if (result[DICTIONARY_KEY_ERROR] && [result[DICTIONARY_KEY_ERROR] isKindOfClass:[NSDictionary class]]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[AlertViewPresenter sharedInstance] standardNotifyWithMessage:[NSString stringWithFormat:BC_STRING_ERROR_GETTING_APPROXIMATE_QUOTE_ARGUMENT_MESSAGE, result[DICTIONARY_KEY_ERROR][DICTIONARY_KEY_MESSAGE]] title:BC_STRING_ERROR in:nil handler:nil];
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

- (void)getAvailableBchBalanceForAccount:(int)account
{
    if ([self isInitialized]) [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.bch.getAvailableBalanceForAccount(\"%d\")", account]];
}

- (void)buildExchangeTradeFromAccount:(int)fromAccount toAccount:(int)toAccount coinPair:(NSString *)coinPair amount:(NSString *)amount fee:(NSString *)fee
{
    if ([self isInitialized]) {

        NSString *convertedAmount = [NSNumberFormatter convertedDecimalString:amount];

        [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.buildExchangeTrade(%d, %d, \"%@\", \"%@\", \"%@\")", fromAccount, toAccount, [[coinPair lowercaseString] escapedForJS], [convertedAmount escapedForJS], [fee escapedForJS]]];
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
        return [[self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.isDepositTransaction(\"%@\")", [txHash escapedForJS]]] toBool];
    }

    return NO;
}

- (BOOL)isWithdrawalTransaction:(NSString *)txHash
{
    if ([self isInitialized]) {
        return [[self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.isWithdrawalTransaction(\"%@\")", [txHash escapedForJS]]] toBool];
    }

    return NO;
}

# pragma mark - Ethereum

- (void)createEthAccountForExchange:(NSString *)secondPassword
{
    if ([self isInitialized]) {
        NSString *setupHelperText = BC_STRING_ETHER_ACCOUNT_SECOND_PASSWORD_PROMPT;
        [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.createEthAccountForExchange(\"%@\", \"%@\")", [secondPassword escapedForJS], [setupHelperText escapedForJS]]];
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
    return [self getBalanceForAccount:0 assetType:LegacyAssetTypeEther];
}

- (NSString *)getEthBalanceTruncated
{
    if ([self isInitialized] && [WalletManager.sharedInstance.wallet hasEthAccount]) {
        NSNumber *balanceNumber = [[self.context evaluateScript:@"MyWalletPhone.getEthBalance()"] toNumber];
        return [[NSNumberFormatter assetFormatterWithGroupingSeparator] stringFromNumber:balanceNumber];
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
        [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.getEthExchangeRate(\"%@\")", WalletManager.sharedInstance.latestMultiAddressResponse.symbol_local.code]];
    }
}

- (void)sendEtherPaymentWithNote:(NSString *)note
{
    if ([self isInitialized]) {
        [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.sendEtherPaymentWithNote(\"%@\")", note ? [note escapedForJS] : @""]];
    }
}

- (NSString *)getEtherAddress
{
    if ([self isInitialized]) {
        NSString *setupHelperText = BC_STRING_ETHER_ACCOUNT_SECOND_PASSWORD_PROMPT;
        JSValue *result = [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.getEtherAddress(\"%@\")", [setupHelperText escapedForJS]]];
        if ([result isUndefined]) return nil;
        NSString *etherAddress = [result toString];
        return etherAddress;
    }

    return nil;
}

- (void)isEtherContractAddress:(NSString *)address completion:(void (^ _Nullable)(NSData *, NSURLResponse *, NSError *))completion
{
    NSURL *URL = [NSURL URLWithString:[[[BlockchainAPI sharedInstance] apiUrl] stringByAppendingString:[NSString stringWithFormat:URL_SUFFIX_ETH_IS_CONTRACT_ADDRESS_ARGUMENT, address]]];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    NSURLSessionDataTask *task = [[[NetworkManager sharedInstance] session] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
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

- (NSString *)getLabelForDefaultBchAccount
{
    if ([self isInitialized] && [self hasBchAccount]) {
        return [[self.context evaluateScript:@"MyWalletPhone.bch.getLabelForDefaultAccount()"] toString];
    }
    return nil;
}

# pragma mark - Bitcoin cash

- (NSString *)fromBitcoinCash:(NSString *)address
{
    return [[self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.bch.fromBitcoinCash(\"%@\")", [address escapedForJS]]] toString];
}

- (NSString *)toBitcoinCash:(NSString *)address includePrefix:(BOOL)includePrefix
{
    JSValue *result = [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.bch.toBitcoinCash(\"%@\", %d)", [address escapedForJS], includePrefix]];
    if ([result isUndefined]) return nil;
    NSString *bitcoinCashAddress = [result toString];
    return includePrefix ? bitcoinCashAddress : [bitcoinCashAddress substringFromIndex:[[ConstantsObjcBridge bitcoinCashUriPrefix] length]+1];
}

- (void)getBitcoinCashHistoryAndRates
{
    if ([self isInitialized]) {
        [self.context evaluateScript:@"MyWalletPhone.bch.getHistoryAndRates()"];
    }
}

- (NSArray *)getBitcoinCashTransactions:(NSInteger)filterType
{
    if ([self isInitialized]) {
        NSArray *fetchedTransactions = [[self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.bch.transactions(%ld)", filterType]] toArray];
        NSMutableArray *transactions = [NSMutableArray new];
        for (NSDictionary *data in fetchedTransactions) {
            Transaction *transaction = [Transaction fromJSONDict:data];
            [transactions addObject:transaction];
        }
        self.bitcoinCashTransactions = transactions;
        return self.bitcoinCashTransactions;
    }
    return nil;
}

- (void)fetchBitcoinCashExchangeRates
{
    if ([self isInitialized]) {
        [self.context evaluateScript:@"MyWalletPhone.bch.fetchExchangeRates()"];
    }
}

- (NSString *)getLabelForBitcoinCashAccount:(int)account
{
    if ([self isInitialized]) {
        return [[self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.bch.getLabelForAccount(\"%d\")", account]] toString];
    }
    return nil;
}

- (void)buildBitcoinCashPaymentTo:(id)to amount:(uint64_t)amount
{
    if ([self isInitialized]) {
        if ([to isKindOfClass:[NSString class]]) {
            [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.bch.buildPayment(\"%@\", %lld)", [to escapedForJS], amount]];
        } else {
            [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.bch.buildPayment(%d, %lld)", [to intValue], amount]];
        }
    }
}

- (void)sendBitcoinCashPaymentWithListener:(transactionProgressListeners *)listener
{
    NSString * txProgressID = [[self.context evaluateScript:@"MyWalletPhone.createTxProgressId()"] toString];

    if (listener) {
        [self.transactionProgressListeners setObject:listener forKey:txProgressID];
    }

    [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.bch.quickSend(\"%@\", true)", [txProgressID escapedForJS]]];
}

- (NSString *)bitcoinCashExchangeRate
{
    if ([self isInitialized]) {
        if (self.bitcoinCashExchangeRates) {
            NSString *currency = [self.accountInfo objectForKey:DICTIONARY_KEY_CURRENCY];
            double lastPrice = [[[self.bitcoinCashExchangeRates objectForKey:currency] objectForKey:DICTIONARY_KEY_LAST] doubleValue];
            return [NSString stringWithFormat:@"%.2f", lastPrice];
        }
    }

    return nil;
}

- (uint64_t)getBitcoinCashConversion
{
    if ([self isInitialized]) {
        return self.bitcoinCashConversion;
    }

    return 0;
}

- (uint64_t)bitcoinCashTotalBalance
{
    if ([self isInitialized]) {
        return [[[self.context evaluateScript:@"MyWalletPhone.bch.totalBalance()"] toNumber] longLongValue];
    }

    return 0;
}

- (BOOL)hasBchAccount
{
    if ([self isInitialized]) {
        return [[self.context evaluateScript:@"MyWalletPhone.bch.hasAccount()"] toBool];
    }
    return NO;
}

- (uint64_t)getBchBalance
{
    if ([self isInitialized] && [WalletManager.sharedInstance.wallet hasBchAccount]) {
        return [[[self.context evaluateScript:@"MyWalletPhone.bch.getBalance()"] toNumber] longLongValue];
    }
    DLog(@"Warning: getting bch balance when not initialized - returning 0");
    return 0;
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
    [[LoadingViewPresenter sharedInstance] updateBusyViewLoadingTextWithText:LocalizationConstantsObjcBridge.downloadingWallet];
}

- (void)loading_start_decrypt_wallet
{
    [[LoadingViewPresenter sharedInstance] updateBusyViewLoadingTextWithText:BC_STRING_LOADING_DECRYPTING_WALLET];
}

- (void)loading_start_build_wallet
{
    [[LoadingViewPresenter sharedInstance] updateBusyViewLoadingTextWithText:BC_STRING_LOADING_LOADING_BUILD_HD_WALLET];
}

- (void)loading_start_multiaddr
{
    [[LoadingViewPresenter sharedInstance] updateBusyViewLoadingTextWithText:BC_STRING_LOADING_LOADING_TRANSACTIONS];
}

- (void)loading_start_get_history
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[LoadingViewPresenter sharedInstance] showBusyViewWithLoadingText:BC_STRING_LOADING_LOADING_TRANSACTIONS];
    });
}

- (void)loading_start_get_wallet_and_history
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[LoadingViewPresenter sharedInstance] showBusyViewWithLoadingText:BC_STRING_LOADING_CHECKING_WALLET_UPDATES];
    });
}

- (void)loading_start_create_account
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[LoadingViewPresenter sharedInstance] showBusyViewWithLoadingText:BC_STRING_LOADING_CREATING];
    });
}

- (void)loading_start_new_account
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[LoadingViewPresenter sharedInstance] showBusyViewWithLoadingText:BC_STRING_LOADING_CREATING_WALLET];
    });
}

- (void)loading_start_create_new_address
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[LoadingViewPresenter sharedInstance] showBusyViewWithLoadingText:BC_STRING_LOADING_CREATING_NEW_ADDRESS];
    });
}

- (void)loading_start_generate_uuids
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[LoadingViewPresenter sharedInstance] updateBusyViewLoadingTextWithText:BC_STRING_LOADING_RECOVERY_CREATING_WALLET];
    });
}

- (void)loading_start_recover_wallet
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[LoadingViewPresenter sharedInstance] showBusyViewWithLoadingText:BC_STRING_LOADING_RECOVERING_WALLET];
    });
}

- (void)loading_start_transfer_all:(NSNumber *)addressIndex totalAddresses:(NSNumber *)totalAddresses
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[LoadingViewPresenter sharedInstance] showBusyViewWithLoadingText:[NSString stringWithFormat:BC_STRING_TRANSFER_ALL_CALCULATING_AMOUNTS_AND_FEES_ARGUMENT_OF_ARGUMENT, addressIndex, totalAddresses]];
    });
}

- (void)loading_stop
{
    DLog(@"Stop loading");
    dispatch_async(dispatch_get_main_queue(), ^{
        [[LoadingViewPresenter sharedInstance] hideBusyView];
    });
}

- (void)upgrade_success
{
    if ([delegate respondsToSelector:@selector(walletUpgraded:)]) {
        [delegate walletUpgraded:self];
    }
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
    if ([delegate respondsToSelector:@selector(wallet:didRequireTwoFactorAuthentication:)]) {
        NSInteger twoFactorType = [[WalletManager.sharedInstance.wallet get2FAType] integerValue];
        [delegate wallet:self didRequireTwoFactorAuthentication:twoFactorType];
    } else {
        DLog(@"Error: delegate of class %@ does not respond to selector wallet:didRequireTwoFactorAuthentication::!", [delegate class]);
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

    TabControllerManager *tabControllerManager = [AppCoordinator sharedInstance].tabControllerManager;
    TransactionsBitcoinViewController *transactionsBitcoinViewController = tabControllerManager.transactionsBitcoinViewController;

    int filterIndex = transactionsBitcoinViewController ? (int)transactionsBitcoinViewController.filterIndex : FILTER_INDEX_ALL;

    if (filterIndex == FILTER_INDEX_ALL) {
        filter = @"";
    } else if (filterIndex == FILTER_INDEX_IMPORTED_ADDRESSES) {
        filter = TRANSACTION_FILTER_IMPORTED;
    } else {
        filter = [NSString stringWithFormat:@"%d", filterIndex];
    }

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

- (void)getPrivateKeyPasswordSuccess:(JSValue *)success error:(void(^)(id))_error
{
    if ([delegate respondsToSelector:@selector(getPrivateKeyPasswordWithSuccess:)]) {
        [delegate getPrivateKeyPasswordWithSuccess:success];
    } else {
        DLog(@"Error: delegate of class %@ does not respond to selector getPrivateKeyPassword!", [delegate class]);
    }
}

- (void)getSecondPasswordSuccess:(JSValue *)success error:(void(^)(id))_error helperText:(NSString *)helperText
{
    if ([delegate respondsToSelector:@selector(getSecondPasswordWithSuccess:)]) {
        [delegate getSecondPasswordWithSuccess:success];
    } else {
        DLog(@"Error: delegate of class %@ does not respond to selector getSecondPassword!", [delegate class]);
    }
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
        [[AlertViewPresenter sharedInstance] standardNotifyWithMessage:BC_STRING_ERROR_SAVING_WALLET_CHECK_FOR_OTHER_DEVICES title:BC_STRING_ERROR in:nil handler:nil];
        return;
    }

    if ([type isEqualToString:@"error"]) {
        [[AlertViewPresenter sharedInstance] standardNotifyWithMessage:message title:BC_STRING_ERROR in:nil handler: nil];
    } else if ([type isEqualToString:@"info"]) {
        [[AlertViewPresenter sharedInstance] standardNotifyWithMessage:[LocalizationConstantsObjcBridge information] title:BC_STRING_ERROR in:nil handler: nil];
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
            [[AlertViewPresenter sharedInstance] standardNotifyWithMessage:message title:BC_STRING_ERROR in:nil handler:nil];
            [self error_restoring_wallet];
            return;
        } else if (connectivityErrorRange.location != NSNotFound) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(ANIMATION_DURATION_LONG * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[AlertViewPresenter sharedInstance] standardNotifyWithMessage:[LocalizationConstantsObjcBridge requestFailedCheckConnection] title:BC_STRING_ERROR in:nil handler:nil];
            });
            [self error_restoring_wallet];
            return;
        }

        if (![KeychainItemWrapper guid]) {
            // This error is used whe trying to login with incorrect passwords or when the account is locked, so present an alert if the app has no guid, since it currently conflicts with makeNotice when backgrounding after changing password in-app
            [[AlertViewPresenter sharedInstance] standardNotifyWithMessage:message title:BC_STRING_ERROR in:nil handler:nil];
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

    if (self.btcSocket) {
        [self.btcSocket closeWithCode:WEBSOCKET_CODE_DECRYPTED_WALLET reason:WEBSOCKET_CLOSE_REASON_DECRYPTED_WALLET];
    } else {
        [self setupSocket:LegacyAssetTypeBitcoin];
    }

    if (self.bchSocket) {
        [self.bchSocket closeWithCode:WEBSOCKET_CODE_DECRYPTED_WALLET reason:WEBSOCKET_CLOSE_REASON_DECRYPTED_WALLET];
    } else {
        [self setupSocket:LegacyAssetTypeBitcoinCash];
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
        if ([[self.btcRates allKeys] containsObject:currencyCode]) {
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

/* Begin Key Importer */

- (void)on_add_key:(NSString*)address
{
    // TODO: call Swift `importKey` directly once available
    [[KeyImportCoordinator sharedInstance] on_add_keyWithAddress:address];
}

- (void)on_add_incorrect_private_key:(NSString *)address
{
    // TODO: remove bridging function call
    [[KeyImportCoordinator sharedInstance] on_add_incorrect_private_keyWithAddress:address];
}

- (void)on_add_private_key_start
{
    // TODO: remove bridging function call
    [[KeyImportCoordinator sharedInstance] on_add_private_key_start];
}

- (void)on_add_private_key_to_legacy_address:(NSString *)address
{
    // TODO: remove bridging function call
    [[KeyImportCoordinator sharedInstance] on_add_private_key_to_legacy_addressWithAddress:address];
}

- (void)on_error_adding_private_key:(NSString*)error
{
    // TODO: remove bridging function call
    [[KeyImportCoordinator sharedInstance] on_error_adding_private_keyWithError:error];
}

- (void)on_error_adding_private_key_watch_only:(NSString*)error
{
    // TODO: remove bridging function call
    [[KeyImportCoordinator sharedInstance] on_error_adding_private_key_watch_onlyWithError:error];
}

- (void)on_error_import_key_for_sending_from_watch_only:(NSString *)error
{
    // TODO: remove bridging function call
    [[KeyImportCoordinator sharedInstance] on_error_adding_private_key_watch_onlyWithError:error];
}

/* End Key Importer */

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
    [[NSNotificationCenter defaultCenter] postNotificationName:[ConstantsObjcBridge notificationKeyBackupSuccess] object:nil];
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

    if (self.shouldLoadMetadata) {
        self.shouldLoadMetadata = NO;
        [self loadMetadata];
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
    [[AlertViewPresenter sharedInstance] standardNotifyWithMessage:BC_STRING_SETTINGS_ERROR_LOADING_MESSAGE title:BC_STRING_SETTINGS_ERROR_UPDATING_TITLE in:nil handler:nil];
}

- (void)on_get_account_info_success:(NSString *)accountInfo
{
    DLog(@"on_get_account_info");
    self.accountInfo = [accountInfo getJSONObject];
    self.hasLoadedAccountInfo = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_GET_ACCOUNT_INFO_SUCCESS object:nil];

    if ([delegate respondsToSelector:@selector(walletDidGetAccountInfo:)]) {
        [self.delegate walletDidGetAccountInfo:self];
    }
}

- (void)on_get_btc_exchange_rates_success:(NSString *)currencies
{
    DLog(@"on_get_btc_exchange_rates_success");
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

    self.btcRates = currencySymbolsWithNames;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_GET_ALL_CURRENCY_SYMBOLS_SUCCESS object:nil];

    if ([self.delegate respondsToSelector:@selector(walletDidGetBtcExchangeRates:)]) {
        [self.delegate walletDidGetBtcExchangeRates:self];
    }
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

//    [self getMessages];
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
            [[AlertViewPresenter sharedInstance] standardNotifyWithMessage:BC_STRING_NO_AVAILABLE_FUNDS title:BC_STRING_ERROR in:nil handler:nil];
        } else if ([message isEqualToString:ERROR_BELOW_DUST_THRESHOLD]) {
            id errorObject = error[DICTIONARY_KEY_MESSAGE][DICTIONARY_KEY_ERROR];
            uint64_t threshold = [errorObject isKindOfClass:[NSString class]] ? [error[DICTIONARY_KEY_MESSAGE][DICTIONARY_KEY_THRESHOLD] longLongValue] : [error[DICTIONARY_KEY_MESSAGE][DICTIONARY_KEY_ERROR][DICTIONARY_KEY_THRESHOLD] longLongValue];
            [[AlertViewPresenter sharedInstance] standardNotifyWithMessage:[NSString stringWithFormat:BC_STRING_MUST_BE_ABOVE_OR_EQUAL_TO_DUST_THRESHOLD, threshold] title:BC_STRING_ERROR in:nil handler:nil];
        } else if ([message isEqualToString:ERROR_FETCH_UNSPENT]) {
            [[AlertViewPresenter sharedInstance] standardNotifyWithMessage:BC_STRING_SOMETHING_WENT_WRONG_CHECK_INTERNET_CONNECTION title:BC_STRING_ERROR in:nil handler:nil];
        } else {
            [[AlertViewPresenter sharedInstance] standardNotifyWithMessage:message title:BC_STRING_ERROR in:nil handler:nil];
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
    [[AlertViewPresenter sharedInstance] standardNotifyWithMessage:error title:BC_STRING_ERROR in:nil handler:nil];
}

- (void)on_add_new_account
{
    DLog(@"on_add_new_account");

    [self subscribeToXPub:[self getXpubForAccount:[self getActiveAccountsCount:LegacyAssetTypeBitcoin] - 1 assetType:LegacyAssetTypeBitcoin] assetType:LegacyAssetTypeBitcoin];

    dispatch_async(dispatch_get_main_queue(), ^{
        [[LoadingViewPresenter sharedInstance] showBusyViewWithLoadingText:[LocalizationConstantsObjcBridge syncingWallet]];
    });
}

- (void)on_error_add_new_account:(NSString*)error
{
    DLog(@"on_error_generating_new_address");
    [[AlertViewPresenter sharedInstance] standardNotifyWithMessage:error title:BC_STRING_ERROR in:nil handler:nil];
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
        [[AlertViewPresenter sharedInstance] standardNotifyWithMessage:BC_STRING_INVALID_RECOVERY_PHRASE title:BC_STRING_ERROR in:nil handler:nil];
    } else if ([error isEqualToString:@""]) {
        [AlertViewPresenter.sharedInstance showNoInternetConnectionAlert];
    } else if ([error isEqualToString:ERROR_TIMEOUT_REQUEST]){
        [[AlertViewPresenter sharedInstance] standardNotifyWithMessage:LocalizationConstantsObjcBridge.timedOut title:BC_STRING_ERROR in:nil handler:nil];
    } else {
        [[AlertViewPresenter sharedInstance] standardNotifyWithMessage:error title:BC_STRING_ERROR in:nil handler:nil];
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

    dispatch_async(dispatch_get_main_queue(), ^{
        if ([totalReceived longLongValue] == 0) {
            self.emptyAccountIndex++;
            [[LoadingViewPresenter sharedInstance] updateBusyViewLoadingTextWithText:[NSString stringWithFormat:BC_STRING_LOADING_RECOVERING_WALLET_CHECKING_ARGUMENT_OF_ARGUMENT, self.emptyAccountIndex, self.emptyAccountIndex > RECOVERY_ACCOUNT_DEFAULT_NUMBER ? self.emptyAccountIndex : RECOVERY_ACCOUNT_DEFAULT_NUMBER]];
        } else {
            self.emptyAccountIndex = 0;
            self.recoveredAccountIndex++;
            [[LoadingViewPresenter sharedInstance] updateBusyViewLoadingTextWithText:[NSString stringWithFormat:BC_STRING_LOADING_RECOVERING_WALLET_ARGUMENT_FUNDS_ARGUMENT, self.recoveredAccountIndex, [NSNumberFormatter formatMoney:fundsInAccount]]];
        }
    });
}

- (void)on_error_downloading_account_settings
{
    DLog(@"on_error_downloading_account_settings");
    [[AlertViewPresenter sharedInstance] standardNotifyWithMessage:BC_STRING_SETTINGS_ERROR_LOADING_MESSAGE title:BC_STRING_SETTINGS_ERROR_LOADING_TITLE in:nil handler:nil];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:USER_DEFAULTS_KEY_LOADED_SETTINGS];
}

- (void)on_update_email_error
{
    [[AlertViewPresenter sharedInstance] standardNotifyWithMessage:BC_STRING_INVALID_EMAIL_ADDRESS title:BC_STRING_ERROR in:nil handler:nil];
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
    DLog(@"on_resend_two_factor_sms_success");
    if ([self.delegate respondsToSelector:@selector(walletDidResendTwoFactorSMS:)]) {
        [self.delegate walletDidResendTwoFactorSMS:self];
    } else {
        DLog(@"Error: delegate of class %@ does not respond to selector walletDidResendTwoFactorSMS:!", [delegate class]);
    }
}

- (void)on_resend_two_factor_sms_error:(NSString *)error
{
    [[AlertViewPresenter sharedInstance] standardNotifyWithMessage:error title:BC_STRING_ERROR in:nil handler:nil];
}

- (void)wrong_two_factor_code:(NSString *)error
{
    self.twoFactorInput = nil;
    [[AlertViewPresenter sharedInstance] standardNotifyWithMessage:error title:BC_STRING_ERROR in:nil handler:nil];
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

- (void)on_success_import_key_for_sending_from_watch_only
{
    [self loading_stop];

    DLog(@"on_success_import_key_for_sending_from_watch_only");
    if ([self.delegate respondsToSelector:@selector(sendFromWatchOnlyAddress)]) {
        [self.delegate sendFromWatchOnlyAddress];
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
        [self.delegate updateLoadedAllTransactions:[loadedAll boolValue]];
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
    if ([self.delegate respondsToSelector:@selector(walletDidRequireEmailAuthorization:)]) {
        [self.delegate walletDidRequireEmailAuthorization:self];
    } else {
        DLog(@"Error: delegate of class %@ does not respond to selector walletDidRequireEmailAuthorization!", [delegate class]);
    }
}

- (void)on_get_fiat_at_time_success:(NSNumber *)fiatAmount currencyCode:(NSString *)currencyCode assetType:(LegacyAssetType)assetType
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

- (void)did_archive_or_unarchive
{
    DLog(@"did_archive_or_unarchive");

    [self.btcSocket closeWithCode:WEBSOCKET_CODE_ARCHIVE_UNARCHIVE reason:WEBSOCKET_CLOSE_REASON_ARCHIVED_UNARCHIVED];
    [self.bchSocket closeWithCode:WEBSOCKET_CODE_ARCHIVE_UNARCHIVE reason:WEBSOCKET_CLOSE_REASON_ARCHIVED_UNARCHIVED];
}

- (void)did_get_swipe_addresses:(NSArray *)swipeAddresses asset_type:(LegacyAssetType)assetType
{
    DLog(@"did_get_swipe_addresses");

    if ([self.delegate respondsToSelector:@selector(didGetSwipeAddresses:assetType:)]) {
        [self.delegate didGetSwipeAddresses:swipeAddresses assetType:assetType];
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
    [[AlertViewPresenter sharedInstance] standardNotifyWithMessage:[error toString] title:BC_STRING_ERROR in:nil handler:nil];
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

- (void)did_fetch_bch_history
{
    if ([self.delegate respondsToSelector:@selector(didFetchBitcoinCashHistory)]) {
        [self.delegate didFetchBitcoinCashHistory];
    } else {
        DLog(@"Error: delegate of class %@ does not respond to selector didFetchBitcoinCashHistory!", [delegate class]);
    }
}

- (void)did_get_bitcoin_cash_exchange_rates:(NSDictionary *)rates
{
    NSString *currency = [self.accountInfo objectForKey:DICTIONARY_KEY_CURRENCY];
    double lastPrice = [[[rates objectForKey:currency] objectForKey:DICTIONARY_KEY_LAST] doubleValue];
    self.bitcoinCashConversion = [[[(NSDecimalNumber *)[NSDecimalNumber numberWithDouble:SATOSHI] decimalNumberByDividingBy: (NSDecimalNumber *)[NSDecimalNumber numberWithDouble:lastPrice]] stringValue] longLongValue];
    self.bitcoinCashExchangeRates = rates;
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
    NSNumber *btcRateNumber = [[[self.context evaluateScript:@"MyWalletPhone.currencyCodeForHardLimit()"] toString] isEqualToString:CURRENCY_CODE_USD] ? [[[WalletManager.sharedInstance.wallet btcRates] objectForKey:CURRENCY_CODE_USD] objectForKey:DICTIONARY_KEY_LAST] : [[[WalletManager.sharedInstance.wallet btcRates] objectForKey:CURRENCY_CODE_EUR] objectForKey:DICTIONARY_KEY_LAST];
    
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
        [[AlertViewPresenter sharedInstance] standardNotifyWithMessage:[NSString stringWithFormat:BC_STRING_ERROR_GETTING_BALANCE_ARGUMENT_ASSET_ARGUMENT_MESSAGE, currencySymbol, error] title:BC_STRING_ERROR in:nil handler:nil];
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
    if ([self.delegate respondsToSelector:@selector(didShiftPayment)]) {
        [self.delegate didShiftPayment];
    } else {
        DLog(@"Error: delegate of class %@ does not respond to selector didShiftPayment:!", [delegate class]);
    }
}

- (void)on_shift_payment_error:(NSDictionary *)result
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[LoadingViewPresenter sharedInstance] hideBusyView];

        NSString *errorMessage = [result objectForKey:DICTIONARY_KEY_MESSAGE];
        [[AlertViewPresenter sharedInstance] standardNotifyWithMessage:errorMessage title:BC_STRING_ERROR in:nil handler:nil];
    });
}

- (void)on_build_exchange_trade_success_from:(NSString *)from depositAmount:(NSString *)depositAmount fee:(NSNumber *)fee rate:(NSString *)rate minerFee:(NSString *)minerFee withdrawalAmount:(NSString *)withdrawalAmount expiration:(NSDate *)expirationDate
{
    NSDictionary *tradeInfo = @{
        DICTIONARY_KEY_DEPOSIT_AMOUNT : depositAmount,
        DICTIONARY_KEY_FEE : [[from lowercaseString] isEqualToString:[CURRENCY_SYMBOL_ETH lowercaseString]] ? [fee stringValue] : [NSNumberFormatter satoshiToBTC:[fee longLongValue]],
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

- (void)on_get_account_info_and_exchange_rates
{
    if ([self.delegate respondsToSelector:@selector(walletDidGetAccountInfoAndExchangeRates:)]) {
        [self.delegate walletDidGetAccountInfoAndExchangeRates:self];
    } else {
        DLog(@"Error: delegate of class %@ does not respond to selector didGetAvailableEthBalance:!", [delegate class]);
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

    [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.getRecoveryPhrase(\"%@\")", [secondPassword escapedForJS]]];
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

- (int)getActiveAccountsCount:(LegacyAssetType)assetType
{
    if (![self isInitialized]) {
        return 0;
    }

    if (assetType == LegacyAssetTypeBitcoin) {
        return [[[self.context evaluateScript:@"MyWalletPhone.getActiveAccountsCount()"] toNumber] intValue];
    } else if (assetType == LegacyAssetTypeBitcoinCash) {
        return [[[self.context evaluateScript:@"MyWalletPhone.bch.getActiveAccountsCount()"] toNumber] intValue];
    }
    return 0;

}

- (int)getAllAccountsCount:(LegacyAssetType)assetType
{
    if (![self isInitialized]) {
        return 0;
    }

    if (assetType == LegacyAssetTypeBitcoin) {
        return [[[self.context evaluateScript:@"MyWalletPhone.getAllAccountsCount()"] toNumber] intValue];
    } else if (assetType == LegacyAssetTypeBitcoinCash) {
        return [[[self.context evaluateScript:@"MyWalletPhone.bch.getAllAccountsCount()"] toNumber] intValue];
    }
    return 0;
}

- (int)getDefaultAccountIndexForAssetType:(LegacyAssetType)assetType
{
    if (![self isInitialized]) {
        return 0;
    }

    if (assetType == LegacyAssetTypeBitcoin) {
        return [[[self.context evaluateScript:@"MyWalletPhone.getDefaultAccountIndex()"] toNumber] intValue];
    } else if (assetType == LegacyAssetTypeBitcoinCash) {
        return [[[self.context evaluateScript:@"MyWalletPhone.bch.getDefaultAccountIndex()"] toNumber] intValue];
    }
    return 0;
}

- (void)setDefaultAccount:(int)index assetType:(LegacyAssetType)assetType
{
    if (![self isInitialized]) {
        return;
    }

    if (assetType == LegacyAssetTypeBitcoin) {
        [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.setDefaultAccount(%d)", index]];
        self.isSettingDefaultAccount = YES;
    } else if (assetType == LegacyAssetTypeBitcoinCash) {
        [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.bch.setDefaultAccount(%d)", index]];
        [self getHistory];
        if ([self.delegate respondsToSelector:@selector(didSetDefaultAccount)]) {
            [self.delegate didSetDefaultAccount];
        } else {
            DLog(@"Error: delegate of class %@ does not respond to selector didSetDefaultAccount!", [delegate class]);
        }
    }
}

- (BOOL)hasLegacyAddresses:(LegacyAssetType)assetType
{
    if (![self isInitialized]) {
        return NO;
    }

    if (assetType == LegacyAssetTypeBitcoin) {
        return [[self.context evaluateScript:@"MyWallet.wallet.addresses.length > 0"] toBool];
    } else if (assetType == LegacyAssetTypeBitcoinCash) {
        return [[self.context evaluateScript:@"MyWalletPhone.bch.hasLegacyAddresses()"] toBool];
    }
    return NO;
}

- (uint64_t)getTotalActiveBalance
{
    if (![self isInitialized]) {
        return 0;
    }

    return [[[self.context evaluateScript:@"MyWalletPhone.totalActiveBalance()"] toNumber] longLongValue];
}

- (uint64_t)getWatchOnlyBalance
{
    if (![self isInitialized]) {
        return 0;
    }

    return [[[self.context evaluateScript:@"MyWalletPhone.watchOnlyBalance()"] toNumber] longLongValue];
}

- (BOOL)hasWatchOnlyAddresses
{
    if (![self isInitialized]) {
        return NO;
    }

    return [[self.context evaluateScript:@"MyWalletPhone.hasWatchOnlyAddresses()"] toBool];
}

- (uint64_t)getTotalBalanceForActiveLegacyAddresses:(LegacyAssetType)assetType
{
    if (![self isInitialized]) {
        return 0;
    }

    if (assetType == LegacyAssetTypeBitcoin) {
        return [[[self.context evaluateScript:@"MyWallet.wallet.balanceActiveLegacy"] toNumber] longLongValue];
    } else if (assetType == LegacyAssetTypeBitcoinCash) {
        return [[[self.context evaluateScript:@"MyWalletPhone.bch.balanceActiveLegacy()"] toNumber] longLongValue];
    }
    DLog(@"Error getting total balance for active legacy addresses: unsupported asset type!");
    return 0;
}

- (uint64_t)getTotalBalanceForSpendableActiveLegacyAddresses
{
    if (![self isInitialized]) {
        return 0;
    }

    return [[[self.context evaluateScript:@"MyWallet.wallet.balanceSpendableActiveLegacy"] toNumber] longLongValue];
}

- (id)getBalanceForAccount:(int)account assetType:(LegacyAssetType)assetType
{
    if (assetType == LegacyAssetTypeBitcoin) {
        if (![self isInitialized]) {
            return @0;
        }
        return [[self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.getBalanceForAccount(%d)", account]] toNumber];
    } else if (assetType == LegacyAssetTypeBitcoinCash) {
        if (![self isInitialized]) {
            return @0;
        }
        return [[self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.bch.getBalanceForAccount(%d)", account]] toNumber];
    } else if (assetType == LegacyAssetTypeEther) {
        if (![self isInitialized]) {
            return nil;
        }
        if ([WalletManager.sharedInstance.wallet hasEthAccount]) {
            return [[self.context evaluateScript:@"MyWalletPhone.getEthBalance()"] toString];
        }
    }
    return nil;
}

- (NSString *)getLabelForAccount:(int)account assetType:(LegacyAssetType)assetType
{
    if (![self isInitialized]) {
        return nil;
    }

    if (assetType == LegacyAssetTypeBitcoin) {
        return [[self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.getLabelForAccount(%d)", account]] toString];
    } else if (assetType == LegacyAssetTypeBitcoinCash) {
        return [[self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.bch.getLabelForAccount(%d)", account]] toString];
    } else if (assetType == LegacyAssetTypeEther) {
        return [[self.context evaluateScript:@"MyWalletPhone.getLabelForEthAccount()"] toString];
    }
    return nil;
}

- (void)setLabelForAccount:(int)account label:(NSString *)label assetType:(LegacyAssetType)assetType
{
    if (!Reachability.hasInternetConnection) {
        [AlertViewPresenter.sharedInstance showNoInternetConnectionAlert];
        return;
    }

    if ([self isInitialized]) {
        if (assetType == LegacyAssetTypeBitcoin) {
            self.isSyncing = YES;
            [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.setLabelForAccount(%d, \"%@\")", account, [label escapedForJS]]];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSetLabelForAccount) name:[ConstantsObjcBridge notificationKeyBackupSuccess] object:nil];
        } else if (assetType == LegacyAssetTypeBitcoinCash) {
            [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.bch.setLabelForAccount(%d, \"%@\")", account, [label escapedForJS]]];
            [self getHistory];
        }
    }
}

- (void)didSetLabelForAccount
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[ConstantsObjcBridge notificationKeyBackupSuccess] object:nil];

    [self getHistory];
}

- (void)createAccountWithLabel:(NSString *)label
{
    if ([self isInitialized] && Reachability.hasInternetConnection) {
        // Show loading text
        [self loading_start_create_account];

        self.isSyncing = YES;
        self.shouldLoadMetadata = YES;

        // Wait a little bit to make sure the loading text is showing - then execute the blocking and kind of long create account
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(ANIMATION_DURATION * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.createAccount(\"%@\")", [label escapedForJS]]];
        });
    }
}

- (NSString *)getReceiveAddressOfDefaultAccount:(LegacyAssetType)assetType
{
    if (assetType == LegacyAssetTypeBitcoin) {
        return [[self.context evaluateScript:@"MyWalletPhone.getReceiveAddressOfDefaultAccount()"] toString];
    } else if (assetType == LegacyAssetTypeBitcoinCash) {
        return [[self.context evaluateScript:@"MyWalletPhone.bch.getReceiveAddressOfDefaultAccount()"] toString];
    }
    DLog(@"Warning: unknown asset type!");
    return nil;
}

- (NSString *)getReceiveAddressForAccount:(int)account assetType:(LegacyAssetType)assetType
{
    if (![self isInitialized]) {
        return nil;
    }

    if (assetType == LegacyAssetTypeBitcoin) {
        return [[self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.getReceivingAddressForAccount(%d)", account]] toString];
    } else if (assetType == LegacyAssetTypeBitcoinCash) {
        return [[self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.bch.getReceivingAddressForAccount(%d)", account]] toString];
    }
    DLog(@"Warning: unknown asset type!");
    return nil;
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

    [AppCoordinator.sharedInstance reload];
}

- (void)logging_out
{
    DLog(@"logging_out");


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
    dispatch_async(dispatch_get_main_queue(), ^{
        [[LoadingViewPresenter sharedInstance] showBusyViewWithLoadingText:BC_STRING_DECRYPTING_PRIVATE_KEY];
    });

    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData * data = [self _internal_crypto_scrypt:_password salt:salt n:[N unsignedLongLongValue] r:[r unsignedIntValue] p:[p unsignedIntValue] dkLen:[derivedKeyLen unsignedIntValue]];

        dispatch_async(dispatch_get_main_queue(), ^{
            if (data) {
                [_success callWithArguments:@[[data hexadecimalString]]];
            } else {
                [[LoadingViewPresenter sharedInstance] hideBusyView];
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

    [[AlertViewPresenter sharedInstance] standardNotifyWithMessage:decription title:BC_STRING_ERROR in:nil handler:nil];
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
#ifdef DEBUG
    [self updateServerURL:[[BlockchainAPI sharedInstance] walletUrl]];

    [self updateWebSocketURL:[[BlockchainAPI sharedInstance] webSocketUri]];

    [self updateAPIURL:[[BlockchainAPI sharedInstance] apiUrl]];

    BOOL testnetOn = [[[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_KEY_ENV] isEqual:ENV_INDEX_TESTNET];
    NSString *network;
    if (testnetOn) {
        network = NETWORK_TESTNET;
    } else {
        network = NETWORK_MAINNET;
    }

    [self.context evaluateScript:[NSString stringWithFormat:@"MyWalletPhone.changeNetwork(\"%@\")", [network escapedForJS]]];
#endif
}

@end
