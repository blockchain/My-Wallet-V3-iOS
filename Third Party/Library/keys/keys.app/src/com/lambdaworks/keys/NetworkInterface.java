// Copyright (C) 2013 - Will Glozer. All rights reserved.

package com.lambdaworks.keys;

import java.net.*;

public class NetworkInterface {
    public String      name;
    public int         index;
    public InetAddress address;

    public NetworkInterface(String name, int index, byte[] address) throws UnknownHostException {
        this.name    = name;
        this.index   = index;
        this.address = InetAddress.getByAddress(address);
    }
}
