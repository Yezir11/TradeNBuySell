package com.tradenbysell.repository;

import com.tradenbysell.model.Report;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ReportRepository extends JpaRepository<Report, Long> {
    List<Report> findByStatusOrderByCreatedAtDesc(Report.ReportStatus status);
    List<Report> findByReporterIdOrderByCreatedAtDesc(String reporterId);
    List<Report> findByReportedTypeOrderByCreatedAtDesc(Report.ReportedType reportedType);
    boolean existsByReporterIdAndReportedTypeAndReportedId(String reporterId, Report.ReportedType reportedType, String reportedId);
}

