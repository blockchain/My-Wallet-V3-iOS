var Buffer = Blockchain.Buffer;

var MyWallet = Blockchain.MyWallet;
var WalletStore = Blockchain.WalletStore;
var WalletCrypto = Blockchain.WalletCrypto;
var BlockchainAPI = Blockchain.API;
var BlockchainSettingsAPI = Blockchain.BlockchainSettingsAPI;
var Helpers = Blockchain.Helpers;
var Payment = Blockchain.Payment;
var WalletNetwork = Blockchain.WalletNetwork;
var Address = Blockchain.Address;
var Bitcoin = Blockchain.Bitcoin;
var BigInteger = Blockchain.BigInteger;
var BIP39 = Blockchain.BIP39;
var Networks = Blockchain.Networks;
var ECDSA = Blockchain.ECDSA;
var Metadata = Blockchain.Metadata;
var SharedMetadata = Blockchain.SharedMetadata;
var Contacts = Blockchain.Contacts;
var EthSocket = Blockchain.EthSocket;
var BlockchainSocket = Blockchain.BlockchainSocket;

if (typeof Buffer.prototype.reverse !== 'function') {
    // required for sending BCH on iOS 9
    console.log('reverse not defined - polyfill');
    Buffer.prototype.reverse = function () {
        return [].reverse.call(this)
    }
}

function NativeEthSocket () {
  this.handlers = []
}

NativeEthSocket.prototype.on = function (type, callback) {
}

NativeEthSocket.prototype.onMessage = function (msg) {
  this.handlers.forEach(function (handler) {
    handler(msg)
  })
}

NativeEthSocket.prototype.subscribeToAccount = function (account) {
  var accountMsg = EthSocket.accountSub(account)
  objc_eth_socket_send(accountMsg)
  var handler = EthSocket.accountMessageHandler(account)
  this.handlers.push(handler)
}

NativeEthSocket.prototype.subscribeToBlocks = function (ethWallet) {
  var blockMsg = EthSocket.blocksSub(ethWallet)
  objc_eth_socket_send(blockMsg)
  var handler = EthSocket.blockMessageHandler(ethWallet)
  this.handlers.push(handler)
}

var ethSocketInstance = new NativeEthSocket();

APP_NAME = 'javascript_iphone_app';
APP_VERSION = '3.0';
API_CODE = '35e77459-723f-48b0-8c9e-6e9e8f54fbd3';
// Don't use minified JS files when loading web worker scripts
min = false;

// Set the API code for the iOS Wallet for the server calls
BlockchainAPI.API_CODE = API_CODE;
BlockchainAPI.AJAX_TIMEOUT = 30000; // 30 seconds
BlockchainAPI.API_ROOT_URL = 'https://api.blockchain.info/'

var MyWalletPhone = {};
var currentPayment = null;
var currentEtherPayment = null;
var currentBitcoinCashPayment = null;
var currentShiftPayment = null;
var transferAllBackupPayment = null;
var transferAllPayments = {};

var walletOptions = new WalletOptions(BlockchainAPI);

// Register for JS event handlers and forward to Obj-C handlers

WalletStore.addEventListener(function (event, obj) {
    var eventsWithObjCHandlers = ["did_fail_set_guid", "did_multiaddr", "did_set_latest_block", "error_restoring_wallet", "logging_out", "on_backup_wallet_start", "on_backup_wallet_error", "on_backup_wallet_success", "on_tx_received", "ws_on_close", "ws_on_open", "did_load_wallet"];

    if (event == 'msg') {
        if (obj.type == 'error') {

            if (obj.message != "For Improved security add an email address to your account.") {
                // Cancel busy view in case any error comes in - except for add email, that's handled differently in makeNotice
                objc_loading_stop();
            }

            if (obj.message == "Error Downloading Account Settings") {
                on_error_downloading_account_settings();
                return;
            }

            // Some messages are JSON objects and the error message is in the map
            try {
                var messageJSON = JSON.parse(obj.message);
                if (messageJSON && messageJSON.initial_error) {
                    objc_makeNotice_id_message(''+obj.type, ''+obj.code, ''+messageJSON.initial_error);
                    return;
                }
            } catch (e) {
            }
            objc_makeNotice_id_message(''+obj.type, ''+obj.code, ''+obj.message);
        } else if (obj.type == 'success') {
            objc_makeNotice_id_message(''+obj.type, ''+obj.code, ''+obj.message);
        }
            return;
    }

    if (eventsWithObjCHandlers.indexOf(event) == -1) {
        return;
    }

    var codeToExecute = ('objc_'.concat(event)).concat('()');
    var tmpFunc = new Function(codeToExecute);
    tmpFunc(obj);
});


// My Wallet phone functions

MyWalletPhone.getAPICode = function() {
    return API_CODE;
}

MyWalletPhone.upgradeToV3 = function(firstAccountName) {
    var success = function () {
        console.log('Upgraded legacy wallet to HD wallet');

        MyWallet.wallet.getHistory();
        objc_loading_stop();
        objc_upgrade_success();
    };

    var error = function (e) {
        console.log('Error upgrading legacy wallet to HD wallet: ' + e);
        objc_loading_stop();
    };

    if (MyWallet.wallet.isDoubleEncrypted) {
        MyWalletPhone.getSecondPassword(function (pw) {
          MyWallet.wallet.upgradeToV3(firstAccountName, pw, success, error);
        });
    }
    else {
        MyWallet.wallet.upgradeToV3(firstAccountName, null, success, error);
    }
};

MyWalletPhone.createAccount = function(label) {
    var success = function () {
        console.log('Created new account');

        objc_loading_stop();

        objc_on_add_new_account();

        objc_reload();
    };

    var error = function (error) {
        objc_on_error_add_new_account(error);
    }

    if (MyWallet.wallet.isDoubleEncrypted) {
        MyWalletPhone.getSecondPassword(function (pw) {
          MyWallet.wallet.newAccount(label, pw, null, success);
        });
    }
    else {
        MyWallet.wallet.newAccount(label, null, null, success);
    }
};

MyWalletPhone.getActiveAccounts = function() {
    if (!MyWallet.wallet.isUpgradedToHD) {
        console.log('Warning: Getting accounts when wallet has not upgraded!');
        return [];
    }

    var accounts = MyWallet.wallet.hdwallet.accounts;

    var activeAccounts = accounts.filter(function(account) { return account.archived === false; });

    return activeAccounts;
};

MyWalletPhone.getIndexOfActiveAccount = function(num) {
    if (!MyWallet.wallet.isUpgradedToHD) {
        console.log('Warning: Getting accounts when wallet has not upgraded!');
        return 0;
    }

    var activeAccounts = MyWalletPhone.getActiveAccounts();

    var realNum = activeAccounts[num].index;

    return realNum;
};

MyWalletPhone.getDefaultAccountIndex = function() {
    if (!MyWallet.wallet.isUpgradedToHD) {
        console.log('Warning: Getting accounts when wallet has not upgraded!');
        return 0;
    }

    var accounts = MyWallet.wallet.hdwallet.accounts;

    var index = MyWallet.wallet.hdwallet.defaultAccountIndex;

    var defaultAccountIndex = null;
    for (var i = 0; i < accounts.length; i++) {
        var account = accounts[i];
        if (account.index === index) {
            defaultAccountIndex = i;
        }
    }

    if (defaultAccountIndex) {
        return defaultAccountIndex;
    }

    return 0;
}

MyWalletPhone.setDefaultAccount = function(num) {
    if (!MyWallet.wallet.isUpgradedToHD) {
        console.log('Warning: Getting accounts when wallet has not upgraded!');
        return 0;
    }

    MyWallet.wallet.hdwallet.defaultAccountIndex = num;
}

MyWalletPhone.getActiveAccountsCount = function() {
    if (!MyWallet.wallet.isUpgradedToHD) {
        console.log('Warning: Getting accounts when wallet has not upgraded!');
        return 0;
    }

    var activeAccounts = MyWalletPhone.getActiveAccounts();

    return activeAccounts.length;
};

MyWalletPhone.getAllTransactionsCount = function() {
    return MyWallet.wallet.txList.transactionsForIOS().length;
}

MyWalletPhone.getAllAccountsCount = function() {
    if (!MyWallet.wallet.isUpgradedToHD) {
        console.log('Warning: Getting accounts when wallet has not upgraded!');
        return 0;
    }

    return MyWallet.wallet.hdwallet.accounts.length;
};

MyWalletPhone.getBalanceForAccount = function(num) {
    if (!MyWallet.wallet.isUpgradedToHD) {
        console.log('Warning: Getting accounts when wallet has not upgraded!');
        return 0;
    }

    return MyWallet.wallet.hdwallet.accounts[num].balance;
};

MyWalletPhone.totalActiveBalance = function() {
    if (!MyWallet.wallet.isUpgradedToHD) {
        console.log('Warning: Getting accounts when wallet has not upgraded!');
        return MyWallet.wallet.balanceSpendableActiveLegacy;
    }

    return MyWallet.wallet.hdwallet.balanceActiveAccounts + MyWallet.wallet.balanceSpendableActiveLegacy;
}

MyWalletPhone.watchOnlyBalance = function() {
    return MyWallet.wallet.activeKeys
    .filter(function (k) { return k.isWatchOnly; })
    .map(function (k) { return k.balance; })
    .reduce(Helpers.add, 0);
}

MyWalletPhone.getLabelForAccount = function(num) {
    if (!MyWallet.wallet.isUpgradedToHD) {
        console.log('Warning: Getting accounts when wallet has not upgraded!');
        return '';
    }

    return MyWallet.wallet.hdwallet.accounts[num].label;
};

MyWalletPhone.setLabelForAccount = function(num, label) {
    if (!MyWallet.wallet.isUpgradedToHD) {
        console.log('Warning: Getting accounts when wallet has not upgraded!');
        return;
    }

    MyWallet.wallet.hdwallet.accounts[num].label = label;
};

MyWalletPhone.isAccountNameValid = function(name) {
    if (!MyWallet.wallet.isUpgradedToHD) {
        console.log('Warning: Getting accounts when wallet has not upgraded!');
        return false;
    }

    var accounts = MyWallet.wallet.hdwallet.accounts;
    for (var i = 0; i < accounts.length; i++) {
        var account = accounts[i];
        if (account.label == name) {
            return false;
        }
    }

    return true;
}

MyWalletPhone.isAddressAvailable = function(address) {
    return MyWallet.wallet.key(address) != null && !MyWallet.wallet.key(address).archived;
}

MyWalletPhone.isAccountAvailable = function(num) {
    if (!MyWallet.wallet.isUpgradedToHD) {
        console.log('Warning: Getting accounts when wallet has not upgraded!');
        return false;
    }

    return MyWallet.wallet.hdwallet.accounts[num] != null && !MyWallet.wallet.hdwallet.accounts[num].archived;
}

MyWalletPhone.getReceivingAddressForAccount = function(num) {
    if (!MyWallet.wallet.isUpgradedToHD) {
        console.log('Warning: Getting accounts when wallet has not upgraded!');
        return '';
    }

    return MyWallet.wallet.hdwallet.accounts[num].receiveAddress;
};

MyWalletPhone.isArchived = function(accountOrAddress) {
    if (Helpers.isNumber(accountOrAddress) && accountOrAddress >= 0) {

        if (MyWallet.wallet.isUpgradedToHD) {
            if (MyWallet.wallet.hdwallet.accounts[accountOrAddress] == null) {
                return_to_addresses_screen();
                return false;
            }
            return MyWallet.wallet.hdwallet.accounts[accountOrAddress].archived;
        } else {
            console.log('Warning: Getting accounts when wallet has not upgraded!');
            return false;
        }
    } else if (accountOrAddress) {

        if (MyWallet.wallet.key(accountOrAddress) == null) {
            return_to_addresses_screen();
            return false;
        }

        return MyWallet.wallet.key(accountOrAddress).archived;
    }

    return false;
}

MyWalletPhone.toggleArchived = function(accountOrAddress) {

    var didArchive = false;

    if (Helpers.isNumber(accountOrAddress) && accountOrAddress >= 0) {
        if (MyWallet.wallet.isUpgradedToHD) {
            MyWallet.wallet.hdwallet.accounts[accountOrAddress].archived = !MyWallet.wallet.hdwallet.accounts[accountOrAddress].archived;
            didArchive = MyWallet.wallet.hdwallet.accounts[accountOrAddress].archived
        } else {
            console.log('Warning: Getting accounts when wallet has not upgraded!');
            return '';
        }
    } else if (accountOrAddress) {
        MyWallet.wallet.key(accountOrAddress).archived = !MyWallet.wallet.key(accountOrAddress).archived;
        didArchive =  MyWallet.wallet.key(accountOrAddress).archived;
    }

    if (didArchive) {
        MyWalletPhone.get_history();
    }

    objc_did_archive_or_unarchive();
}

