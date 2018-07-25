// Copyright (C) 2013 - Will Glozer. All rights reserved.

package com.lambdaworks.keys;

import android.content.Context;

import java.io.File;

public class KeysCore {
    static {
        System.loadLibrary("keys");
    }

    public static File databaseDir(Context context) {
        return new File(context.getFilesDir(), "db");
    }

    public static String issueCert(Context context) {
        String path = databaseDir(context).getAbsolutePath();
        return issueCert(path);
    }

    public static native String initialize(String path, long N, long r, long p);
    public static native NetworkInterface[] interfaces();
    public static native String issueCert(String path);
    public static native Version version();
}
