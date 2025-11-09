package com.tradenbysell.repository;

import com.tradenbysell.model.ListingTag;
import com.tradenbysell.model.ListingTagId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ListingTagRepository extends JpaRepository<ListingTag, ListingTagId> {
    List<ListingTag> findByListingId(String listingId);
    void deleteByListingId(String listingId);
}