MyWalletPhone.archiveTransferredAddresses = function(addresses) {

    var parsedAddresses = JSON.parse(addresses);

    for (var index = 0; index < parsedAddresses.length; index++) {
        MyWallet.wallet.key(parsedAddresses[index]).archived = true;
    }
}

MyWalletPhone.createNewBitcoinPayment = function() {
    console.log('Creating new bitcoin payment')
    currentPayment = MyWallet.wallet.createPayment();

    currentPayment.on('error', function(errorObject) {
      var errorDictionary = {
        'message':{'error': errorObject['error']}
      };
      objc_on_error_update_fee(errorDictionary);
    });

    currentPayment.on('message', function(object) {
      objc_on_payment_notice(object['text']);
    });
}

MyWalletPhone.changePaymentFrom = function(from, isAdvanced) {
    if (currentPayment) {
        currentPayment.from(from).then(function(x) {
          if (x) {
            if (x.from != null) objc_update_send_balance_fees(isAdvanced ? x.balance : x.sweepAmount, x.fees);
          }
          return x;
        });
    } else {
        console.log('Payment error: null payment object!');
    }
}

MyWalletPhone.changePaymentTo = function(to) {
    if (currentPayment) {
        currentPayment.to(to);
    } else {
        console.log('Payment error: null payment object!');
    }
}

MyWalletPhone.changePaymentAmount = function(amount) {
    if (currentPayment) {
        currentPayment.amount(amount);
    } else {
        console.log('Payment error: null payment object!');
    }
}

MyWalletPhone.getSurgeStatus = function() {
    if (currentPayment) {
        currentPayment.payment.then(function (x) {
          objc_update_surge_status(x.fees.default.surge);
          return x;
        });
    } else {
        console.log('Payment error: null payment object!');
    }
}

MyWalletPhone.checkIfUserIsOverSpending = function() {

    var checkForOverSpending = function(x) {
        objc_check_max_amount_fee(x.sweepAmount, x.sweepFee);
        console.log('checking for overspending: maxAmount and fee are ' + x.sweepAmount + ',' + x.sweepFee);
        return x;
    }

    if (currentPayment) {
        currentPayment.payment.then(checkForOverSpending).catch(function(error) {
          var errorArgument;
          if (error.error) {
            errorArgument = error.error;
          } else {
            errorArgument = error.message;
          }
          console.log('error checking for overspending: ' + errorArgument);
          objc_on_error_update_fee(errorArgument);
          return error.payment;
        });
    } else {
        console.log('Payment error: null payment object!');
    }
}

MyWalletPhone.changeSatoshiPerByte = function(satoshiPerByte, updateType) {
    console.log('changing satoshi per byte to ' + satoshiPerByte);
    var buildFailure = function (error) {
        console.log('Error changing satoshi per byte');
        console.log(JSON.stringify(error));

        var errorArgument;
        if (error.error) {
            errorArgument = error.error;
        } else {
            errorArgument = error.message;
        }

        console.log('error updating fee: ' + errorArgument);

        objc_on_error_update_fee(errorArgument, updateType);

        return error.payment;
    }

    if (currentPayment) {
        currentPayment.updateFeePerKb(satoshiPerByte).build().then(function (x) {
          objc_did_change_satoshi_per_byte_dust_show_summary(x.sweepAmount, x.finalFee, x.extraFeeConsumption, updateType);
          return x;
        }).catch(buildFailure);
    } else {
        console.log('Payment error: null payment object!');
    }
}

MyWalletPhone.sweepPaymentRegular = function() {
    if (currentPayment) {
        currentPayment.useAll().then(function (x) {
          MyWalletPhone.updateSweep(false, false);
          return x;
        });
    } else {
        console.log('Payment error: null payment object!');
    }
}

MyWalletPhone.sweepPaymentRegularThenConfirm = function() {

    var buildFailure = function (error) {
        console.log('buildfailure');

        var errorArgument;
        if (error.error) {
            errorArgument = error.error;
        } else {
            errorArgument = error.message;
        }

        console.log('error sweeping regular then confirm: ' + errorArgument);
        objc_on_error_update_fee(errorArgument);

        return error.payment;
    }

    if (currentPayment) {
        currentPayment.useAll().build().then(function(x) {
          MyWalletPhone.updateSweep(false, true);
          return x;
        }).catch(buildFailure);
    } else {
        console.log('Payment error: null payment object!');
    }
}

MyWalletPhone.sweepPaymentAdvanced = function(fee) {
    if (currentPayment) {
        currentPayment.useAll().then(function (x) {
          MyWalletPhone.updateSweep(true, false);
          return x;
        });
    } else {
        console.log('Payment error: null payment object!');
    }
}

MyWalletPhone.sweepPaymentAdvancedThenConfirm = function(fee) {
    var buildFailure = function (error) {
        console.log('buildfailure');

        var errorArgument;
        if (error.error) {
            errorArgument = error.error;
        } else {
            errorArgument = error.message;
        }

        console.log('error sweeping advanced then confirm: ' + errorArgument);
        objc_on_error_update_fee(errorArgument);

        return error.payment;
    }

    if (currentPayment) {
        currentPayment.useAll(fee).build().then(function(x) {
          MyWalletPhone.updateSweep(true, true);
          return x;
        }).catch(buildFailure);
    } else {
        console.log('Payment error: null payment object!');
    }
}

MyWalletPhone.updateSweep = function(isAdvanced, willConfirm) {

    if (currentPayment) {
        currentPayment.payment.then(function(x) {
          console.log('updated fee: ' + x.finalFee);
          console.log('SweepAmount: ' + x.amounts);
          objc_update_max_amount_fee_dust_willConfirm(x.amounts[0], x.finalFee, x.extraFeeConsumption, willConfirm);
          return x;
        }).catch(function(error) {
          var errorArgument;
          if (error.error) {
            errorArgument = error.error;
          } else {
            errorArgument = error.message;
          }
          console.log('error sweeping payment: ' + errorArgument);
          objc_on_error_update_fee(errorArgument);
        });
    } else {
        console.log('Payment error: null payment object!');
    }
}

MyWalletPhone.getTransactionFeeWithUpdateType = function(updateType) {
    if (currentPayment) {

        var buildFailure = function(error) {

            var errorArgument;
            if (error.error) {
                errorArgument = error.error;
            } else {
                errorArgument = error.message;
            }

            console.log('error updating fee: ' + errorArgument);
            objc_on_error_update_fee(errorArgument, updateType);

            return error.payment;
        }

        currentPayment.prebuild().build().then(function (x) {
          objc_did_get_fee_dust_txSize(x.finalFee, x.extraFeeConsumption, x.txSize);
          return x;
        }).catch(buildFailure);

    } else {
        console.log('Payment error: null payment object!');
    }
}

MyWalletPhone.updateTotalAvailableAndFinalFee = function() {
    if (currentPayment) {
        currentPayment.payment.then(function(x) {
          objc_update_total_available_final_fee(x.sweepAmount, x.finalFee)
        }).catch(function(error) {
          console.log(error);
        });
    }
}

MyWalletPhone.setPbkdf2Iterations = function(iterations) {
    var success = function () {
        console.log('Updated PBKDF2 iterations');
    };

    var error = function () {
        console.log('Error updating PBKDF2 iterations');
    };

    if (MyWallet.wallet.isDoubleEncrypted) {
        MyWalletPhone.getSecondPassword(function (pw) {
          MyWallet.setPbkdf2Iterations(iterations, success, error, pw);
        });
    }
    else {
        MyWallet.setPbkdf2Iterations(iterations, success, error, null);
    }
};

MyWalletPhone.getLegacyArchivedAddresses = function() {
    return MyWallet.wallet.addresses.filter(function (addr) {
      return MyWallet.wallet.key(addr).archived === true;
    });
};

MyWalletPhone.getSessionToken = function() {
    WalletNetwork.obtainSessionToken().then(function (sessionToken) {
      objc_on_get_session_token(sessionToken);
    });
}

MyWalletPhone.login = function(user_guid, shared_key, resend_code, inputedPassword, sessionToken, twoFACode, twoFAType, success, needs_two_factor_code, wrong_two_factor_code, other_error) {

    // Timing
    var t0 = new Date().getTime(), t1;

    var logTime = function(name) {
        t1 = new Date().getTime();

        console.log('----------');
        console.log('Execution time ' + name + ': ' + (t1 - t0) + ' milliseconds.')
        console.log('----------');

        t0 = t1;
    };

    var fetch_success = function() {

        logTime('download');
        objc_loading_start_decrypt_wallet();
    };

    var decrypt_success = function() {
        logTime('decrypt');

        objc_did_decrypt();

        objc_loading_start_build_wallet();
    };

    var build_hd_success = function() {
        logTime('build HD wallet');

        objc_loading_start_multiaddr();
    };

    var login_success = function() {
        logTime('fetch history, account info');

        objc_loading_stop();

        objc_did_load_wallet();

        MyWallet.wallet.useEthSocket(ethSocketInstance);
    };

    var history_error = function(error) {console.log(error);
        console.log('login: error getting history');
        objc_on_error_get_history(error);
        return Promise.reject('history_error');
    }

    var success = function() {
        logTime('wallet login');
        var getHistory = MyWalletPhone.getHistoryForAllAssets().catch(history_error);
        var fetchAccount = MyWallet.wallet.fetchAccountInfo().catch(other_error);
        Promise.all([getHistory, fetchAccount]).then(login_success);
    };

    var other_error = function(e) {
        console.log('login: other error: ' + e);
        objc_loading_stop();
        objc_error_other_decrypting_wallet(e);
        return Promise.reject(e);
    };

    var needs_two_factor_code = function(type) {
        console.log('login: needs 2fa of type: ' + WalletStore.get2FATypeString());
        objc_loading_stop();
        objc_on_fetch_needs_two_factor_code();
    };

    var wrong_two_factor_code = function(error) {
        console.log('wrong two factor code: ' + error);
        objc_loading_stop();
        objc_wrong_two_factor_code(error);
    }

    var authorization_required = function() {
        console.log('authorization required');
        objc_loading_stop();
        objc_show_email_authorization_alert();
    }

    objc_loading_start_download_wallet();

    var credentials = {};

    credentials.twoFactor = twoFACode ? {type: WalletStore.get2FAType(), code : twoFACode} : null;

    if (shared_key) {
        console.log('setting sharedKey');
        credentials.sharedKey = shared_key;
    }

    if (sessionToken) {
        console.log('setting sessionToken');
        credentials.sessionToken = sessionToken;
    }

    var callbacks = {
        needsTwoFactorCode: needs_two_factor_code,
        wrongTwoFactorCode: wrong_two_factor_code,
        authorizationRequired: authorization_required,
        didFetch: fetch_success,
        didDecrypt: decrypt_success,
        didBuildHD: build_hd_success
    }

    walletOptions.fetch().then(function() {
        Blockchain.constants.SHAPE_SHIFT_KEY = walletOptions.getValue().shapeshift.apiKey;
        MyWallet.login(user_guid, inputedPassword, credentials, callbacks).then(success).catch(other_error);
    });
};

MyWalletPhone.getInfoForTransferAllFundsToAccount = function() {

    var totalAddressesUsed = [];
    var addresses = MyWallet.wallet.spendableActiveAddresses;
    var payments = [];
    transferAllPayments = {};

    var updateInfo = function(payments) {
        var totalAmount = payments.filter(function(p) {
          return p.amounts[0] >= Bitcoin.networks.bitcoin.dustThreshold;
        }).map(function (p) {
          totalAddressesUsed.push(p.from[0]);
          return p.amounts[0];
        }).reduce(Helpers.add, 0);

        var totalFee = payments.filter(function(p) {
          return p.finalFee > 0 && p.amounts[0] >= Bitcoin.networks.bitcoin.dustThreshold;
        }).map(function (p) {
          return p.finalFee;
        }).reduce(Helpers.add, 0);

        objc_update_transfer_all_amount_fee_addressesUsed(totalAmount, totalFee, totalAddressesUsed);
    }

    var createPayment = function(address) {
      return new Promise(function (resolve) {
        var payment = MyWallet.wallet.createPayment().from(address).useAll();
        transferAllPayments[address] = payment;
        payment.sideEffect(function (p) {
          resolve(p);
        });
      })
    }

    MyWalletPhone.preparePaymentsForTransferAll(addresses, createPayment, updateInfo, payments, addresses.length);
}

