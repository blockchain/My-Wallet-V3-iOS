// Copyright (C) 2013 - Will Glozer. All rights reserved.

package com.lambdaworks.keys;

import android.app.ProgressDialog;
import android.content.Context;
import android.os.AsyncTask;

public abstract class ProgressTask<Params, Progress, Result> extends AsyncTask<Params, Progress, Result> {
    ProgressDialog dialog;

    protected ProgressTask(Context context, int message) {
        dialog = new ProgressDialog(context);
        dialog.setProgressStyle(ProgressDialog.STYLE_SPINNER);
        dialog.setCancelable(false);
        dialog.setMessage(context.getString(message));
    }

    @Override
    protected void onPreExecute() {
        super.onPreExecute();
        dialog.show();
    }

    @Override
    protected void onPostExecute(Result result) {
        super.onPostExecute(result);
        dialog.dismiss();
    }
}
