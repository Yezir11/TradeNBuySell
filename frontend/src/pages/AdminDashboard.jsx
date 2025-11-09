import React, { useState, useEffect } from 'react';
import { useAuth } from '../context/AuthContext';
import api from '../services/api';
import Navigation from '../components/Navigation';
import './AdminDashboard.css';

const AdminDashboard = () => {
  const { user, isAdmin } = useAuth();
  const [reports, setReports] = useState([]);
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [activeTab, setActiveTab] = useState('reports');
  const [selectedReport, setSelectedReport] = useState(null);
  const [adminAction, setAdminAction] = useState('');
  const [reportStatus, setReportStatus] = useState('NEW');

  useEffect(() => {
    if (!isAdmin()) {
      return;
    }
    fetchDashboardData();
  }, [activeTab]);

  const fetchDashboardData = async () => {
    try {
      if (activeTab === 'reports') {
        const response = await api.get('/api/admin/reports');
        setReports(response.data);
      } else if (activeTab === 'users') {
        const response = await api.get('/api/admin/users');
        setUsers(response.data);
      }
    } catch (err) {
      console.error('Failed to fetch dashboard data:', err);
    } finally {
      setLoading(false);
    }
  };

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