MyWalletPhone.preparePaymentsForTransferAll = function(addresses, paymentSetup, updateInfo, payments, totalCount) {
    if (addresses.length > 0) {
      objc_loading_start_transfer_all(totalCount - addresses.length + 1, totalCount);
      var newPayment = paymentSetup(addresses[0]);
      newPayment.then(function (p) {
        setTimeout(function() {
          if (p) {
            payments.push(p);
            addresses.shift();
            MyWalletPhone.preparePaymentsForTransferAll(addresses, paymentSetup, updateInfo, payments, totalCount);
          }
          return p;
        }, 0)
      }).catch(function(e){
        console.log(e);
      });
    } else {
        updateInfo(payments);
    }
}

MyWalletPhone.transferAllFundsToAccount = function(accountIndex, isFirstTransfer, address, secondPassword, onSendScreen) {
    var totalAmount = 0;
    var totalFee = 0;

    var buildFailure = function (error) {
        console.log('failure building transfer all payment');

        var errorArgument;
        if (error.error) {
            errorArgument = error.error;
        } else {
            errorArgument = error.message;
        }

        console.log('error transfering all funds: ' + errorArgument);

        // pass second password to frontend in case we want to continue sending from other addresses
        objc_on_error_transfer_all_secondPassword(errorArgument, secondPassword);

        return error.payment;
    }

    var showSummaryOrSend = function (payment) {
        if (isFirstTransfer) {
            console.log('builtTransferAll: from:' + payment.from);
            console.log('builtTransferAll: to:' + payment.to);
            objc_show_summary_for_transfer_all();
        } else {
            console.log('builtTransferAll: from:' + payment.from);
            console.log('builtTransferAll: to:' + payment.to);
            objc_send_transfer_all(secondPassword);
        }

        return payment;
    };

    if (onSendScreen) {
        currentPayment = transferAllPayments[address];
        if (currentPayment) {
            currentPayment.to(accountIndex).build().then(showSummaryOrSend).catch(buildFailure);
        } else {
            console.log('Payment error: null payment object!');
        }
    } else {
        transferAllBackupPayment = transferAllPayments[address];
        if (transferAllBackupPayment) {
            transferAllBackupPayment.to(accountIndex).build().then(showSummaryOrSend).catch(buildFailure);
        } else {
            console.log('Payment error: null payment object!');
        }
    }
}

MyWalletPhone.transferFundsToDefaultAccountFromAddress = function(address) {
    currentPayment = MyWallet.wallet.createPayment();

    var buildFailure = function (error) {
        console.log('buildfailure');

        console.log('error sweeping regular then confirm: ' + error);
    objc_on_error_update_fee({'message': {'error':error.error.message}});

        return error.payment;
    }

    currentPayment.from(address).to(MyWalletPhone.getReceivingAddressForAccount(MyWallet.wallet.hdwallet.defaultAccountIndex)).useAll().build().then(function(x) {
      MyWalletPhone.updateSweep(false, true);
      return x;
    }).catch(buildFailure);
}

MyWalletPhone.changeLastUsedReceiveIndexOfDefaultAccount = function() {
    MyWallet.wallet.hdwallet.defaultAccount.lastUsedReceiveIndex = MyWallet.wallet.hdwallet.defaultAccount.receiveIndex;
}

MyWalletPhone.getBtcSwipeAddresses = function(numberOfAddresses, label) {

    var addresses = [];

    MyWalletPhone.changeLastUsedReceiveIndexOfDefaultAccount();

    for (var i = 0; i < numberOfAddresses; i++) {
        addresses.push(MyWallet.wallet.hdwallet.defaultAccount.receiveAddress);
        MyWalletPhone.changeLastUsedReceiveIndexOfDefaultAccount();
    }

    objc_did_get_btc_swipe_addresses(addresses);
}

MyWalletPhone.getReceiveAddressOfDefaultAccount = function() {
    return MyWallet.wallet.hdwallet.defaultAccount.receiveAddress;
}

MyWalletPhone.createTxProgressId = function() {
    return ''+Math.round(Math.random()*100000);
}

MyWalletPhone.quickSendBtc = function(id, onSendScreen, secondPassword) {
    MyWalletPhone.quickSend(id, onSendScreen, secondPassword, 'btc');
}

MyWalletPhone.quickSend = function(id, onSendScreen, secondPassword, assetType) {

    console.log('quickSend');

    var success = function(tx) {
        objc_tx_on_success_secondPassword_hash(id, secondPassword, tx.txid);
    };

    var error = function(response) {
        console.log(response);

        var error = response;
        if (response.initial_error) {
            error = response.initial_error;
        }
        objc_tx_on_error_error_secondPassword(id, ''+error, secondPassword);
    };

    var payment;
    if (assetType == 'btc') {
        payment = onSendScreen ? currentPayment : transferAllBackupPayment;
        
        payment.on('on_start', function () {
                   objc_tx_on_start(id);
                   });
        
        payment.on('on_begin_signing', function() {
                   objc_tx_on_begin_signing(id);
                   });
        
        payment.on('on_sign_progress', function(i) {
                   objc_tx_on_sign_progress_input(id, i);
                   });
        
        payment.on('on_finish_signing', function(i) {
                   objc_tx_on_finish_signing(id);
                   });

    } else if (assetType == 'bch') {
        payment = currentBitcoinCashPayment;
    }

    if (!payment) {
        console.log('Payment error: null payment object!');
        return;
    }

    if (MyWallet.wallet.isDoubleEncrypted) {
        if (secondPassword) {
            payment
            .sign(secondPassword)
            .publish()
            .then(success).catch(error);
        } else {
            MyWalletPhone.getSecondPassword(function (pw) {
              secondPassword = pw;
              payment
              .sign(pw)
              .publish()
              .then(success).catch(error);
            });
        }
    } else {
        payment
        .sign()
        .publish()
        .then(success).catch(error);
    }

    return id;
};

MyWalletPhone.newAccount = function(password, email, firstAccountName) {
    var success = function(guid, sharedKey, password) {
        objc_loading_stop();

        objc_on_create_new_account_sharedKey_password(guid, sharedKey, password);
    };

    var error = function(e) {
        objc_loading_stop();
        var message = e;
        if (e.initial_error) {
            message = e.initial_error;
        }
        objc_on_error_creating_new_account(''+message);
    };

    MyWallet.createNewWallet(email, password, firstAccountName, null, null, success, error);
};

MyWalletPhone.parsePairingCode = function (raw_code) {
    var success = function (pairing_code) {
        objc_didParsePairingCode(pairing_code);
    };

    var error = function (e) {
        objc_errorParsingPairingCode(e);
    };

    MyWallet.parsePairingCode(raw_code).then(success, error);
};

MyWalletPhone.makePairingCode = function () {
    var success = function (code) {
        objc_didMakePairingCode(code);
    };

    var error = function (e) {
        objc_errorMakingPairingCode(e);
    };

    MyWallet.makePairingCode(success, error);
}

MyWalletPhone.addAddressBookEntry = function(bitcoinAddress, label) {
    MyWallet.addAddressBookEntry(bitcoinAddress, label);

    MyWallet.backupWallet();
};

MyWalletPhone.detectPrivateKeyFormat = function(privateKeyString) {
    try {
        var format = Helpers.detectPrivateKeyFormat(privateKeyString);
        return format == null ? '' : format;
    } catch(e) {
        return null;
    }
};

MyWalletPhone.hasEncryptedWalletData = function() {
    var data = MyWallet.getEncryptedWalletData();

    return data && data.length > 0;
};

MyWalletPhone.get_history = function(hideBusyView) {
    var success = function () {
        console.log('Got wallet history');
        objc_on_get_history_success();
    };

    var error = function () {
        console.log('Error getting wallet history');
        objc_loading_stop();
    };

    if (!hideBusyView) objc_loading_start_get_history();

    var getHistory = MyWallet.wallet.getHistory();
    getHistory.then(success).catch(error);
};

MyWalletPhone.get_wallet_and_history = function() {
    var success = function () {
        console.log('Got wallet and history');
        objc_loading_stop();
    };

    var error = function (e) {
        console.log(e);
        console.log('Error getting wallet and history');
        objc_loading_stop();
    };

    objc_loading_start_get_wallet_and_history();

    MyWallet.getWallet(function() {
      var getHistory = MyWallet.wallet.getHistory();
      getHistory.then(success).catch(error);
    });
};

MyWalletPhone.getMultiAddrResponse = function(txFilter) {
    var obj = {};

    obj.transactions = MyWallet.wallet.txList.transactionsForIOS(txFilter);
    obj.total_received = MyWallet.wallet.totalReceived;
    obj.total_sent = MyWallet.wallet.totalSent;
    obj.final_balance = MyWallet.wallet.finalBalance;
    obj.n_transactions = MyWallet.wallet.numberTx;
    obj.addresses = MyWallet.wallet.addresses;

    return obj;
};

MyWalletPhone.fetchMoreTransactions = function() {
    objc_loading_start_get_history();
    MyWallet.wallet.fetchTransactions().then(function(numFetched) {
      var loadedAll = numFetched < MyWallet.wallet.txList.loadNumber;
      objc_update_loaded_all_transactions(loadedAll);
    });
}

MyWalletPhone.addKey = function(keyString) {
    var success = function(address) {
        console.log('Add private key success');

        objc_on_add_key(address.address);
    };
    var error = function(e) {
        console.log('Add private key Error');
        console.log(e);

        objc_on_error_adding_private_key(e);
    };

    var needsBip38Passsword = Helpers.detectPrivateKeyFormat(keyString) === 'bip38';

    if (needsBip38Passsword) {
        MyWalletPhone.getPrivateKeyPassword(function (bip38Pass) {
          if (MyWallet.wallet.isDoubleEncrypted) {
            objc_on_add_private_key_start();
            MyWalletPhone.getSecondPassword(function (pw) {
              var promise = MyWallet.wallet.importLegacyAddress(keyString, null, pw, bip38Pass);
              promise.then(success, error);
            });
          } else {
            objc_on_add_private_key_start();
            var promise = MyWallet.wallet.importLegacyAddress(keyString, null, null, bip38Pass);
            promise.then(success, error);
          }
        });
    }
    else {
        if (MyWallet.wallet.isDoubleEncrypted) {
            objc_on_add_private_key_start();
            MyWalletPhone.getSecondPassword(function (pw) {
              var promise = MyWallet.wallet.importLegacyAddress(keyString, null, pw, null);
              promise.then(success, error);
            });
        } else {
            objc_on_add_private_key_start();
            var promise = MyWallet.wallet.importLegacyAddress(keyString, null, null, null);
            promise.then(success, error);
        }
    }
};

MyWalletPhone.sendFromWatchOnlyAddressWithPrivateKey = function(privateKeyString, watchOnlyAddress) {

    if (!MyWallet.wallet.key(watchOnlyAddress).isWatchOnly) {
        console.log('Address is not watch only!');
        return;
    }

    var success = function(payment) {
        console.log('Add private key success:');
        objc_on_success_import_key_for_sending_from_watch_only();
    };

    var error = function(message) {
        console.log('Add private key error: ' + message);
        objc_on_error_import_key_for_sending_from_watch_only(message);
    };

    var needsBip38Passsword = Helpers.detectPrivateKeyFormat(privateKeyString) === 'bip38';

    if (needsBip38Passsword) {
        MyWalletPhone.getPrivateKeyPassword(function (bip38Pass) {
          Helpers.privateKeyCorrespondsToAddress(watchOnlyAddress, privateKeyString, bip38Pass).then(function (decryptedPrivateKey) {
            if (decryptedPrivateKey) {
              if (currentPayment) {
                currentPayment.from(decryptedPrivateKey).sideEffect(success).catch(error);
              } else {
                console.log('Payment error: null payment object!');
              }
            } else {
              console.log('Add private key error: ');
              objc_on_error_import_key_for_sending_from_watch_only('wrongPrivateKey');
            }
          }).catch(error);
        });
    } else {
        Helpers.privateKeyCorrespondsToAddress(watchOnlyAddress, privateKeyString, null).then(function (decryptedPrivateKey) {
          if (decryptedPrivateKey) {
            if (currentPayment) {
              currentPayment.from(decryptedPrivateKey).sideEffect(success).catch(error);
            } else {
              console.log('Payment error: null payment object!');
            }
          } else {
            console.log('Add private key error: ');
            objc_on_error_import_key_for_sending_from_watch_only('wrongPrivateKey');
          }
        }).catch(error);
    }
}

