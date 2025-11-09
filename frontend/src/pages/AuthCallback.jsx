import React, { useEffect, useState } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import api from '../services/api';
import Navigation from '../components/Navigation';
import './AuthCallback.css';

const AuthCallback = () => {
  const [searchParams] = useSearchParams();
  const { login } = useAuth();
  const navigate = useNavigate();
  const [error, setError] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const token = searchParams.get('token');
    const errorParam = searchParams.get('error');

    if (errorParam) {
      setError(`OAuth authentication failed: ${errorParam}. Please ensure you're using a @pilani.bits-pilani.ac.in email.`);
      setLoading(false);
      return;
    }

    if (token) {
      // Store token first
      localStorage.setItem('token', token);
      api.defaults.headers.common['Authorization'] = `Bearer ${token}`;
      
      // Get user info
      api.get('/api/auth/me')
        .then(response => {
          const userData = {
            userId: response.data.userId,
            email: response.data.email,
            fullName: response.data.fullName,
            role: response.data.role
          };
          login(token, userData);
          navigate('/marketplace');
        })
        .catch(err => {
          console.error('Failed to fetch user info:', err);
          setError('Failed to complete login. Please try again.');
          setLoading(false);
          localStorage.removeItem('token');
        });
    } else {
      setError('No authentication token received from OAuth provider.');
      setLoading(false);
    }
  }, [searchParams, login, navigate]);

  if (loading) {
    return (
      <>
        <Navigation />
        <div className="auth-callback">
          <div className="callback-container">
            <div className="spinner"></div>
            <p>Completing authentication...</p>
          </div>
        </div>
      </>
    );
  }

  if (error) {
    return (
      <>
        <Navigation />
        <div className="auth-callback">
          <div className="callback-container">
            <div className="error-icon">✕</div>
            <h2>Authentication Failed</h2>
            <p>{error}</p>
            <button onClick={() => navigate('/auth')} className="retry-btn">
              Go to Login Page
            </button>
          </div>
        </div>
      </>
    );
  }

  return null;
};

export default AuthCallback;

