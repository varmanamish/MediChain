package com.example.medichain.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.web3j.crypto.Credentials;
import org.web3j.protocol.Web3j;
import org.web3j.tx.RawTransactionManager;
import org.web3j.tx.TransactionManager;
import org.web3j.tx.response.PollingTransactionReceiptProcessor;
import org.web3j.tx.response.TransactionReceiptProcessor;

@Configuration
public class ContractConfig {

	private final Web3j web3j;
	private final BlockchainProperties properties;

	public ContractConfig(Web3j web3j, BlockchainProperties properties) {
		this.web3j = web3j;
		this.properties = properties;
	}

	@Bean
	public Credentials credentials() {
		return Credentials.create(properties.getWalletPrivateKey());
	}

	@Bean(name = "web3jTransactionManager")
	public TransactionManager web3jTransactionManager(Credentials credentials) {
		return new RawTransactionManager(web3j, credentials);
	}

	@Bean
	public TransactionReceiptProcessor transactionReceiptProcessor() {
		return new PollingTransactionReceiptProcessor(
				web3j,
				properties.getTxReceipt().getPollIntervalMs(),
				properties.getTxReceipt().getMaxAttempts());
	}
}
