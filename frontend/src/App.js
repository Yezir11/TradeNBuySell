import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { ThemeProvider, createTheme } from '@mui/material/styles';
import CssBaseline from '@mui/material/CssBaseline';
import { AuthProvider } from './context/AuthContext';
import PrivateRoute from './components/PrivateRoute';
import './App.css';

// Pages
import LandingPage from './pages/LandingPage';
import AuthPage from './pages/AuthPage';
import AuthCallback from './pages/AuthCallback';
import PasswordSetup from './pages/PasswordSetup';
import Marketplace from './pages/Marketplace';
import ListingDetails from './pages/ListingDetails';
import PostListing from './pages/PostListing';
import MyProfile from './pages/MyProfile';
import Wallet from './pages/Wallet';
import TradeCenter from './pages/TradeCenter';
import BiddingCenter from './pages/BiddingCenter';
import ChatPage from './pages/ChatPage';
import AdminDashboard from './pages/AdminDashboard';

const theme = createTheme({
  palette: {
    primary: {
      main: '#1976d2',
    },
    secondary: {
      main: '#dc004e',
    },
  },
});

function App() {
  return (
    <ThemeProvider theme={theme}>
      <CssBaseline />
      <AuthProvider>
        <Router
          future={{
            v7_startTransition: true,
            v7_relativeSplatPath: true,
          }}
        >
          <div className="App">
            <Routes>
              <Route path="/" element={<LandingPage />} />
              <Route path="/auth" element={<AuthPage />} />
              <Route path="/auth/callback" element={<AuthCallback />} />
              <Route path="/setup-password" element={<PasswordSetup />} />
              <Route path="/marketplace" element={<Marketplace />} />
              <Route path="/listing/:listingId" element={<ListingDetails />} />
              <Route
                path="/post-listing"
                element={
                  <PrivateRoute>
                    <PostListing />
                  </PrivateRoute>
                }
              />
              <Route
                path="/profile"
                element={
                  <PrivateRoute>
                    <MyProfile />
                  </PrivateRoute>
                }
              />
              <Route
                path="/wallet"
                element={
                  <PrivateRoute>
                    <Wallet />
                  </PrivateRoute>
                }
              />
              <Route
                path="/trades"
                element={
                  <PrivateRoute>
                    <TradeCenter />
                  </PrivateRoute>
                }
              />
              <Route
                path="/bids"
                element={
                  <PrivateRoute>
                    <BiddingCenter />
                  </PrivateRoute>
                }
              />
              <Route
                path="/chat"
                element={
                  <PrivateRoute>
                    <ChatPage />
                  </PrivateRoute>
                }
              />
              <Route
                path="/admin"
                element={
                  <PrivateRoute>
                    <AdminDashboard />
                  </PrivateRoute>
                }
              />
            </Routes>
          </div>
        </Router>
      </AuthProvider>
    </ThemeProvider>
  );
}

export default App;
