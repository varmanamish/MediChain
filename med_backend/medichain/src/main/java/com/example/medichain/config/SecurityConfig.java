package com.example.medichain.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

//    @Bean
//    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
//        http
//                .csrf(csrf -> csrf.disable())
//                .authorizeHttpRequests(auth -> auth
//                        .requestMatchers(
//                                "/api/register",
//                                "/api/login",
//                                "/api/products",
//                                "/api/products/top-rated",
//                                "/api/posts",
//                                // ADD YOUR PROTECTED ENDPOINTS HERE TEMPORARILY
//                                "/api/users/**",      // Add user endpoints
//                                "/api/manufacturer/**", // Add manufacturer endpoints
//                                "/api/distributor/**",  // Add distributor endpoints
//                                "/api/pharmacy/**",     // Add pharmacy endpoints
//                                "/api/end-user/**"      // Add end-user endpoints
//                        ).permitAll() // Allow public access
//                        .anyRequest().authenticated() // Secure all other endpoints
//                );
//
//        return http.build();
//    }
    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
                .csrf(csrf -> csrf.disable())
                .authorizeHttpRequests(auth -> auth
                        .anyRequest().permitAll() // Allow ALL requests without authentication
                );

        return http.build();
    }
}