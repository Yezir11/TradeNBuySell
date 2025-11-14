package com.tradenbysell.repository;

import com.tradenbysell.model.FeaturedPackage;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface FeaturedPackageRepository extends JpaRepository<FeaturedPackage, String> {
    List<FeaturedPackage> findByIsActiveOrderByDisplayOrderAsc(Boolean isActive);
    Optional<FeaturedPackage> findByPackageIdAndIsActive(String packageId, Boolean isActive);
}

