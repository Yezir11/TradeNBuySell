package com.tradenbysell.service;

import com.tradenbysell.model.AppSetting;
import com.tradenbysell.model.User;
import com.tradenbysell.repository.AppSettingRepository;
import com.tradenbysell.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AppSettingService {
    @Autowired
    private AppSettingRepository appSettingRepository;

    @Autowired
    private UserRepository userRepository;

    private static final String MANDATORY_MODERATION_KEY = "MANDATORY_MODERATION_ENABLED";

    /**
     * Get the mandatory moderation enabled setting
     */
    public boolean isMandatoryModerationEnabled() {
        return appSettingRepository.findBySettingKey(MANDATORY_MODERATION_KEY)
                .map(setting -> Boolean.parseBoolean(setting.getSettingValue()))
                .orElse(true); // Default to enabled if not found
    }

    /**
     * Get setting by key
     */
    public AppSetting getSetting(String key) {
        return appSettingRepository.findBySettingKey(key)
                .orElse(null);
    }

    /**
     * Update mandatory moderation enabled setting
     */
    @Transactional
    public AppSetting updateMandatoryModerationSetting(boolean enabled, String userId) {
        AppSetting setting = appSettingRepository.findBySettingKey(MANDATORY_MODERATION_KEY)
                .orElse(null);

        if (setting == null) {
            // Create new setting if it doesn't exist
            setting = new AppSetting();
            setting.setSettingKey(MANDATORY_MODERATION_KEY);
        }

        setting.setSettingValue(String.valueOf(enabled));
        setting.setDescription("If true, all new postings must go through ML moderation before being activated");

        if (userId != null) {
            try {
                userRepository.findById(userId).ifPresent(setting::setUpdatedBy);
            } catch (Exception e) {
                // If user lookup fails, continue without setting updatedBy
                System.err.println("Warning: Could not set updatedBy for setting: " + e.getMessage());
            }
        }

        try {
            return appSettingRepository.save(setting);
        } catch (Exception e) {
            throw new RuntimeException("Failed to update mandatory moderation setting: " + e.getMessage(), e);
        }
    }

    /**
     * Update any setting
     */
    @Transactional
    public AppSetting updateSetting(String key, String value, String description, String userId) {
        AppSetting setting = appSettingRepository.findBySettingKey(key)
                .orElse(new AppSetting());

        setting.setSettingKey(key);
        setting.setSettingValue(value);
        if (description != null) {
            setting.setDescription(description);
        }
        if (userId != null) {
            userRepository.findById(userId).ifPresent(setting::setUpdatedBy);
        }

        return appSettingRepository.save(setting);
    }
}

