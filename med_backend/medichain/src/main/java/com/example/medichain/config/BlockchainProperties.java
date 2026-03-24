package com.example.medichain.config;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.math.BigInteger;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;
import org.springframework.validation.annotation.Validated;

@Component
@ConfigurationProperties(prefix = "blockchain")
@Validated
public class BlockchainProperties {

    @NotBlank
    private String rpcUrl;

    @NotBlank
    private String walletPrivateKey;

    @NotNull
    private BigInteger gasPrice;

    @NotNull
    private BigInteger gasLimit;

    @NotNull
    private SupplyChain supplyChain;

    @NotNull
    private TxReceipt txReceipt;

    public String getRpcUrl() {
        return rpcUrl;
    }

    public void setRpcUrl(String rpcUrl) {
        this.rpcUrl = rpcUrl;
    }

    public String getWalletPrivateKey() {
        return walletPrivateKey;
    }

    public void setWalletPrivateKey(String walletPrivateKey) {
        this.walletPrivateKey = walletPrivateKey;
    }

    public BigInteger getGasPrice() {
        return gasPrice;
    }

    public void setGasPrice(BigInteger gasPrice) {
        this.gasPrice = gasPrice;
    }

    public BigInteger getGasLimit() {
        return gasLimit;
    }

    public void setGasLimit(BigInteger gasLimit) {
        this.gasLimit = gasLimit;
    }

    public SupplyChain getSupplyChain() {
        return supplyChain;
    }

    public void setSupplyChain(SupplyChain supplyChain) {
        this.supplyChain = supplyChain;
    }

    public TxReceipt getTxReceipt() {
        return txReceipt;
    }

    public void setTxReceipt(TxReceipt txReceipt) {
        this.txReceipt = txReceipt;
    }

    public static class SupplyChain {
        @NotBlank
        private String contractAddress;

        public String getContractAddress() {
            return contractAddress;
        }

        public void setContractAddress(String contractAddress) {
            this.contractAddress = contractAddress;
        }
    }

    public static class TxReceipt {
        @NotNull
        private Integer pollIntervalMs;

        @NotNull
        private Integer maxAttempts;

        public Integer getPollIntervalMs() {
            return pollIntervalMs;
        }

        public void setPollIntervalMs(Integer pollIntervalMs) {
            this.pollIntervalMs = pollIntervalMs;
        }

        public Integer getMaxAttempts() {
            return maxAttempts;
        }

        public void setMaxAttempts(Integer maxAttempts) {
            this.maxAttempts = maxAttempts;
        }
    }
}
