import React, { useState, useEffect, useCallback } from 'react';
import { useAuth } from '../context/AuthContext';
import api from '../services/api';
import Navigation from '../components/Navigation';
import './AdminDashboard.css';

const AdminDashboard = () => {
  const { isAdmin } = useAuth();
  const [reports, setReports] = useState([]);
  const [users, setUsers] = useState([]);
  const [flaggedListings, setFlaggedListings] = useState([]);
  const [moderationStats, setModerationStats] = useState({});
  const [loading, setLoading] = useState(true);
  const [activeTab, setActiveTab] = useState('reports');
  const [selectedReport, setSelectedReport] = useState(null);
  const [selectedModeration, setSelectedModeration] = useState(null);
  const [adminAction, setAdminAction] = useState('');
  const [reportStatus, setReportStatus] = useState('NEW');
  const [moderationPage, setModerationPage] = useState(0);

  const fetchDashboardData = useCallback(async () => {
    try {
      if (activeTab === 'reports') {
        const response = await api.get('/api/admin/reports');
        setReports(response.data);
      } else if (activeTab === 'users') {
        const response = await api.get('/api/admin/users');
        setUsers(response.data);
      } else if (activeTab === 'moderation') {
        const [listingsResponse, statsResponse] = await Promise.all([
          api.get(`/api/moderation/admin/flagged-listings?page=${moderationPage}&size=20`),
          api.get('/api/moderation/admin/statistics')
        ]);
        setFlaggedListings(listingsResponse.data.content || []);
        setModerationStats(statsResponse.data || {});
      }
    } catch (err) {
      console.error('Failed to fetch dashboard data:', err);
    } finally {
      setLoading(false);
    }
  }, [activeTab, moderationPage]);

  useEffect(() => {
    if (!isAdmin()) {
      return;
    }
    fetchDashboardData();
  }, [activeTab, moderationPage, fetchDashboardData, isAdmin]);

  const handleReportUpdate = async (reportId) => {
    if (!adminAction.trim()) {
      alert('Please enter an admin action');
      return;
    }

    try {
      await api.put(`/api/admin/reports/${reportId}`, {
        status: reportStatus,
        adminAction: adminAction
      });
      setSelectedReport(null);
      setAdminAction('');
      fetchDashboardData();
    } catch (err) {
      alert('Failed to update report');
    }
  };

  const handleUserAction = async (userId, action) => {
    try {
      await api.post(`/api/admin/users/${userId}/${action}`);
      fetchDashboardData();
    } catch (err) {
      alert(`Failed to ${action} user`);
    }
  };

  const handleModerationAction = async (logId) => {
    if (!adminAction.trim()) {
      alert('Please select an action');
      return;
    }

    try {
      await api.put(`/api/moderation/admin/log/${logId}/action`, {
        action: adminAction,
        reason: `Admin action: ${adminAction}`
      });
      setSelectedModeration(null);
      setAdminAction('');
      fetchDashboardData();
    } catch (err) {
      alert('Failed to update moderation action');
    }
  };

  if (!isAdmin()) {
    return (
      <>
        <Navigation />
        <div className="admin-dashboard">
          <div className="container">
            <h1>Access Denied</h1>
            <p>You must be an administrator to access this page.</p>
          </div>
        </div>
      </>
    );
  }

  if (loading) {
    return (
      <>
        <Navigation />
        <div className="admin-dashboard">Loading...</div>
      </>
    );
  }

  return (
    <>
      <Navigation />
      <div className="admin-dashboard">
        <div className="container">
          <h1>Admin Dashboard</h1>

          <div className="tabs">
            <button
              className={activeTab === 'reports' ? 'active' : ''}
              onClick={() => setActiveTab('reports')}
            >
              Reports ({reports.filter(r => r.status === 'NEW').length})
            </button>
            <button
              className={activeTab === 'users' ? 'active' : ''}
              onClick={() => setActiveTab('users')}
            >
              Users
            </button>
            <button
              className={activeTab === 'moderation' ? 'active' : ''}
              onClick={() => setActiveTab('moderation')}
            >
              Moderation {moderationStats.pendingFlagged > 0 && `(${moderationStats.pendingFlagged})`}
            </button>
            <button
              className={activeTab === 'analytics' ? 'active' : ''}
              onClick={() => setActiveTab('analytics')}
            >
              Analytics
            </button>
          </div>

          {activeTab === 'reports' && (
            <div className="reports-section">
              <div className="section-header">
                <h2>Reports Management</h2>
                <select
                  value={reportStatus}
                  onChange={(e) => setReportStatus(e.target.value)}
                  className="filter-select"
                >
                  <option value="NEW">New</option>
                  <option value="UNDER_REVIEW">Under Review</option>
                  <option value="RESOLVED">Resolved</option>
                  <option value="ESCALATED">Escalated</option>
                  <option value="DISMISSED">Dismissed</option>
                </select>
              </div>

              {reports.length === 0 ? (
                <div className="no-reports">No reports found</div>
              ) : (
                <div className="reports-list">
                  {reports
                    .filter(r => reportStatus === 'ALL' || r.status === reportStatus)
                    .map(report => (
                      <div key={report.reportId} className="report-card">
                        <div className="report-header">
                          <div>
                            <h3>Report #{report.reportId}</h3>
                            <span className={`report-status ${report.status.toLowerCase().replace('_', '-')}`}>
                              {report.status}
                            </span>
                          </div>
                          <span className="report-date">
                            {new Date(report.createdAt).toLocaleString()}
                          </span>
                        </div>

                        <div className="report-details">
                          <p><strong>Type:</strong> {report.reportedType}</p>
                          <p><strong>Reported ID:</strong> {report.reportedId}</p>
                          <p><strong>Reporter:</strong> {report.reporterName}</p>
                          <p><strong>Reason:</strong></p>
                          <div className="reason-text">{report.reasonText}</div>
                          {report.adminAction && (
                            <>
                              <p><strong>Admin Action:</strong></p>
                              <div className="admin-action-text">{report.adminAction}</div>
                            </>
                          )}
                        </div>

                        {selectedReport === report.reportId ? (
                          <div className="admin-action-form">
                            <select
                              value={reportStatus}
                              onChange={(e) => setReportStatus(e.target.value)}
                              className="status-select"
                            >
                              <option value="NEW">New</option>
                              <option value="UNDER_REVIEW">Under Review</option>
                              <option value="RESOLVED">Resolved</option>
                              <option value="ESCALATED">Escalated</option>
                              <option value="DISMISSED">Dismissed</option>
                            </select>
                            <textarea
                              value={adminAction}
                              onChange={(e) => setAdminAction(e.target.value)}
                              placeholder="Enter admin action..."
                              rows="3"
                              className="action-textarea"
                            />
                            <div className="action-buttons">
                              <button
                                onClick={() => handleReportUpdate(report.reportId)}
                                className="save-btn"
                              >
                                Save Action
                              </button>
                              <button
                                onClick={() => {
                                  setSelectedReport(null);
                                  setAdminAction('');
                                }}
                                className="cancel-btn"
                              >
                                Cancel
                              </button>
                            </div>
                          </div>
                        ) : (
                          <button
                            onClick={() => setSelectedReport(report.reportId)}
                            className="action-btn"
                          >
                            Take Action
                          </button>
                        )}
                      </div>
                    ))}
                </div>
              )}
            </div>
          )}

          {activeTab === 'users' && (
            <div className="users-section">
              <h2>User Management</h2>
              {users.length === 0 ? (
                <div className="no-users">No users found</div>
              ) : (
                <div className="users-table">
                  <table>
                    <thead>
                      <tr>
                        <th>Name</th>
                        <th>Email</th>
                        <th>Role</th>
                        <th>Trust Score</th>
                        <th>Wallet Balance</th>
                        <th>Status</th>
                        <th>Actions</th>
                      </tr>
                    </thead>
                    <tbody>
                      {users.map(user => (
                        <tr key={user.userId}>
                          <td>{user.fullName}</td>
                          <td>{user.email}</td>
                          <td>{user.role}</td>
                          <td>{user.trustScore?.toFixed(1) || 'N/A'}</td>
                          <td>₹{user.walletBalance?.toFixed(2) || '0.00'}</td>
                          <td>
                            <span className={user.isSuspended ? 'suspended' : 'active'}>
                              {user.isSuspended ? 'Suspended' : 'Active'}
                            </span>
                          </td>
                          <td>
                            {!user.isSuspended ? (
                              <button
                                onClick={() => handleUserAction(user.userId, 'suspend')}
                                className="suspend-btn"
                              >
                                Suspend
                              </button>
                            ) : (
                              <button
                                onClick={() => handleUserAction(user.userId, 'unsuspend')}
                                className="unsuspend-btn"
                              >
                                Unsuspend
                              </button>
                            )}
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              )}
            </div>
          )}

          {activeTab === 'moderation' && (
            <div className="moderation-section">
              <div className="section-header">
                <h2>ML Content Moderation</h2>
                <div className="moderation-stats">
                  <span>Pending: {moderationStats.pendingFlagged || 0}</span>
                  <span>Approved: {moderationStats.approved || 0}</span>
                  <span>Rejected: {moderationStats.rejected || 0}</span>
                </div>
              </div>

              {flaggedListings.length === 0 ? (
                <div className="no-flagged">No flagged listings found</div>
              ) : (
                <div className="flagged-listings">
                  {flaggedListings.map(log => (
                    <div key={log.logId} className="moderation-card">
                      <div className="moderation-header">
                        <div>
                          <h3>Listing #{log.listingId || 'N/A'}</h3>
                          <span className={`label-badge ${log.predictedLabel}`}>
                            {log.predictedLabel} ({Math.round(log.confidence * 100)}%)
                          </span>
                        </div>
                        <span className="moderation-date">
                          {new Date(log.createdAt).toLocaleString()}
                        </span>
                      </div>

                      <div className="moderation-details">
                        <p><strong>User:</strong> {log.userName}</p>
                        <p><strong>Confidence:</strong> {Math.round(log.confidence * 100)}%</p>
                        <p><strong>Status:</strong> {log.adminAction || 'PENDING'}</p>
                        
                        {log.imageHeatmap && (
                          <div className="heatmap-preview">
                            <p><strong>ML Explanation:</strong></p>
                            <img src={log.imageHeatmap} alt="Heatmap" style={{maxWidth: '300px', marginTop: '10px'}} />
                          </div>
                        )}

                        {log.textExplanation && (
                          <div className="text-explanation">
                            <p><strong>Important Tokens:</strong></p>
                            <div className="tokens-list">
                              {log.textExplanation.tokens?.slice(0, 10).map((token, idx) => (
                                <span key={idx} className="token-badge">
                                  {token} ({log.textExplanation.scores?.[idx]?.toFixed(2)})
                                </span>
                              ))}
                            </div>
                          </div>
                        )}
                      </div>

                      {selectedModeration === log.logId ? (
                        <div className="moderation-actions">
                          <select
                            value={adminAction}
                            onChange={(e) => setAdminAction(e.target.value)}
                            className="action-select"
                          >
                            <option value="">Select Action</option>
                            <option value="APPROVED">Approve</option>
                            <option value="REJECTED">Reject</option>
                            <option value="BLACKLISTED">Blacklist User</option>
                          </select>
                          <button
                            onClick={() => handleModerationAction(log.logId)}
                            className="btn-primary"
                          >
                            Submit Action
                          </button>
                          <button
                            onClick={() => {
                              setSelectedModeration(null);
                              setAdminAction('');
                            }}
                            className="btn-secondary"
                          >
                            Cancel
                          </button>
                        </div>
                      ) : (
                        <button
                          onClick={() => setSelectedModeration(log.logId)}
                          className="btn-primary"
                        >
                          Review
                        </button>
                      )}
                    </div>
                  ))}
                </div>
              )}

              {moderationStats.totalPages > 1 && (
                <div className="pagination">
                  <button
                    onClick={() => setModerationPage(Math.max(0, moderationPage - 1))}
                    disabled={moderationPage === 0}
                  >
                    Previous
                  </button>
                  <span>Page {moderationPage + 1} of {moderationStats.totalPages}</span>
                  <button
                    onClick={() => setModerationPage(Math.min(moderationStats.totalPages - 1, moderationPage + 1))}
                    disabled={moderationPage >= moderationStats.totalPages - 1}
                  >
                    Next
                  </button>
                </div>
              )}
            </div>
          )}

          {activeTab === 'analytics' && (
            <div className="analytics-section">
              <h2>Analytics Dashboard</h2>
              <div className="stats-grid">
                <div className="stat-card">
                  <h3>Total Users</h3>
                  <p className="stat-value">{users.length}</p>
                </div>
                <div className="stat-card">
                  <h3>Total Reports</h3>
                  <p className="stat-value">{reports.length}</p>
                </div>
                <div className="stat-card">
                  <h3>New Reports</h3>
                  <p className="stat-value">{reports.filter(r => r.status === 'NEW').length}</p>
                </div>
                <div className="stat-card">
                  <h3>Resolved Reports</h3>
                  <p className="stat-value">{reports.filter(r => r.status === 'RESOLVED').length}</p>
                </div>
              </div>
            </div>
          )}
        </div>
      </div>
    </>
  );
};

export default AdminDashboard;
