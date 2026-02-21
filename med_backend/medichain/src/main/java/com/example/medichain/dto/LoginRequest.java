package com.example.medichain.dto;

// DTO for login request
public class LoginRequest {
    private String usernameOrEmail;
    private String password;

    // Getters and setters
    public String getUsernameOrEmail() { return usernameOrEmail; }
    public void setUsernameOrEmail(String usernameOrEmail) {
        this.usernameOrEmail = usernameOrEmail;
    }

    public String getPassword() { return password; }
    public void setPassword(String password) {
        this.password = password;
    }

    // Add toString for debugging
    @Override
    public String toString() {
        return "LoginRequest{" +
                "usernameOrEmail='" + usernameOrEmail + '\'' +
                ", password='" + password + '\'' +
                '}';
    }
}
