import React, { createContext, useState, useContext, useEffect } from 'react';
import api from '../services/api';

const AuthContext = createContext();

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};

export const AuthProvider = ({ children }) => {
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const validateToken = async () => {
    const token = localStorage.getItem('token');
    if (token) {
        try {
          // Validate token by fetching current user
      api.defaults.headers.common['Authorization'] = `Bearer ${token}`;
          const response = await api.get('/api/auth/me');
          if (response.data) {
      setIsAuthenticated(true);
            setUser({
              userId: response.data.userId,
              email: response.data.email,
              fullName: response.data.fullName,
              role: response.data.role,
            });
          } else {
            // Token is invalid, clear it
            localStorage.removeItem('token');
            delete api.defaults.headers.common['Authorization'];
            setIsAuthenticated(false);
            setUser(null);
          }
        } catch (error) {
          // Token is invalid or expired, clear it
          console.error('Token validation failed:', error);
          localStorage.removeItem('token');
          delete api.defaults.headers.common['Authorization'];
          setIsAuthenticated(false);
          setUser(null);
        }
      } else {
        // No token, ensure we're logged out
        setIsAuthenticated(false);
        setUser(null);
    }
    setLoading(false);
    };

    validateToken();
  }, []);

  const login = (token, userData) => {
    localStorage.setItem('token', token);
    api.defaults.headers.common['Authorization'] = `Bearer ${token}`;
    setIsAuthenticated(true);
    setUser(userData);
  };

  const logout = () => {
    localStorage.removeItem('token');
    delete api.defaults.headers.common['Authorization'];
    setIsAuthenticated(false);
    setUser(null);
  };

  const isAdmin = () => {
    return user?.role === 'ADMIN';
  };

  return (
    <AuthContext.Provider
      value={{
        isAuthenticated,
        user,
        loading,
        login,
        logout,
        isAdmin,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
};

