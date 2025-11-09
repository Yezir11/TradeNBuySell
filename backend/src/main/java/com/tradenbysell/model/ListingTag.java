package com.tradenbysell.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;

@Entity
@Table(name = "listing_tags")
@IdClass(ListingTagId.class)
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ListingTag {
    @Id
    @Column(name = "listing_id", nullable = false, length = 36, columnDefinition = "CHAR(36)")
    private String listingId;

    @Id
    @Column(nullable = false, length = 50)
    private String tag;
}


