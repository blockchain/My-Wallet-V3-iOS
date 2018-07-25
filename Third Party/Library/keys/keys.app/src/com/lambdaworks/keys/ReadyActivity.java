// Copyright (C) 2013 - Will Glozer. All rights reserved.

package com.lambdaworks.keys;

import android.app.Activity;
import android.os.Bundle;
import android.view.Menu;
import android.widget.*;

import java.io.*;

public class ReadyActivity extends Activity {
    public void onCreate(Bundle state) {
        super.onCreate(state);
        setTitle(getString(R.string.certificate));
        setContentView(R.layout.ready);

        EditText password = (EditText) findViewById(R.id.password);
        password.setKeyListener(null);
        password.setText(getIntent().getStringExtra("password"));
    }

    @Override
    protected void onStart() {
        super.onStart();
        File cert = new File(KeysCore.databaseDir(getApplicationContext()), "client.pem");
        CertFragment fragment = (CertFragment) getFragmentManager().findFragmentByTag("cert");
        fragment.setCert(cert);
    }
}