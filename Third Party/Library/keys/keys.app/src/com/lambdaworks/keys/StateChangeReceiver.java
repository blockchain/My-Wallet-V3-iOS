// Copyright (C) 2013 - Will Glozer. All rights reserved.

package com.lambdaworks.keys;

import android.content.*;
import android.net.ConnectivityManager;
import android.preference.PreferenceManager;

public class StateChangeReceiver extends BroadcastReceiver {
    @Override
    public void onReceive(Context context, Intent intent) {
        SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(context);

        boolean connected = KeysCore.interfaces().length > 0;
        boolean start = false;
        String action = intent.getAction();

        if (Intent.ACTION_BOOT_COMPLETED.equals(action)) {
            start = prefs.getBoolean("start_on_boot", false);
         } else if (ConnectivityManager.CONNECTIVITY_ACTION.equals(action)) {
            start = prefs.getBoolean("start_on_connection", false);
        }

        intent = new Intent(context, KeysService.class);

        if (connected && start) {
            String path = KeysCore.databaseDir(context.getApplicationContext()).getAbsolutePath();
            intent.putExtra("path", path);
            context.startService(intent);
        } else if (!connected) {
            context.stopService(intent);
        }
    }
}