MyWalletPhone.addKeyToLegacyAddress = function(privateKeyString, legacyAddress) {

    var success = function(address) {
        console.log('Add private key success:');
        console.log(address.address);

        if (address.address != legacyAddress) {
            objc_on_add_incorrect_private_key(legacyAddress);
        } else {
            objc_on_add_private_key_to_legacy_address(legacyAddress);
        }
    };
    var error = function(message) {
        console.log('Add private key Error: ' + message);

        objc_on_error_adding_private_key_watch_only(message);
    };

    var needsBip38Passsword = Helpers.detectPrivateKeyFormat(privateKeyString) === 'bip38';

    if (needsBip38Passsword) {
        MyWalletPhone.getPrivateKeyPassword(function (bip38Pass) {
          if (MyWallet.wallet.isDoubleEncrypted) {
            objc_on_add_private_key_start();
            MyWalletPhone.getSecondPassword(function (pw) {
              MyWallet.wallet.addKeyToLegacyAddress(privateKeyString, legacyAddress, pw, bip38Pass).then(success).catch(error);
            });
          } else {
            objc_on_add_private_key_start();
            MyWallet.wallet.addKeyToLegacyAddress(privateKeyString, legacyAddress, null, bip38Pass).then(success).catch(error);
          }
        });
    }
    else {
        if (MyWallet.wallet.isDoubleEncrypted) {
            objc_on_add_private_key_start();
            MyWalletPhone.getSecondPassword(function (pw) {
              MyWallet.wallet.addKeyToLegacyAddress(privateKeyString, legacyAddress, pw, null).then(success).catch(error);
            });
        } else {
            objc_on_add_private_key_start();
            MyWallet.wallet.addKeyToLegacyAddress(privateKeyString, legacyAddress, null, null).then(success).catch(error);
        }
    }
};

MyWalletPhone.getRecoveryPhrase = function(secondPassword) {
    var recoveryPhrase = MyWallet.wallet.getMnemonic(secondPassword);
    objc_on_success_get_recovery_phrase(recoveryPhrase);
};


// Get passwords

MyWalletPhone.getPrivateKeyPassword = function(callback) {
    objc_get_private_key_password(function(pw) {
        callback(pw);
    });
};

MyWalletPhone.getSecondPassword = function(callback, helperText) {
    objc_get_second_password(function(pw) {
        callback(pw);
    }, helperText);
};


// Overrides

MyWallet.socketConnect = function() {
    // override socketConnect to prevent memory leaks
}

WalletCrypto.scrypt = function(passwd, salt, N, r, p, dkLen, callback) {
    if(typeof(passwd) !== 'string') {
        passwd = passwd.toJSON().data;
    }

    if(typeof(salt) !== 'string') {
        salt = salt.toJSON().data;
    }

    objc_crypto_scrypt_salt_n_r_p_dkLen(passwd, salt, N, r, p, dkLen, function(buffer) {
      var bytes = new Buffer(buffer, 'hex');
      callback(bytes);
    }, function(e) {
      error(''+e);
    });
};

WalletCrypto.stretchPassword = function (password, salt, iterations, keylen) {
    var retVal = objc_sjcl_misc_pbkdf2(password, salt.toJSON().data, iterations, (keylen || 256) / 8);
    return new Buffer(retVal, 'hex');
}

BIP39.mnemonicToSeed = function(mnemonic, enteredPassword) {
    var mnemonicBuffer = new Buffer(mnemonic, 'utf8')
    var saltBuffer = new Buffer(BIP39.salt(enteredPassword), 'utf8');
    var retVal = objc_pbkdf2_sync(mnemonicBuffer, saltBuffer, 2048, 64, 'sha512');
    return new Buffer(retVal, 'hex');
}

Metadata.verify = function (address, signature, message) {
    return objc_message_verify(address, signature.toString('hex'), message);
}

Metadata.sign = function (keyPair, message) {
    return new Buffer(objc_message_sign(keyPair, message), 'hex');
}

SharedMetadata.verify = function (address, signature, message) {
    return objc_message_verify_base64(address, signature, message);
}

SharedMetadata.sign = function (keyPair, message) {
    return new Buffer(objc_message_sign(keyPair, message), 'hex');
}

SharedMetadata.prototype.encryptFor = function (message, contact) {
    var sharedKey = new Buffer(objc_get_shared_key(contact.pubKey, this._keyPair), 'hex');
    return WalletCrypto.encryptDataWithKey(message, sharedKey);
};

SharedMetadata.prototype.decryptFrom = function (message, contact) {
    var sharedKey = new Buffer(objc_get_shared_key(contact.pubKey, this._keyPair), 'hex');
    return WalletCrypto.decryptDataWithKey(message, sharedKey);
};

// TODO what should this value be?
MyWallet.getNTransactionsPerPage = function() {
    return 50;
};

// Settings

MyWalletPhone.getAccountInfo = function () {

    var success = function (data) {
        console.log('Getting account info');
        var accountInfo = JSON.stringify(data, null, 2);
        objc_on_get_account_info_success(accountInfo);
        return data;
    }

    var error = function (e) {
        console.log('Error getting account info: ' + e);
    };

    return MyWallet.wallet.fetchAccountInfo().then(success).catch(error);
}

MyWalletPhone.getAccountInfoAndExchangeRates = function() {
    
    var success = function() {
        objc_on_get_account_info_and_exchange_rates()
    };
    
    MyWalletPhone.getAccountInfo().then(function(data) {
        var getBtcExchangeRates = MyWalletPhone.getBtcExchangeRates()
        var getBchExchangeRates = MyWalletPhone.bch.fetchExchangeRates()
        var currency =  data.currency
        var getEthExchangeRate = MyWalletPhone.getEthExchangeRate(currency)
        Promise.all([getBtcExchangeRates, getBchExchangeRates, getEthExchangeRate]).then(success);
    });
}

MyWalletPhone.getEmail = function () {
    return MyWallet.wallet.accountInfo.email;
}

MyWalletPhone.getSMSNumber = function () {
    return MyWallet.wallet.accountInfo.mobile == null ? '' : MyWallet.wallet.accountInfo.mobile;
}

MyWalletPhone.getEmailVerifiedStatus = function () {
    return MyWallet.wallet.accountInfo.isEmailVerified == null ? false : MyWallet.wallet.accountInfo.isEmailVerified;
}

MyWalletPhone.getSMSVerifiedStatus = function () {
    return MyWallet.wallet.accountInfo.isMobileVerified == null ? false : MyWallet.wallet.accountInfo.isMobileVerified;
}

MyWalletPhone.changeEmail = function(email) {

    var success = function () {
        console.log('Changing email');
        objc_on_change_email_success();
    };

    var error = function (e) {
        console.log('Error changing email: ' + e);
    };

    BlockchainSettingsAPI.changeEmail(email, success, error);
}

MyWalletPhone.resendEmailConfirmation = function(email) {

    var success = function () {
        console.log('Resending verification email');
        objc_on_resend_verification_email_success();
    };

    var error = function (e) {
        console.log('Error resending verification email: ' + e);
    };

    BlockchainSettingsAPI.resendEmailConfirmation(email, success, error);
}

MyWalletPhone.changeMobileNumber = function(mobileNumber) {

    var success = function () {
        console.log('Changing mobile number');
        objc_on_change_mobile_number_success();
    };

    var error = function (e) {
        console.log('Error changing mobile number: ' + e);
        objc_on_change_mobile_number_error();
    };

    BlockchainSettingsAPI.changeMobileNumber(mobileNumber, success, error);
}

MyWalletPhone.verifyMobile = function(code) {

    var success = function () {
        console.log('Verifying mobile number');
        objc_on_verify_mobile_number_success();
    };

    var error = function (e) {
        console.log('Error verifying mobile number: ' + e);
        // Error message is already shown through a sendEvent
        objc_on_verify_mobile_number_error();
    };

    BlockchainSettingsAPI.verifyMobile(code, success, error);
}

MyWalletPhone.setTwoFactorSMS = function() {

    var success = function () {
        console.log('Enabling two step SMS');
        objc_on_change_two_step_success();
    };

    var error = function (e) {
        console.log('Error enabling two step SMS: ' + e);
        objc_on_change_two_step_error();
    };

    BlockchainSettingsAPI.setTwoFactorSMS(success, error);
}

MyWalletPhone.unsetTwoFactor = function() {

    var success = function () {
        console.log('Disabling two step');
        objc_on_change_two_step_success();
    };

    var error = function (e) {
        console.log('Error disabling two step: ' + e);
        objc_on_change_two_step_error();
    };

    BlockchainSettingsAPI.unsetTwoFactor(success, error);
}

MyWalletPhone.changePassword = function(password) {

    var success = function () {
        console.log('Changing password');
        objc_on_change_password_success();
    };

    var error = function (e) {
        console.log('Error Changing password: ' + e);
        objc_on_change_password_error();
    };

    WalletStore.changePassword(password, success, error);
}

MyWalletPhone.isCorrectMainPassword = function(password) {
    return WalletStore.isCorrectMainPassword(password);
}

MyWalletPhone.changeLocalCurrency = function(code) {

    var success = function () {
        console.log('Changing local currency');
        objc_on_change_local_currency_success();
    };

    var error = function (e) {
        console.log('Error changing local currency: ' + e);
    };

    BlockchainSettingsAPI.changeLocalCurrency(code, success, error);
}

MyWalletPhone.changeBtcCurrency = function(code) {

    var success = function () {
        console.log('Changing btc currency');
        objc_on_change_local_currency_success();
    };

    var error = function (e) {
        console.log('Error changing btc currency: ' + e);
    };

    BlockchainSettingsAPI.changeBtcCurrency(code, success, error);
}

MyWalletPhone.getBtcExchangeRates = function () {

    var success = function (data) {
        console.log('Getting btc exchange rates');
        var currencySymbolData = JSON.stringify(data, null, 2);
        objc_on_get_btc_exchange_rates_success(currencySymbolData);
        return data;
    };

    var error = function (e) {
        console.log('Error getting all currency symbols: ' + e);
    };

    var promise = BlockchainAPI.getTicker();
    return promise.then(success, error);
}

MyWalletPhone.getPasswordStrength = function(password) {
    var strength = Helpers.scorePassword(password);
    return strength;
}

MyWalletPhone.generateNewAddress = function() {
    MyWallet.getWallet(function() {
      objc_loading_start_create_new_address();
      var label = null;

      var success = function () {
        console.log('Success creating new address');
        MyWalletPhone.get_history();
        objc_on_generate_key();
        objc_loading_stop();
      };

      var error = function (e) {
        console.log('Error creating new address: ' + e);
        objc_loading_stop();
        objc_on_error_creating_new_address(e);
      };

      if (MyWallet.wallet.isDoubleEncrypted) {
        MyWalletPhone.getSecondPassword(function (pw) {
          MyWallet.wallet.newLegacyAddress(label, pw, success, error);
        });
      } else {
        MyWallet.wallet.newLegacyAddress(label, '', success, error);
      }
    });
};

MyWalletPhone.checkIfWalletHasAddress = function(address) {
    return (MyWallet.wallet.addresses.indexOf(address) > -1);
}

MyWalletPhone.recoverWithPassphrase = function(email, password, passphrase) {

    if (Helpers.isValidBIP39Mnemonic(passphrase)) {
        console.log('recovering wallet');

        var accountProgress = function(obj) {
            var totalReceived = obj['total_received'];
            var finalBalance = obj['final_balance'];
            objc_on_progress_recover_with_passphrase_finalBalance(totalReceived, finalBalance);
        }

        var generateUUIDProgress = function() {
            objc_loading_start_generate_uuids();
        }

        var decryptWalletProgress = function() {
            objc_loading_start_decrypt_wallet();
        }

        var startedRestoreHDWallet = function() {
            objc_loading_start_recover_wallet();
        }

        var success = function (recoveredWalletDictionary) {
            console.log('recovery success');
            objc_on_success_recover_with_passphrase(recoveredWalletDictionary);
        }

        var error = function(error) {
            console.log('recovery error after validation: ' + error);
            objc_on_error_recover_with_passphrase(error);
        }

        MyWallet.recoverFromMnemonic(email, password, passphrase, '', success, error, startedRestoreHDWallet, accountProgress, generateUUIDProgress, decryptWalletProgress);

    } else {
        console.log('Invalid passphrase');
        objc_on_error_recover_with_passphrase('invalid passphrase');
    };
}

