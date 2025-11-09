package com.tradenbysell.service;

import com.tradenbysell.exception.ResourceNotFoundException;
import com.tradenbysell.model.User;
import com.tradenbysell.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class UserService {
    @Autowired
    private UserRepository userRepository;

    public User getUserById(String userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
    }

    public User getUserByEmail(String email) {
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
    }

    public List<User> getAllUsers() {
        return userRepository.findAll();
    }

    @Transactional
    public void suspendUser(String userId) {
        User user = getUserById(userId);
        user.setIsSuspended(true);
        userRepository.save(user);
    }

    @Transactional
    public void unsuspendUser(String userId) {
        User user = getUserById(userId);
        user.setIsSuspended(false);
        userRepository.save(user);
    }
}

