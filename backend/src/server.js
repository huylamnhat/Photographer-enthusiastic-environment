const app = require('./app');

const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
  console.log(`====================================================`);
  console.log(`🚀 Film Web Lab Server đang chạy tại: http://localhost:${PORT}`);
  console.log(`📡 API Endpoints sẵn sàng tại: http://localhost:${PORT}/api/lab/`);
  console.log(`====================================================`);
});
