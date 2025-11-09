package com.tradenbysell.model;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;

@Embeddable
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ListingTagId implements Serializable {
    @Column(name = "listing_id", length = 36, columnDefinition = "CHAR(36)")
    private String listingId;

    @Column(length = 50)
    private String tag;
}

