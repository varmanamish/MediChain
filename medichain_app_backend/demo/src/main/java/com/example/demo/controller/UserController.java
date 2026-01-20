//package com.example.demo.controller;
//
//import com.example.demo.model.User;
//import com.example.demo.repository.UserRepository;
//import org.springframework.beans.factory.annotation.Autowired;
//import org.springframework.http.HttpStatus;
//import org.springframework.http.ResponseEntity;
//import org.springframework.security.crypto.password.PasswordEncoder;
//import org.springframework.web.bind.annotation.*;
//
//import java.util.Map;
//
//@RestController
//@RequestMapping("/api")
//@CrossOrigin(origins = "http://10.0.2.2") // Allow Flutter emulator requests
//public class UserController {
//
//    @Autowired
//    private UserRepository userRepository;
//
//    @Autowired
//    private PasswordEncoder passwordEncoder;
//
//    @PostMapping("/register")
//    public ResponseEntity<Map<String, String>> registerUser(@RequestBody User user) {
//        // Check for existing username or email
//        if (userRepository.findByUsername(user.getUsername()).isPresent()) {
//            return ResponseEntity.badRequest()
//                    .body(Map.of("message", "Username is already taken!"));
//        }
//        if (userRepository.findByMailId(user.getMailId()).isPresent()) {
//            return ResponseEntity.badRequest()
//                    .body(Map.of("message", "Email is already taken!"));
//        }
//
//        // Validate password match
//        if (!user.getPassword().equals(user.getConfirmPassword())) {
//            System.out.println(user.getPassword()+" "+user.getConfirmPassword());
//            return ResponseEntity.badRequest()
//                    .body(Map.of("message", "Passwords do not match!"));
//        }
//        // Hash the password before saving
//        user.setPassword(passwordEncoder.encode(user.getPassword()));
//        userRepository.save(user);
//
//        return ResponseEntity.status(HttpStatus.CREATED)
//                .body(Map.of("message", "User registered successfully!"));
//    }
//
//    @PostMapping("/login")
//    public ResponseEntity<Map<String, String>> loginUser(@RequestBody LoginRequest loginRequest) {
//        // Find user by username or email
//        User user = userRepository.findByUsername(loginRequest.getUsernameOrEmail())
//                .orElseGet(() -> userRepository.findByMailId(loginRequest.getUsernameOrEmail())
//                        .orElse(null));
//
//        if (user == null || !passwordEncoder.matches(loginRequest.getPassword(), user.getPassword())) {
//            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
//                    .body(Map.of("message", "Invalid username or password!"));
//        }
//
//        return ResponseEntity.ok(Map.of("message", "Login successful!"));
//    }
//}
//
//// DTO for login request
//class LoginRequest {
//    private String usernameOrEmail;
//    private String password;
//
//    // Getters and setters
//    public String getUsernameOrEmail() { return usernameOrEmail; }
//    public void setUsernameOrEmail(String usernameOrEmail) { this.usernameOrEmail = usernameOrEmail; }
//    public String getPassword() { return password; }
//    public void setPassword(String password) { this.password = password; }
//}

package com.example.demo.controller;

import com.example.demo.model.User;
import com.example.demo.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api")
@CrossOrigin(origins = {"http://10.0.2.2", "http://localhost"}) // Allow both
public class UserController {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @GetMapping("/health")
    public String health() {
        return "Backend is running";
    }

    @PostMapping("/register")
    public ResponseEntity<Map<String, Object>> registerUser(@RequestBody User user) {
        Map<String, Object> response = new HashMap<>();

        // Check for existing username or email
        if (userRepository.findByUsername(user.getUsername()).isPresent()) {
            response.put("success", false);
            response.put("message", "Username is already taken!");
            return ResponseEntity.badRequest().body(response);
        }

        if (userRepository.findByMailId(user.getMailId()).isPresent()) {
            response.put("success", false);
            response.put("message", "Email is already taken!");
            return ResponseEntity.badRequest().body(response);
        }

        // Validate password match
        if (!user.getPassword().equals(user.getConfirmPassword())) {
            response.put("success", false);
            response.put("message", "Passwords do not match!");
            return ResponseEntity.badRequest().body(response);
        }

        // Hash the password before saving
        user.setPassword(passwordEncoder.encode(user.getPassword()));

        // Set default values
        user.setActive(true);

        User savedUser = userRepository.save(user);

        // Return user data (without password)
        response.put("success", true);
        response.put("message", "User registered successfully!");
        response.put("user", Map.of(
                "id", savedUser.getId(),
                "username", savedUser.getUsername(),
                "email", savedUser.getMailId(),
                "firstName", savedUser.getFirstName(),
                "lastName", savedUser.getLastName(),
                "role", savedUser.getRole()
        ));

        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @PostMapping("/login")
    public ResponseEntity<Map<String, Object>> loginUser(@RequestBody LoginRequest loginRequest) {
        Map<String, Object> response = new HashMap<>();

        // Find user by username or email
        User user = userRepository.findByUsername(loginRequest.getUsernameOrEmail())
                .orElseGet(() -> userRepository.findByMailId(loginRequest.getUsernameOrEmail())
                        .orElse(null));

        if (user == null) {
            response.put("success", false);
            response.put("message", "User not found!");
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(response);
        }

        if (!passwordEncoder.matches(loginRequest.getPassword(), user.getPassword())) {
            response.put("success", false);
            response.put("message", "Invalid password!");
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(response);
        }

        // Check if user is active
        if (!user.isActive()) {
            response.put("success", false);
            response.put("message", "Account is deactivated!");
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(response);
        }

        // Successful login - return user info
        response.put("success", true);
        response.put("message", "Login successful!");
        response.put("user", Map.of(
                "id", user.getId(),
                "username", user.getUsername(),
                "email", user.getMailId(),
                "firstName", user.getFirstName(),
                "lastName", user.getLastName(),
                "role", user.getRole(),
                "phone", user.getPhone(),
                "dob", user.getDob()
        ));

        return ResponseEntity.ok(response);
    }
}

// DTO for login request
class LoginRequest {
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