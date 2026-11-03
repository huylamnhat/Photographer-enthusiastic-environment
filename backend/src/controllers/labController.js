const { mockLabs, mockServicePackages, mockReviews } = require('../data/mockStore');

exports.getAllLabs = (req, res) => {
  const { search, city, format, process_type } = req.query;
  let results = [...mockLabs];

  if (search) {
    const q = search.toLowerCase();
    results = results.filter(l => 
      l.name.toLowerCase().includes(q) || 
      l.tagline.toLowerCase().includes(q) ||
      l.address.toLowerCase().includes(q)
    );
  }

  if (city) {
    results = results.filter(l => l.city.toLowerCase() === city.toLowerCase());
  }

  if (format) {
    results = results.filter(l => l.supported_formats.includes(format));
  }

  if (process_type) {
    results = results.filter(l => l.supported_processes.some(p => p.toLowerCase().includes(process_type.toLowerCase())));
  }

  return res.json({
    success: true,
    count: results.length,
    data: results
  });
};

exports.getLabById = (req, res) => {
  const { id } = req.params;
  const lab = mockLabs.find(l => l.lab_id === id);
  if (!lab) {
    return res.status(404).json({ success: false, message: 'Không tìm thấy Film Lab' });
  }

  const packages = mockServicePackages.filter(p => p.lab_id === id);
  const reviews = mockReviews.filter(r => r.lab_id === id);

  return res.json({
    success: true,
    data: {
      ...lab,
      packages,
      reviews
    }
  });
};

exports.getLabPackages = (req, res) => {
  const { id } = req.params;
  const packages = mockServicePackages.filter(p => p.lab_id === id);
  return res.json({
    success: true,
    data: packages
  });
};

