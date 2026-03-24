package com.example.medichain.dto;

import java.math.BigInteger;
import java.util.List;

public class TransactionResponse {

    private String transactionHash;
    private BigInteger blockNumber;
    private BigInteger gasUsed;
    private String status;
    private List<String> logs;

    public TransactionResponse(String transactionHash,
                               BigInteger blockNumber,
                               BigInteger gasUsed,
                               String status,
                               List<String> logs) {
        this.transactionHash = transactionHash;
        this.blockNumber = blockNumber;
        this.gasUsed = gasUsed;
        this.status = status;
        this.logs = logs;
    }

    public String getTransactionHash() { return transactionHash; }
    public BigInteger getBlockNumber() { return blockNumber; }
    public BigInteger getGasUsed() { return gasUsed; }
    public String getStatus() { return status; }
    public List<String> getLogs() { return logs; }
}
