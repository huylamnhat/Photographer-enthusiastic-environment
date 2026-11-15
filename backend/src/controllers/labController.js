const { mockLabs, mockServicePackages, mockReviews } = require('../data/mockStore');

const LAB_ALIAS_MAP = {
  croplab: 'lab-001',
  llab: 'lab-002',
  nadar: 'lab-003',
};

function resolveLabId(id) {
  const raw = String(id || '').trim().toLowerCase();
  if (LAB_ALIAS_MAP[raw]) return LAB_ALIAS_MAP[raw];
  if (raw.includes('croplab')) return 'lab-001';
  if (raw.includes('llab') || raw.includes('saigon') || raw.includes('sài-gòn') || raw.includes('sài gòn')) return 'lab-002';
  if (raw.includes('nadar')) return 'lab-003';
  return id;
}

function attachLabDetails(lab) {
  const activePackages = mockServicePackages.filter(
    p => p.lab_id === lab.lab_id && p.status !== 'INACTIVE'
  );
  return {
    ...lab,
    packages: activePackages,
    process_table: lab.process_table || [],
  };
}

exports.getAllLabs = (req, res) => {
  res.set('Cache-Control', 'no-store, no-cache, must-revalidate');
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

  const enriched = results.map(attachLabDetails);

  return res.json({
    success: true,
    count: enriched.length,
    data: enriched
  });
};

exports.getLabById = (req, res) => {
  res.set('Cache-Control', 'no-store, no-cache, must-revalidate');
  const resolvedId = resolveLabId(req.params.id);
  const lab = mockLabs.find(l => l.lab_id === resolvedId || l.lab_id === req.params.id);
  if (!lab) {
    return res.status(404).json({ success: false, message: 'Không tìm thấy Film Lab' });
  }

  const reviews = mockReviews.filter(r => r.lab_id === lab.lab_id);

  return res.json({
    success: true,
    data: {
      ...attachLabDetails(lab),
      reviews
    }
  });
};

exports.getLabPackages = (req, res) => {
  res.set('Cache-Control', 'no-store, no-cache, must-revalidate');
  const resolvedId = resolveLabId(req.params.id);
  const packages = mockServicePackages.filter(
    p => p.lab_id === resolvedId && p.status !== 'INACTIVE'
  );
  return res.json({
    success: true,
    data: packages
  });
};

