package com.example.medichain.util;

import java.util.Arrays;
import org.web3j.utils.Numeric;

public final class Bytes32Util {

    private Bytes32Util() {}

    public static byte[] fromHexString(String hex) {
        if (hex == null || hex.isBlank()) {
            throw new IllegalArgumentException("Hex string is required");
        }
        byte[] raw = Numeric.hexStringToByteArray(hex);
        if (raw.length > 32) {
            throw new IllegalArgumentException("Hex string exceeds 32 bytes");
        }
        if (raw.length == 32) {
            return raw;
        }
        byte[] padded = new byte[32];
        Arrays.fill(padded, (byte) 0);
        System.arraycopy(raw, 0, padded, 32 - raw.length, raw.length);
        return padded;
    }
}
