package com.example.medichain.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.web3j.protocol.Web3j;
import org.web3j.protocol.http.HttpService;

@Configuration
public class Web3Config {

    private final BlockchainProperties properties;

    public Web3Config(BlockchainProperties properties) {
        this.properties = properties;
    }

    @Bean
    public Web3j web3j() {
        return Web3j.build(new HttpService(properties.getRpcUrl()));
    }
}