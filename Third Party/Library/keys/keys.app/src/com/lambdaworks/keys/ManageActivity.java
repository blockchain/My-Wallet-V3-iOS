// Copyright (C) 2013 - Will Glozer. All rights reserved.

package com.lambdaworks.keys;

import android.app.Activity;
import android.os.Bundle;

public class ManageActivity extends Activity {
    @Override
    public void onCreate(Bundle state) {
        super.onCreate(state);
        ManageFragment settings = new ManageFragment();
        getFragmentManager().beginTransaction().replace(android.R.id.content, settings).commit();
    }
}