MyWalletPhone.setLabelForAddress = function(address, label) {
    if (label == '') {
        label = null;
    }
    MyWallet.wallet.key(address).label = label;
}

MyWalletPhone.resendTwoFactorSms = function(user_guid, sessionToken) {

    var success = function () {
        console.log('Resend two factor SMS success');
        objc_on_resend_two_factor_sms_success();
    }

    var error = function(error) {
        var parsedError = JSON.parse(error);
        console.log('Resend two factor SMS error: ');
        console.log(parsedError);
        objc_on_resend_two_factor_sms_error(parsedError['initial_error']);
    }

    WalletNetwork.resendTwoFactorSms(user_guid, sessionToken).then(success).catch(error);
}

MyWalletPhone.get2FAType = function() {
    return WalletStore.get2FAType();
}

MyWalletPhone.emailNotificationsEnabled = function() {
    return MyWallet.wallet.accountInfo.notifications.email;
}

MyWalletPhone.enableEmailNotifications = function() {
    MyWalletPhone.updateNotification({email: 'enable'});
}

MyWalletPhone.disableEmailNotifications = function() {
    MyWalletPhone.updateNotification({email: 'disable'});
}

MyWalletPhone.updateNotification = function(updates) {
    var success = function () {

        var updateReceiveError = function(error) {
            console.log('Enable notifications error: ' + error);
        }

        if (!MyWallet.wallet.accountInfo.notifications.http) {
            console.log('Enable notifications success; enabling for receiving');
            BlockchainSettingsAPI.updateNotificationsOn({ receive: true }).then(function(x) {
              objc_on_change_notifications_success();
              return x;
            }).catch(updateReceiveError);
        } else {
            console.log('Enable notifications success');
            objc_on_change_notifications_success();
        }
    }

    var error = function(error) {
        console.log('Enable notifications error: ' + error);
    }

    var notificationsType = MyWallet.wallet.accountInfo.notifications;

    if (updates.sms == 'enable') notificationsType.sms = true;
    if (updates.sms == 'disable') notificationsType.sms = false;

    if (updates.http == 'enable') notificationsType.http = true;
    if (updates.http == 'disable') notificationsType.http = false;

    if (updates.email == 'enable') notificationsType.email = true;
    if (updates.email == 'disable') notificationsType.email = false;

    BlockchainSettingsAPI.updateNotificationsType(notificationsType).then(success).catch(error);
}

MyWalletPhone.updateServerURL = function(url) {
    console.log('Changing wallet server URL to ' + url);
    if (url.substring(url.length - 1) == '/') {
        BlockchainAPI.ROOT_URL = url;
        MyWallet.ws.headers = { 'Origin': url.substring(0, url.length - 1) };
    } else {
        BlockchainAPI.ROOT_URL = url.concat('/');
        MyWallet.ws.headers = { 'Origin': url };
    }
}

MyWalletPhone.updateWebsocketURL = function(url) {
    console.log('Changing websocket server URL to ' + url);
    if (url.substring(url.length - 1) == '/') {
        MyWallet.ws.wsUrl = url.substring(0, url.length - 1);
    } else {
        MyWallet.ws.wsUrl = url;
    }
}

MyWalletPhone.updateAPIURL = function(url) {
    console.log('Changing API URL to ' + url);
    if (url.substring(url.length - 1) != '/') {
        BlockchainAPI.API_ROOT_URL = url.concat('/')
    } else {
        BlockchainAPI.API_ROOT_URL = url;
    }
}

MyWalletPhone.getXpubForAccount = function(accountIndex) {
    return MyWallet.wallet.hdwallet.accounts[accountIndex].extendedPublicKey;
}

MyWalletPhone.filteredWalletJSON = function() {
    var walletJSON = JSON.parse(JSON.stringify(MyWallet.wallet, null, 2));
    var hidden = '(REMOVED)';

    walletJSON['guid'] = hidden;
    walletJSON['sharedKey'] = hidden;
    walletJSON['dpasswordhash'] = hidden;

    for (var key in walletJSON) {
        if (key == 'hd_wallets') {

            walletJSON[key][0]['seed_hex'] = hidden;

            for (var account in walletJSON[key][0]['accounts']) {
                walletJSON[key][0]['accounts'][account]['xpriv'] = hidden;
                walletJSON[key][0]['accounts'][account]['xpub'] = hidden;
                walletJSON[key][0]['accounts'][account]['label'] = hidden;
                walletJSON[key][0]['accounts'][account]['address_labels'] = hidden;

                if (walletJSON[key][0]['accounts'][account]['cache']) {
                    walletJSON[key][0]['accounts'][account]['cache']['changeAccount'] = hidden;
                    walletJSON[key][0]['accounts'][account]['cache']['receiveAccount'] = hidden;
                }
            }
        }

        if (key == 'keys') {
            for (var address in walletJSON[key]) {
                walletJSON[key][address]['priv'] = hidden;
                walletJSON[key][address]['label'] = hidden;
                walletJSON[key][address]['addr'] = hidden;
            }
        }
    }
    return walletJSON;
}

MyWalletPhone.didSetLatestBlock = function() {
    var latestBlock = JSON.stringify(MyWallet.wallet.latestBlock);
    return latestBlock == null ? '' : latestBlock;
}

MyWalletPhone.dust = function() {
    return Bitcoin.networks.bitcoin.dustThreshold;
}

MyWalletPhone.labelForLegacyAddress = function(key) {
    var label = MyWallet.wallet.key(key).label;
    return label == null ? '' : label;
}

MyWalletPhone.getNotePlaceholder = function(transactionHash) {

    var transaction = MyWallet.wallet.txList.transaction(transactionHash);

    var getLabel = function(tx) {
        if (tx.txType === 'received') {
            if (tx.to.length) {
                return MyWallet.wallet.labels.getLabel(tx.to[0].accountIndex, tx.to[0].receiveIndex);
            }
        }
    }

    var label = getLabel(transaction);
    if (label == undefined) return '';
    return label;
}

MyWalletPhone.getDefaultAccountLabelledAddressesCount = function() {
    if (!MyWallet.wallet.isUpgradedToHD) {
        console.log('Warning: Getting accounts when wallet has not upgraded!');
        return 0;
    }

    return MyWallet.wallet.hdwallet.defaultAccount.getLabels().length;
}

MyWalletPhone.getNetworks = function() {
    return Networks;
}

MyWalletPhone.getECDSA = function() {
    return ECDSA;
}

// Contacts

MyWalletPhone.loadContacts = function() {
    console.log('Loading contacts');
    MyWallet.wallet.loadContacts();
}

MyWalletPhone.loadContactsThenGetMessages = function() {
    console.log('Loading contacts then getting messages');
    MyWallet.wallet.loadContacts().then(function(discard) {
        MyWalletPhone.getMessages(true);
    });
}

MyWalletPhone.getContacts = function() {
    console.log('Getting contacts');
    console.log(JSON.stringify(MyWallet.wallet.contacts.list));
    var list = MyWallet.wallet.contacts.list;

    var listToReturn = Blockchain.R.map(function(contact) {
      return {
        company: contact.company,
        email: contact.email,
        id: contact.id,
        invitationReceived: contact.invitationReceived,
        invitationSent: contact.invitationSent,
        mdid: contact.mdid,
        name: contact.name,
        senderName: contact.senderName,
        note: contact.note,
        pubKey: contact.pubKey,
        surname: contact.surname,
        trusted: contact.trusted,
        xpub: contact.xpub,
        facilitatedTxList: contact.facilitatedTxList
      }
    }, list);

    return listToReturn;
}

MyWalletPhone.getSaveContactsFunction = function() {
    var save = function(info) {
        return MyWallet.wallet.contacts.save().then(function(discard) {
            return info;
        });
    }

    return save;
}

MyWalletPhone.createContact = function(name, id) {

    var success = function(invitation) {
        objc_on_create_invitation_success(invitation);
    };

    var error = function(e) {
        objc_on_create_invitation_error(e);
        onsole.log('Error creating contact');
        console.log(e);
    };

    var save = MyWalletPhone.getSaveContactsFunction();

    MyWallet.wallet.contacts.createInvitation({name: name}, {name: id, senderName: name}).then(save).then(success).catch(error);
}

MyWalletPhone.sendDeclination = function(userId, txIdentifier) {

    var success = function() {
        objc_on_send_declination_success();
    };

    var error = function(e) {
        objc_on_send_declination_error();
        console.log('Error sending declination');
        console.log(e);
    };

    MyWallet.wallet.contacts.sendDeclination(userId, txIdentifier).then(success).catch(error);
}

MyWalletPhone.sendCancellation = function(userId, txIdentifier) {

    var success = function() {
        objc_on_send_cancellation_success();
    };

    var error = function(e) {
        objc_on_send_cancellation_error();
        console.log('Error sending cancellation');
        console.log(e);
    };

    MyWallet.wallet.contacts.sendCancellation(userId, txIdentifier).then(success).catch(error);
}

MyWalletPhone.readInvitation = function(invitation, invitationString) {
    objc_on_read_invitation_success(invitation, invitationString);
}

MyWalletPhone.completeRelation = function(invitation) {

    var success = function() {
        objc_on_complete_relation_success();
    };

    var error = function(e) {
        objc_on_complete_relation_error();
        console.log('Error completing relation');
        console.log(e);
    };

    MyWallet.wallet.contacts.completeRelation(invitation).then(success).catch(error);
}

MyWalletPhone.acceptRelation = function(invitation, name, identifier) {

    var success = function() {
        objc_on_accept_relation_success(name, identifier);
    };

    var error = function(e) {
        objc_on_accept_relation_error(name);
        console.log('Error accepting relation');
        console.log(e);
    };

    MyWallet.wallet.contacts.acceptRelation({name: name, invitationReceived:identifier}).then(success).catch(error);
}

MyWalletPhone.fetchExtendedPublicKey = function(contactIdentifier) {

    var success = function(xpub) {
        objc_on_fetch_xpub_success(xpub);
    };

    var save = MyWalletPhone.getSaveContactsFunction();

    MyWallet.wallet.contacts.fetchXPUB(contactIdentifier).then(save).then(success).catch(function(e){console.log('Error fetching xpub');console.log(e)});
}

MyWalletPhone.getMessages = function(isFirstLoad) {

    var success = function(messages) {
        console.log('digested new messages');
        objc_on_get_messages_success(messages, isFirstLoad);
    };

    var error = function(error) {
        console.log('Error getting messages');
        console.log(error);
        objc_on_get_messages_error(error);
    };

    if (MyWallet.wallet.contacts) {
        MyWallet.wallet.contacts.digestNewMessages().then(success).catch(error);
    } else {
        console.log('MyWalletPhone.getMessages error: contacts not loaded');
    }
}

MyWalletPhone.changeName = function(newName, identifier) {

    var save = MyWalletPhone.getSaveContactsFunction();
    var success = function(info) {
        objc_on_change_contact_name_success(info);
    };

    MyWallet.wallet.contacts.list[identifier].name = newName;

    save().then(success);
}

MyWalletPhone.deleteContact = function(identifier) {

    var save = MyWalletPhone.getSaveContactsFunction();
    var success = function(info) {
        objc_on_delete_contact_success(info);
    };

    MyWallet.wallet.contacts.delete(identifier);

    save().then(success);
}

MyWalletPhone.deleteContactAfterStoringInfo = function(identifier) {

    var save = MyWalletPhone.getSaveContactsFunction();
    var success = function(info) {
        console.log('Deleted contact because user did not complete create contact sequence');
        objc_on_delete_contact_after_storing_info_success(info);
    };

    var contactInfo;

    var filtered = Blockchain.R.filter(function(contact) {
        if (contact.invitationSent == identifier) {
             contactInfo = contact;
             return true;
           }
           return false;
        }, MyWallet.wallet.contacts.list);

    MyWallet.wallet.contacts.delete(contactInfo.id);

    save().then(success);
}

MyWalletPhone.sendPaymentRequest = function(userId, intendedAmount, requestIdentifier, note, initiatorSource) {

    var success = function(info) {
        objc_on_send_payment_request_success(info, intendedAmount, userId, requestIdentifier);
    };

    var error = function(error) {
        console.log('Error sending payment request')
        console.log(error);
        objc_on_send_payment_request_error(error);
    };

    MyWallet.wallet.contacts.sendPR(userId, intendedAmount, requestIdentifier, note, initiatorSource).then(success).catch(error);
}

