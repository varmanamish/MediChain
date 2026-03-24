package com.example.medichain.dto;

import java.math.BigInteger;

public class OwnershipRecordResponse {

    private final String owner;
    private final BigInteger role;
    private final BigInteger timestamp;

    public OwnershipRecordResponse(String owner, BigInteger role, BigInteger timestamp) {
        this.owner = owner;
        this.role = role;
        this.timestamp = timestamp;
    }

    public String getOwner() {
        return owner;
    }

    public BigInteger getRole() {
        return role;
    }

    public BigInteger getTimestamp() {
        return timestamp;
    }
}
