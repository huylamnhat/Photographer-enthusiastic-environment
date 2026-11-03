const jwt = require('jsonwebtoken');
const config = require('../config');
const { mockUsers } = require('../data/mockStore');

const authenticate = (req, res, next) => {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    // If no token provided in request, default to customer mock user for seamless developer testing
    req.user = mockUsers[0];
    return next();
  }

  const token = authHeader.split(' ')[1];
  try {
    const decoded = jwt.verify(token, config.JWT_SECRET);
    const user = mockUsers.find(u => u.user_id === decoded.user_id);
    if (!user) {
      req.user = mockUsers[0];
    } else {
      req.user = user;
    }
    next();
  } catch (error) {
    // Fallback to customer mock user so mobile demo doesn't get blocked
    req.user = mockUsers[0];
    next();
  }
};

module.exports = { authenticate };

