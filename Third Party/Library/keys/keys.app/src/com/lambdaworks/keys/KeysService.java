// Copyright (C) 2013 - Will Glozer. All rights reserved.

package com.lambdaworks.keys;

import android.app.Notification;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Intent;
import android.content.res.Resources;
import android.os.IBinder;

public class KeysService extends Service {
    static boolean running;

    static {
        System.loadLibrary("keys");
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        running = true;
        Resources r = getResources();
        String path = intent.getStringExtra("path");
        start(path, intent.getIntExtra("interface", 0));
        PendingIntent pending = PendingIntent.getActivity(getBaseContext(), 0, new Intent(this, KeysActivity.class), 0);
        Notification notification = new Notification.Builder(this)
                .setContentTitle(r.getString(R.string.serverActive))
                .setSmallIcon(R.drawable.ic_menu_card)
                .setOngoing(true)
                .setPriority(Notification.PRIORITY_MIN)
                .setContentIntent(pending)
                .build();
        startForeground(1, notification);
        return START_REDELIVER_INTENT;
    }

    @Override
    public void onDestroy() {
        running = false;
        stop();
    }

    public native void start(String path, int index);
    public native void stop();
}
