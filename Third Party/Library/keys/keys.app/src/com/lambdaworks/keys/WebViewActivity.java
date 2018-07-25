// Copyright (C) 2013 - Will Glozer. All rights reserved.

package com.lambdaworks.keys;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.webkit.WebView;

public class WebViewActivity extends Activity {
    public void onCreate(Bundle state) {
        super.onCreate(state);
        setContentView(R.layout.web);

        Intent intent = getIntent();
        setTitle(intent.getStringExtra("title"));
        WebView webView = (WebView) findViewById(R.id.web);
        webView.loadUrl(intent.getStringExtra("url"));
    }


}