MyWalletPhone.requestPaymentRequest = function(userId, intendedAmount, requestIdentifier, note) {

    var success = function(info) {
        objc_on_request_payment_request_success(info, userId);
    };

    var error = function(error) {
        console.log('Error requesting payment request')
        console.log(error);
        objc_on_request_payment_request_error(error);
    };

    MyWallet.wallet.contacts.sendRPR(userId, intendedAmount, requestIdentifier, note).then(success).catch(error);
}

MyWalletPhone.sendPaymentRequestResponse = function(userId, txHash, txIdentifier) {

    var success = function(info) {
        objc_on_send_payment_request_response_success(info);
    };

    var error = function(error) {
        console.log('Error sending payment request response')
        console.log(error);
        objc_on_send_payment_request_response_error(error);
    };

    MyWallet.wallet.contacts.sendPRR(userId, txHash, txIdentifier).then(success).catch(function(e){error});
}

MyWalletPhone.changeNetwork = function(newNetwork) {
    console.log('Changing network to ');
    console.log(newNetwork);
    Blockchain.constants.NETWORK = newNetwork;
}

MyWalletPhone.parseValueBitcoin = function(valueString) {
    valueString = valueString.toString();
    var valueComp = valueString.split('.');
    var integralPart = valueComp[0];
    var fractionalPart = valueComp[1] || '0';
    while (fractionalPart.length < 8) fractionalPart += '0';
    fractionalPart = fractionalPart.replace(/^0+/g, '');
    var value = BigInteger.valueOf(parseInt(integralPart, 10));
    value = value.multiply(BigInteger.valueOf(objc_get_satoshi()));
    value = value.add(BigInteger.valueOf(parseInt(fractionalPart, 10)));
    return value;
}

// The current 'shift' value - BTC = 1, mBTC = 3, uBTC = 6
function sShift (conversion) {
    return (objc_get_satoshi() / conversion).toString().length - 1;
}

MyWalletPhone.precisionToSatoshiBN = function (x, conversion) {
    return MyWalletPhone.parseValueBitcoin(x).divide(BigInteger.valueOf(Math.pow(10, sShift(conversion).toString())));
}

MyWalletPhone.getExchangeAccount = function () {
    var sfox = MyWallet.wallet.external.sfox;
    var coinify = MyWallet.wallet.external.coinify;
    var partners = walletOptions.getValue().partners;

    if (sfox.user) {
        console.log('Found sfox user');
        sfox.api.production = true;
        sfox.api.apiKey = partners.sfox.apiKey;
        return sfox;
    } else if (coinify.user) {
        console.log('Found coinify user');
        coinify.partnerId = partners.coinify.partnerId;
        return coinify;
    } else {
        console.log('Found no sfox or coinify user');
    }
}

var tradeToObject = function (trade) {
  return {
    createdAt: new Date(trade.createdAt).toLocaleString(),
    receiveAddress: trade.receiveAddress,
    txHash: trade.txHash
  }
}

var watchTrade = function (trade) {
  console.log('watching ' + trade.receiveAddress);
  trade.watchAddress().then(function () {
    console.log('trade complete ' + trade.receiveAddress);
    objc_show_completed_trade(tradeToObject(trade));
  });
}

MyWalletPhone.getPendingTrades = function(shouldSync) {

      var watchTrades = function() {
        var exchange = MyWalletPhone.getExchangeAccount();
        if (exchange) {
          console.log('Getting pending trades');
          exchange.getTrades().then(function () {
            console.log(exchange.trades);
            exchange.monitorPayments();
            exchange.trades
              .filter(function (trade) { return !trade.txHash; })
              .forEach(watchTrade);
          });
        }
      }

      var loadMetadataIfNeeded = function(errorCallBack) {
        if (MyWallet.wallet.isMetadataReady) {
          watchTrades();
        } else {
          var wallet = MyWallet.wallet;
          var p = wallet.loadMetadata();
          return p.then(function () {
            objc_loading_stop();
            watchTrades();
          }).catch(function(e){console.log('Error getting exchange account:'); console.log(e)});
        }
      }

      var error = function(e) {
        console.log(e);
        objc_on_get_pending_trades_error(e);
      };

      if (shouldSync) {
          console.log('Getting wallet then watching trades');
          MyWallet.getWallet(function() {
              loadMetadataIfNeeded(error);
          }, error);
      } else {
          console.log('Watching trades');
          loadMetadataIfNeeded(error);
      }
}

MyWalletPhone.getWebViewLoginData = function () {
  var wallet = MyWallet.wallet
  var magicHash = wallet.external._metadata._magicHash
  return {
    walletJson: JSON.stringify(wallet.toJSON()),
    externalJson: wallet.external.toJSON() ? JSON.stringify(wallet.external.toJSON()) : null,
    magicHash: magicHash ? magicHash.toString('hex') : null
  }
}

MyWalletPhone.canUseSfox = function() {
    var wallet = MyWallet.wallet
    var options = walletOptions.getValue()
    var accountInfo = wallet.accountInfo;
    var isSfoxCountryState = accountInfo && options.partners.sfox.countries.indexOf(accountInfo.countryCodeGuess) > -1 && (options.partners.sfox.states.indexOf(accountInfo.stateCodeGuess) > -1 || accountInfo.stateCodeGuess === undefined);
    var isSfoxInvited = accountInfo && accountInfo.invited && accountInfo.invited.sfox;

    var external = MyWallet.wallet && MyWallet.wallet.external;
    var userHasSfoxAccount = external && external.sfox && external.sfox.hasAccount;

    return (userHasSfoxAccount || isSfoxInvited && isSfoxCountryState) && options.ios.showSfox;
}

MyWalletPhone.isBuyFeatureEnabled = function () {
  var wallet = MyWallet.wallet
  var options = walletOptions.getValue()
  var guidHash = WalletCrypto.sha256(new Buffer(wallet.guid.replace(/-/g, ''), 'hex'));
  var userHasAccess = ((guidHash[0] + 1) / 256) <= (options.iosBuyPercent || 0);
  var whiteListedGuids = objc_get_whitelisted_guids();

  if (whiteListedGuids.indexOf(wallet.guid) > -1) {
      userHasAccess = true;
  }

  var canBuy = function(accountInfo, options) {
     var external = MyWallet.wallet && MyWallet.wallet.external;
     var userHasCoinifyAccount = external && external.coinify && external.coinify.hasAccount;
     var isCoinifyCountry = accountInfo && options.partners.coinify.countries.indexOf(accountInfo.countryCodeGuess) > -1;
     return (userHasCoinifyAccount || isCoinifyCountry) || MyWalletPhone.canUseSfox();
  }

  return userHasAccess && wallet.external && canBuy(wallet.accountInfo, options)
}

MyWalletPhone.getNetworks = function() {
    return Networks;
}

MyWalletPhone.getECDSA = function() {
    return ECDSA;
}

function WalletOptions (api) {
  var optionsCache = {};

  this.getValue = function () {
    return optionsCache[this.getFileName()];
  };

  this.fetch = function () {
    var name = this.getFileName();
    var readJson = function (res) { return res.json(); }
    var cacheOptions = function (opts) { optionsCache[name] = opts; return opts; };
    return fetch(api.ROOT_URL + 'Resources/' + name).then(readJson).then(cacheOptions);
  };

  this.getFileName = function () {
    var base = 'wallet-options';
    return base + '.json';
  };
}

// MARK: - Ethereum

MyWalletPhone.getEthExchangeRate = function(currencyCode) {

    var success = function(result) {
        console.log('Success fetching eth exchange rate');
        objc_on_fetch_eth_exchange_rate_success(result, currencyCode);
        return result;
    };

    var error = function(error) {
        console.log('Error fetching eth exchange rate')
        console.log(error);
        objc_on_fetch_eth_exchange_rate_error(error);
    };

    return BlockchainAPI.getExchangeRate(currencyCode, 'ETH').then(success).catch(error);
}

MyWalletPhone.getEthBalance = function() {
    var eth = MyWallet.wallet.eth;

    if (eth.defaultAccount) {
        return eth.defaultAccount.balance;
    } else {
        return 0;
    }
}

MyWalletPhone.getEthTransactions = function() {
    var eth = MyWallet.wallet.eth;
    if (eth.defaultAccount) {
        return MyWalletPhone.convertEthTransactionsToJSON(eth.defaultAccount.txs);
    } else {
        return {};
    }
}

MyWalletPhone.convertEthTransactionsToJSON = function(transactions) {
    return transactions.map(function (tx) {
       var result = tx.toJSON();
       result.txType = tx.getTxType(MyWallet.wallet.eth.activeAccountsWithLegacy);
       result.amount = result.txType === 'sent' ? parseFloat(result.fee) + parseFloat(result.amount) : parseFloat(result.amount);
       return result;
    });
}

MyWalletPhone.getEthHistory = function() {

    var success = function() {
        console.log('Success fetching eth history')
        objc_on_fetch_eth_history_success();
    };

    var error = function(error) {
        console.log('Error fetching eth history')
        console.log(error);
        objc_on_fetch_eth_history_error(error);
    };

    MyWallet.wallet.eth.fetchHistory().then(success).catch(error);
}

MyWalletPhone.createNewEtherPayment = function() {
    console.log('Creating new ether payment');

    var eth = MyWallet.wallet.eth;

    currentEtherPayment = eth.defaultAccount.createPayment();

    eth.fetchFees().then(function(fees) {
         currentEtherPayment.setGasPrice(fees.regular);
         currentEtherPayment.setGasLimit(fees.gasLimit);

         MyWalletPhone.updateEtherPayment();
     });
}

MyWalletPhone.hasEthAccount = function() {
    var eth = MyWallet.wallet.eth;
    return eth && eth.defaultAccount;
}

MyWalletPhone.KYC = {
    updateUserCredentials: function(userId, lifetimeToken) {
        MyWallet.wallet.retailCore.updateUserCredentials(
            {userId: userId, lifetimeToken: lifetimeToken},
            objc_updateUserCredentials_success,
            objc_updateUserCredentials_error
        )
    },

    userId: function() {
        return MyWallet.wallet.retailCore.userId;
    },

    lifetimeToken: function() {
        return MyWallet.wallet.retailCore.lifetimeToken;
    }
}

MyWalletPhone.createEthAccountForExchange = function(secondPassword, helperText) {

    var eth = MyWallet.wallet.eth;

    if (MyWallet.wallet.isDoubleEncrypted) {
        eth.createAccount(void 0, secondPassword).then(function() {
            objc_on_create_eth_account_for_exchange_success();
        });
    } else {
        eth.createAccount(void 0, secondPassword).then(function() {
            objc_on_create_eth_account_for_exchange_success();
        });
    }
}

MyWalletPhone.updateEtherPayment = function(isSweep) {

    var paymentInfo = {
        amount : currentEtherPayment.amount,
        available : currentEtherPayment.available,
        fee : currentEtherPayment.fee,
        sweep : isSweep
    };

    console.log(JSON.stringify(paymentInfo));

    objc_update_eth_payment(paymentInfo);
}

MyWalletPhone.setEtherPaymentTo = function(to) {
    currentEtherPayment.setTo(to);
}

MyWalletPhone.setEtherPaymentAmount = function(amount) {
    if (amount == null) amount = 0;
    currentEtherPayment.setValue(amount);
    MyWalletPhone.updateEtherPayment();
}

MyWalletPhone.isEthAddress = function(address) {
    return Helpers.isEtherAddress(address);
}

MyWalletPhone.getEthPaymentTotal = function() {
    return currentEtherPayment.amount + currentEtherPayment.fee;
}

MyWalletPhone.sendEtherPaymentWithNote = function(note) {

    var eth = MyWallet.wallet.eth;

    var success = function(tx) {
        MyWalletPhone.recordLastTransaction(tx.txHash);
        if (note != '') eth.setTxNote(tx.txHash, note);
        console.log('Send ether success');
        objc_on_send_ether_payment_success();
    }

    var error = function(e) {
        console.log('Send ether error');
        console.log(e);
        objc_on_send_ether_payment_error(e);
    }

    if (MyWallet.wallet.isDoubleEncrypted) {
      MyWalletPhone.getSecondPassword(function (pw) {
        var privateKey = eth.getPrivateKeyForAccount(eth.defaultAccount, pw);
        currentEtherPayment.sign(privateKey);
        currentEtherPayment
        .publish()
        .then(success).catch(error);
      });
    } else {
      var privateKey = eth.getPrivateKeyForAccount(eth.defaultAccount);
      currentEtherPayment.sign(privateKey);
      currentEtherPayment
      .publish()
      .then(success).catch(error);
    }
}

