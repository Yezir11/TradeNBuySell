import React, { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import api from '../services/api';
import MarketplaceHeader from '../components/MarketplaceHeader';
import './AuthPage.css';

const AuthPage = () => {
  const [isLogin, setIsLogin] = useState(true);
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [fullName, setFullName] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const { login } = useAuth();
  const navigate = useNavigate();

  const handleToggleMode = () => {
    setIsLogin(!isLogin);
    setError(''); // Clear error when switching modes
    setEmail('');
    setPassword('');
    setFullName('');
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setLoading(true);

    try {
      if (isLogin) {
        const response = await api.post('/api/auth/login', { email, password });
        login(response.data.token, response.data);
        navigate('/marketplace');
      } else {
        const response = await api.post('/api/auth/register', { email, password, fullName });
        login(response.data.token, response.data);
        navigate('/marketplace');
      }
    } catch (err) {
      const errorMessage = err.response?.data?.message || err.message || 'An error occurred. Please try again.';
      setError(errorMessage);
      setLoading(false); // Don't navigate on error, so loading should be false
    }
  };

  return (
    <>
      <MarketplaceHeader showSearch={false} />
      <div className="auth-page">
        <div className="auth-container">
          <h1>{isLogin ? 'Login' : 'Register'}</h1>
          
          {error && <div className="error-message">{error}</div>}

          <form onSubmit={handleSubmit}>
            {!isLogin && (
              <div className="form-group">
                <label>Full Name</label>
                <input
                  type="text"
                  value={fullName}
                  onChange={(e) => setFullName(e.target.value)}
                  required
                />
              </div>
            )}
            
            <div className="form-group">
              <label>Email</label>
              <input
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="yourname@pilani.bits-pilani.ac.in"
                required
              />
            </div>

            <div className="form-group">
              <label>Password</label>
              <input
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
              />
            </div>

            <button type="submit" disabled={loading} className="submit-btn">
              {loading ? 'Processing...' : (isLogin ? 'Login' : 'Register')}
            </button>
          </form>

          <div className="auth-footer">
            <p>
              {isLogin ? "Don't have an account? " : "Already have an account? "}
              <button onClick={handleToggleMode} className="link-button">
                {isLogin ? 'Register' : 'Login'}
              </button>
            </p>
          </div>
        </div>
      </div>
    </>
  );
};

export default AuthPage;