MyWalletPhone.saveEtherNote = function(txHash, note) {
    MyWallet.wallet.eth.setTxNote(txHash, note);
    MyWalletPhone.getEthHistory();
}

MyWalletPhone.didReceiveEthSocketMessage = function(msg) {
    ethSocketInstance.onMessage(msg);
}

MyWalletPhone.getEtherAddress = function(helperText) {

    var eth = MyWallet.wallet.eth;

    if (eth && eth.defaultAccount) {
        return eth.defaultAccount.address;
    } else {
        if (MyWallet.wallet.isDoubleEncrypted) {
            MyWalletPhone.getSecondPassword(function (pw) {
                eth.createAccount(void 0, pw).then(function() {
                    objc_did_get_ether_address_with_second_password();
                });
            }, helperText);
        } else {
            eth.createAccount(void 0).then(function() {
               objc_did_get_ether_address_with_second_password();
            });
        }
    }
}

MyWalletPhone.sweepEtherPayment = function() {
    currentEtherPayment.setSweep();
    MyWalletPhone.updateEtherPayment(true);
}

MyWalletPhone.recordLastTransaction = function(hash) {
    MyWallet.wallet.eth.setLastTx(hash);
}

MyWalletPhone.isWaitingOnTransaction = function() {

    var eth = MyWallet.wallet.eth;
    var options = walletOptions.getValue();
    var lastTxFuse = options.ethereum.lastTxFuse;

    return null != eth.lastTx && null == eth.txs.find(function(tx) {
       return tx.hash === eth.lastTx;
    }) &&
    eth.lastTxTimestamp + lastTxFuse * 1000 > new Date().getTime();
}

MyWalletPhone.getMobileMessage = function(languageCode) {
    var options = walletOptions.getValue();

    if (!options.mobile_notice || options.mobile_notice == null) return null;

    var notice = options.mobile_notice[languageCode];
    if (!notice || notice == null) return options.mobile_notice['en'];
    return notice;
}

MyWalletPhone.getExchangeTrades = function() {

    var success = function() {
      var trades = MyWallet.wallet.shapeshift.trades.map(function(trade){
        return {
            hashIn : trade.hashIn,
            hashOut : trade.hashOut,
            quote : trade.quote.toJSON(),
            status : trade.status,
            time : trade.time
        }
      }).sort(function(a,b) {
        return new Date(b.time) - new Date(a.time);
      });

      objc_on_get_exchange_trades_success(trades);
    }

    var error = function(e) {
        console.log('Error getting trades');
        console.log(e);
        on_get_exchange_trades_error(e)
    }

    return MyWallet.wallet.shapeshift.fetchFullTrades().then(success).catch(error);
}

MyWalletPhone.getRate = function(coinPair) {

    var success = function(result) {
        const from = coinPair.split('_')[0];

        const fetchRateSuccess = function(hardLimit) {
            var currencyCode = MyWalletPhone.currencyCodeForHardLimit();
            result.hardLimitRate = hardLimit[currencyCode].last;
            objc_on_get_exchange_rate_success(result);
        };

        MyWalletPhone.getExchangeRateForHardLimit(from).then(fetchRateSuccess);
    }

    var error = function(e) {
        console.log('Error getting rate');
        console.log(e);
    }

    MyWallet.wallet.shapeshift.getRate(coinPair).then(success).catch(error);
}

MyWalletPhone.getShapeshiftApiKey = function() {
    return walletOptions.getValue().shapeshift.apiKey;
}

MyWalletPhone.getAvailableBtcBalanceForAccount = function(accountIndex) {

    var success = function(result) {
        objc_on_get_available_btc_balance_success(result);
    }

    var error = function(e) {
        console.log('Error getting btc balance');
        console.log(e);
        objc_on_get_available_btc_balance_error(e);
    }

    MyWallet.wallet.hdwallet.accounts[accountIndex].getAvailableBalance('priority').then(success).catch(error);
}

MyWalletPhone.getAvailableEthBalance = function() {

    var success = function(result) {
        objc_on_get_available_eth_balance_success(result.amount, result.fee);
    }

    var error = function(e) {
        console.log('Error getting eth balance');
        console.log(e);
        objc_on_get_available_eth_balance_error(e);
    }
    MyWallet.wallet.eth.accounts[0].getAvailableBalance().then(success).catch(error);
}

MyWalletPhone.getLabelForEthAccount = function() {
    return MyWallet.wallet.eth.defaultAccount.label;
}

MyWalletPhone.buildExchangeTrade = function(from, to, coinPair, amount, fee) {

    var success = function(depositAmount, fee, rate, minerFee, withdrawalAmount, expiration) {
        objc_on_build_exchange_trade_success(coins[0], depositAmount, fee, rate, minerFee, withdrawalAmount, expiration);
    }

    var error = function(e) {
        console.log('Error building exchange trade');
        console.log(e);
    }

    var buildPayment = function(quote) {
        var expiration = quote.expires;
        currentShiftPayment = MyWallet.wallet.shapeshift.buildPayment(quote, Number(fee), fromArg);

        var depositAmount = currentShiftPayment.quote.depositAmount;
        var rate = currentShiftPayment.quote.rate;
        var minerFee = currentShiftPayment.quote.minerFee;
        var withdrawalAmount = currentShiftPayment.quote.withdrawalAmount;

        currentShiftPayment.getFee().then(function(finalFee) {
          console.log('payment got fee');
          console.log(finalFee);
          success(depositAmount, finalFee, rate, minerFee, withdrawalAmount, expiration);
        });
    };

    var coins = coinPair.split('_');
    
    var fromArg;
    var fromSymbol = coins[0];
    if (fromSymbol == 'btc') {
        fromArg = MyWallet.wallet.hdwallet.accounts[from];
    } else if (fromSymbol == 'eth') {
        fromArg = MyWallet.wallet.eth.defaultAccount;
    } else if (fromSymbol == 'bch') {
        fromArg = MyWallet.wallet.bch.accounts[from];
    } else {
        console.log('Error building trade: unsupported asset type');
    }
    
    var toArg;
    var toSymbol = coins[1];
    if (toSymbol == 'btc') {
        toArg = MyWallet.wallet.hdwallet.accounts[to];
    } else if (toSymbol == 'eth') {
        toArg = MyWallet.wallet.eth.defaultAccount;
    } else if (toSymbol == 'bch') {
        toArg = MyWallet.wallet.bch.accounts[to];
    } else {
        console.log('Error building trade: unsupported asset type');
    }

    MyWallet.wallet.shapeshift.getQuote(fromArg, toArg, amount).then(buildPayment).catch(error);
}

MyWalletPhone.shiftPayment = function() {

    var success = function(result) {
        console.log('shift complete');
        console.log(JSON.stringify(result));
        if (result.fromCurrency == 'eth') {
            MyWalletPhone.recordLastTransaction(result.depositHash);
        }
        objc_on_shift_payment_success();
    }

    var error = function(e) {
        console.log('Error shifting payment');
        console.log(JSON.stringify(e));
        objc_on_shift_payment_error(e);
    }

    if (MyWallet.wallet.isDoubleEncrypted) {
        MyWalletPhone.getSecondPassword(function (pw) {
            MyWallet.wallet.shapeshift.shift(currentShiftPayment, pw).then(success).catch(error);
        });
    }
    else {
        MyWallet.wallet.shapeshift.shift(currentShiftPayment).then(success).catch(error);
    }
}

MyWalletPhone.isExchangeEnabled = function() {
    var showShapeshift = walletOptions.getValue().ios.showShapeshift;
    return MyWalletPhone.isCountryGuessWhitelistedForShapeshift() && MyWalletPhone.isStateGuessWhitelistedForShapeshift() && showShapeshift;
}

MyWalletPhone.isStateGuessWhitelistedForShapeshift = function() {
    var state = MyWallet.wallet.accountInfo.stateCodeGuess;
    var statesWhitelist = walletOptions.getValue().shapeshift.statesWhitelist;
    return !state ? true : statesWhitelist.indexOf(state) > -1;
}

MyWalletPhone.isCountryGuessWhitelistedForShapeshift = function() {
    var country = MyWallet.wallet.accountInfo.countryCodeGuess;
    var countriesBlacklist = walletOptions.getValue().shapeshift.countriesBlacklist;
    var isBlacklisted = countriesBlacklist.indexOf(country) > -1;
    return !isBlacklisted;
}

MyWalletPhone.countryCodeGuess = function() {
    var accountInfo = MyWallet.wallet.accountInfo;
    var codeGuess = accountInfo && accountInfo.countryCodeGuess;
    return codeGuess;
}

MyWalletPhone.stateCodeGuess = function() {
    var accountInfo = MyWallet.wallet.accountInfo;
    return accountInfo && accountInfo.stateCodeGuess;
}

MyWalletPhone.availableUSStates = function() {
    var codeGuess = MyWalletPhone.countryCodeGuess();
    var storedState = MyWallet.wallet.shapeshift.USAState;

    if (codeGuess === 'US' && !storedState) {
        return [{'Name': 'Alabama', 'Code': 'AL'},
                {'Name': 'Alaska', 'Code': 'AK'},
                {'Name': 'American Samoa', 'Code': 'AS'},
                {'Name': 'Arizona', 'Code': 'AZ'},
                {'Name': 'Arkansas', 'Code': 'AR'},
                {'Name': 'California', 'Code': 'CA'},
                {'Name': 'Colorado', 'Code': 'CO'},
                {'Name': 'Connecticut', 'Code': 'CT'},
                {'Name': 'Delaware', 'Code': 'DE'},
                {'Name': 'District Of Columbia', 'Code': 'DC'},
                {'Name': 'Federated States Of Micronesia', 'Code': 'FM'},
                {'Name': 'Florida', 'Code': 'FL'},
                {'Name': 'Georgia', 'Code': 'GA'},
                {'Name': 'Guam', 'Code': 'GU'},
                {'Name': 'Hawaii', 'Code': 'HI'},
                {'Name': 'Idaho', 'Code': 'ID'},
                {'Name': 'Illinois', 'Code': 'IL'},
                {'Name': 'Indiana', 'Code': 'IN'},
                {'Name': 'Iowa', 'Code': 'IA'},
                {'Name': 'Kansas', 'Code': 'KS'},
                {'Name': 'Kentucky', 'Code': 'KY'},
                {'Name': 'Louisiana', 'Code': 'LA'},
                {'Name': 'Maine', 'Code': 'ME'},
                {'Name': 'Marshall Islands', 'Code': 'MH'},
                {'Name': 'Maryland', 'Code': 'MD'},
                {'Name': 'Massachusetts', 'Code': 'MA'},
                {'Name': 'Michigan', 'Code': 'MI'},
                {'Name': 'Minnesota', 'Code': 'MN'},
                {'Name': 'Mississippi', 'Code': 'MS'},
                {'Name': 'Missouri', 'Code': 'MO'},
                {'Name': 'Montana', 'Code': 'MT'},
                {'Name': 'Nebraska', 'Code': 'NE'},
                {'Name': 'Nevada', 'Code': 'NV'},
                {'Name': 'New Hampshire', 'Code': 'NH'},
                {'Name': 'New Jersey', 'Code': 'NJ'},
                {'Name': 'New Mexico', 'Code': 'NM'},
                {'Name': 'New York', 'Code': 'NY'},
                {'Name': 'North Carolina', 'Code': 'NC'},
                {'Name': 'North Dakota', 'Code': 'ND'},
                {'Name': 'Northern Mariana Islands', 'Code': 'MP'},
                {'Name': 'Ohio', 'Code': 'OH'},
                {'Name': 'Oklahoma', 'Code': 'OK'},
                {'Name': 'Oregon', 'Code': 'OR'},
                {'Name': 'Palau', 'Code': 'PW'},
                {'Name': 'Pennsylvania', 'Code': 'PA'},
                {'Name': 'Puerto Rico', 'Code': 'PR'},
                {'Name': 'Rhode Island', 'Code': 'RI'},
                {'Name': 'South Carolina', 'Code': 'SC'},
                {'Name': 'South Dakota', 'Code': 'SD'},
                {'Name': 'Tennessee', 'Code': 'TN'},
                {'Name': 'Texas', 'Code': 'TX'},
                {'Name': 'Utah', 'Code': 'UT'},
                {'Name': 'Vermont', 'Code': 'VT'},
                {'Name': 'Virgin Islands', 'Code': 'VI'},
                {'Name': 'Virginia', 'Code': 'VA'},
                {'Name': 'Washington', 'Code': 'WA'},
                {'Name': 'West Virginia', 'Code': 'WV'},
                {'Name': 'Wisconsin', 'Code': 'WI'},
                {'Name': 'Wyoming', 'Code': 'WY'}];
    } else {
        return [];
    }
}

MyWalletPhone.isStateWhitelistedForShapeshift = function(stateCode) {
    var states = walletOptions.getValue().shapeshift.statesWhitelist;
    return states.indexOf(stateCode) > -1;
}

MyWalletPhone.setStateForShapeshift = function(name, code) {
    MyWallet.wallet.shapeshift.setUSAState({
       'Name': name,
       'Code': code
    });
}

MyWalletPhone.isDepositTransaction = function(txHash) {
    return MyWallet.wallet.shapeshift.isDepositTx(txHash);
}

MyWalletPhone.isWithdrawalTransaction = function(txHash) {
    return MyWallet.wallet.shapeshift.isWithdrawalTx(txHash);
}

MyWalletPhone.getExchangeRateForHardLimit = function(assetType) {
    var currencyCode = MyWalletPhone.currencyCodeForHardLimit();
    return BlockchainAPI.getExchangeRate(currencyCode, assetType);
}

MyWalletPhone.currencyCodeForHardLimit = function() {
    return MyWallet.wallet.accountInfo.countryCodeGuess == 'US' ? 'USD' : 'EUR';
}

MyWalletPhone.fiatExchangeHardLimit = function() {
    return walletOptions.getValue().shapeshift.upperLimit;
}

MyWalletPhone.bch = {
    getHistory : function() {
        var success = function(promise) {
            console.log('Success fetching bch history')
            objc_on_fetch_bch_history_success();
            return promise;
        };
        
        var error = function(error) {
            console.log('Error fetching bch history')
            console.log(error);
            objc_on_fetch_bch_history_error(error);
        };
        
        return MyWallet.wallet.bch.getHistory().then(success).catch(error);
    },
    
    getHistoryAndRates : function() {
        var success = function(result) {
            objc_did_get_bitcoin_cash_exchange_rates(result[1], false);
            objc_on_fetch_bch_history_success();
            return result;
        }
        
        var error = function(e) {
            console.log('Error fetching bch history and rates')
            console.log(e);
        }
        
        var getBitcoinCashHistory = MyWallet.wallet.bch.getHistory();
        var getBitcoinCashExchangeRates = BlockchainAPI.getExchangeRate('USD', 'BCH');
        return Promise.all([getBitcoinCashHistory, getBitcoinCashExchangeRates]).then(success).catch(error);
    },
    
    fetchExchangeRates : function() {
        var success = function(result) {
            objc_did_get_bitcoin_cash_exchange_rates(result);
            return result;
        }
        
        var error = function(e) {
            console.log(e);
        }
        return BlockchainAPI.getExchangeRate('USD', 'BCH').then(success).catch(error);
    },
    
    getAvailableBalanceForAccount : function(accountIndex) {
        var success = function(result) {
            objc_on_get_available_btc_balance_success(result);
        }
        
        var error = function(e) {
            console.log('Error getting btc balance');
            console.log(e);
            objc_on_get_available_btc_balance_error(e);
        }
        
        var options = walletOptions.getValue();
        MyWallet.wallet.bch.accounts[accountIndex].getAvailableBalance(options.bcash.feePerByte).then(success).catch(error);
    },
    
    hasAccount : function() {
        var bch = MyWallet.wallet.bch;
        return bch && bch.defaultAccount;
    },
    
    getAllAccountsCount : function() {
        var bch = MyWallet.wallet.bch;
        return bch.accounts.length;
    },
    
    getLabelForDefaultAccount : function() {
        return MyWallet.wallet.bch.defaultAccount.label;
    },
    
    getDefaultAccountIndex : function() {
        return MyWallet.wallet.bch.defaultAccountIdx;
    },
    
    setDefaultAccount : function(index) {
        MyWallet.wallet.bch.defaultAccountIdx = index;
    },
    
    getReceiveAddressOfDefaultAccount : function() {
        return Helpers.toBitcoinCash(MyWallet.wallet.bch.defaultAccount.receiveAddress);
    },
    
    getReceivingAddressForAccount : function(index) {
        return Helpers.toBitcoinCash(MyWallet.wallet.bch.accounts[index].receiveAddress);
    },
    
    getLabelForAccount : function(index) {
        return MyWallet.wallet.bch.accounts[index].label;
    },
    
    setLabelForAccount : function(num, label) {
        MyWallet.wallet.bch.accounts[num].label = label;
    },
    
    getIndexOfActiveAccount : function(index) {
        var activeAccounts = MyWallet.wallet.bch.activeAccounts;
        var realNum = activeAccounts[index].index;
        return realNum;
    },
    
    getActiveAccountsCount : function() {
        return MyWallet.wallet.bch.activeAccounts.length;
    },
    
    getActiveLegacyAddresses : function() {
        return MyWallet.wallet.bch.importedAddresses.addresses.map(function(address) {
            var prefix = 'bitcoincash:';
            return Helpers.toBitcoinCash(address).slice(prefix.length);
        });
    },
    
    isArchived : function(index) {
        return MyWallet.wallet.bch.accounts[index].archived;
    },
    
    toggleArchived : function(index) {
        var account = MyWallet.wallet.bch.accounts[index];
        account.archived = !account.archived;
    },
    
    balanceActiveLegacy : function() {
        return MyWallet.wallet.bch.importedAddresses.balance;
    },
    
    getBalance : function() {
        return MyWallet.wallet.bch.balance;
    },
    
    getBalanceForAccount : function(index) {
        return MyWallet.wallet.bch.accounts[index].balance;
    },
    
    hasLegacyAddresses : function() {
        if (MyWallet.wallet.bch.importedAddresses) {
            return true;
        } else {
            return false;
        }
    },
    
    getBalanceForAddress : function(address) {
        return MyWallet.wallet.bch.getAddressBalance(Helpers.fromBitcoinCash('bitcoincash:' + address));
    },
    
    getXpubForAccount : function(index) {
        return MyWallet.wallet.bch.accounts[index].xpub;
    },
    
    transactions : function(filter) {
        return MyWallet.wallet.bch.txs.filter(function(tx) {

            var indexFromCoinType = function(coinType) {
                return coinType !== 'external' && coinType !== 'legacy' ? parseInt(coinType.charAt(0)) : null;
            };

            var fromIndex = indexFromCoinType(tx.from.coinType);
            if (fromIndex != null) tx.from.label = MyWallet.wallet.bch.accounts[fromIndex].label;

            if (tx.to && tx.to.length > 0) {
                var toIndex = indexFromCoinType(tx.to[0].coinType);
                if (toIndex != null) tx.to[0].label = MyWallet.wallet.bch.accounts[toIndex].label;
            } else {
                var address = tx.processedOutputs[0].address;
                tx.to = [{address: address, label: address, coinType: 'external'}];
            }

            if (filter == -1) return true;
            if (filter == -2) filter = 'imported';
            return tx.belongsTo(filter);
        });
    },
    
    isValidAddress : function(address) {
        var base = 'bitcoincash:';
        var prefixed = address.includes(base);
        if (!prefixed) address = base + address;
        return Helpers.fromBitcoinCash(address);
    },
    
    // Payment
    
    changePaymentFromAccount : function(from) {
        console.log('Changing bch payment from account');
        var bchAccount = MyWallet.wallet.bch.accounts[from];
        currentBitcoinCashPayment = bchAccount.createPayment();
        
        var options = walletOptions.getValue();
        bchAccount.getAvailableBalance(options.bcash.feePerByte).then(function(balance) {
            var fee = balance.sweepFee;
            var maxAvailable = balance.amount;
            objc_update_total_available_final_fee(maxAvailable, fee);
        }).catch(function(e) {
            console.log(e);
            objc_update_total_available_final_fee(0, 0);
        });
    },
    
    changePaymentFromImportedAddresses : function() {
        console.log('Changing bch payment from address');
        var importedAddresses = MyWallet.wallet.bch.importedAddresses;
        currentBitcoinCashPayment = importedAddresses.createPayment();
        
        var options = walletOptions.getValue();
        importedAddresses.getAvailableBalance(options.bcash.feePerByte).then(function(balance) {
            var fee = balance.sweepFee;
            var maxAvailable = balance.amount;
            objc_update_total_available_final_fee(maxAvailable, fee);
        }).catch(function(e) {
            console.log(e);
            objc_update_total_available_final_fee(0, 0);
        });
    },
    
    changePaymentToAccount : function(to) {
        console.log('Changing bch payment to account');
        var account = MyWallet.wallet.bch.accounts[to];
        var address = account.receiveAddress;
        currentBitcoinCashPayment.to(address);
    },
    
    changePaymentToAddress : function(to) {
        console.log('Changing bch payment to address');
        if (Helpers.isBitcoinAddress(to)) {
            currentBitcoinCashPayment.to(to);
        } else {
            currentBitcoinCashPayment.to(Helpers.fromBitcoinCash('bitcoincash:' + to));
        }
    },
    
    changePaymentAmount : function(amount) {
        console.log('Changing bch payment amount');
        currentBitcoinCashPayment.amount(amount);
    },
    
    buildPayment : function(to, amount) {
        if (Helpers.isNumber(to)) {
            MyWalletPhone.bch.changePaymentToAccount(to);
        } else {
            MyWalletPhone.bch.changePaymentToAddress(to);
        }
        
        MyWalletPhone.bch.changePaymentAmount(amount);
        
        var options = walletOptions.getValue()
        currentBitcoinCashPayment.feePerByte(options.bcash.feePerByte);
        currentBitcoinCashPayment.build();
    },
    
    quickSend : function(id, onSendScreen, secondPassword) {
        MyWalletPhone.quickSend(id, onSendScreen, secondPassword, 'bch');
    },
    
    didGetTxMessage : function() {
        MyWalletPhone.bch.getHistory().then(function(){objc_on_tx_received()});
    },
    
    getSocketOnOpenMessage : function() {
        return BlockchainSocket.xpubSub(MyWallet.wallet.bch.activeAccounts.map(function(account) {return account.xpub}));
    },
    
    getSwipeAddresses : function(numberOfAddresses) {
        var addresses = [];

        var xpub = MyWallet.wallet.bch.defaultAccount.xpub
        var receiveIndex = MyWallet.wallet.bch.getAccountIndexes(xpub).receive;
        const accountIndex = MyWallet.wallet.bch.defaultAccountIdx;

        for (var i = 0; i < numberOfAddresses; i++) {
            var address = Helpers.toBitcoinCash(Blockchain.MyWallet.wallet.hdwallet.accounts[accountIndex].receiveAddressAtIndex(receiveIndex + i));
            addresses.push(address);
        }

        objc_did_get_bch_swipe_addresses(addresses);
    },
    
    fromBitcoinCash : function(address) {
        var base = 'bitcoincash:';
        var prefixed = address.includes(base);
        if (!prefixed) address = base + address;
        return Helpers.fromBitcoinCash(address);
    },
    
    toBitcoinCash : function(address) {
        return Helpers.toBitcoinCash(address);
    }
};

MyWalletPhone.loadMetadata = function() {
    MyWallet.wallet.loadMetadata().then(function() {
        objc_reload();
    });
}

MyWalletPhone.getHistoryForAllAssets = function() {
    var getBitcoinHistory = MyWallet.wallet.getHistory();
    var eth = MyWallet.wallet.eth;
    var getEtherHistory = eth ? eth.fetchHistory() : {};
    var bch = MyWallet.wallet.bch;
    var getBitcoinCashHistory = bch ? bch.getHistory() : {};
    return Promise.all([getBitcoinHistory, getEtherHistory, getBitcoinCashHistory]);
}

MyWalletPhone.tradeExecution = {
    sendBitcoinTransaction : function(from, to, amount) {
        currentPayment = MyWallet.wallet.createPayment()
            .from(from)
            .to(to)
            .amount(amount)
        currentPayment.build().then(function (x) {

        }).catch(funcion(e){console.log('setupBitcoinTransaction: ' + e)})
    }
}
