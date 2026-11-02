const mockDb = require('../data/mockDb');

exports.getQCBatch = (req, res) => {
  const { orderId } = req.params;

  let batch = mockDb.qcBatches[orderId];
  if (!batch) {
    // Generate default batch for any queried order
    batch = {
      order_id: orderId,
      total_files: 36,
      uploaded_files: 36,
      passed_frames: 35,
      flagged_frames: 1,
      upload_status: 'COMPLETED',
      speed: '42.0 MB/s',
      scanner: 'Noritsu HS-1800',
      format: 'JPEG Hi-Res (450 MB)',
      md5_checksum: '0xA187FE9203C',
      frames: Array.from({ length: 36 }, (_, i) => ({
        frame_id: `FRAME-${(i + 1).toString().padStart(2, '0')}`,
        frame_number: i + 1,
        filename: `SCAN_${(i + 1).toString().padStart(2, '0')}.jpg`,
        thumb_url: `https://picsum.photos/seed/scan_${orderId}_${i}/300/200`,
        qc_status: i === 7 ? 'FLAGGED' : 'PASSED',
        defect_type: i === 7 ? 'Bụi thấu kính' : null,
        resolution: '3000 x 2000 px',
        color_space: 'sRGB Standard',
        operator_note: i === 7 ? 'Cần lau kính và scan lại frame 8' : 'Nét và chuẩn sáng'
      }))
    };
    mockDb.qcBatches[orderId] = batch;
  }

  return res.status(200).json({
    success: true,
    data: batch
  });
};

exports.toggleFrameQC = (req, res) => {
  const { orderId, frameId } = req.params;
  const { qc_status, defect_type, operator_note } = req.body;

  const batch = mockDb.qcBatches[orderId];
  if (!batch) {
    return res.status(404).json({ success: false, message: 'Không tìm thấy lô scan.' });
  }

  const frame = batch.frames.find(f => f.frame_id === frameId);
  if (!frame) {
    return res.status(404).json({ success: false, message: 'Không tìm thấy khung hình frame.' });
  }

  frame.qc_status = qc_status || (frame.qc_status === 'PASSED' ? 'FLAGGED' : 'PASSED');
  if (frame.qc_status === 'FLAGGED') {
    frame.defect_type = defect_type || 'Cần kiểm tra lại độ nét/bụi';
    frame.operator_note = operator_note || 'Gắn cờ kiểm định';
  } else {
    frame.defect_type = null;
    frame.operator_note = operator_note || 'Đã kiểm định đạt';
  }

  // Recalculate summary counts
  batch.passed_frames = batch.frames.filter(f => f.qc_status === 'PASSED').length;
  batch.flagged_frames = batch.frames.filter(f => f.qc_status === 'FLAGGED').length;

  return res.status(200).json({
    success: true,
    message: `Cập nhật trạng thái QC ${frameId} thành công`,
    data: {
      frame,
      summary: {
        passed_frames: batch.passed_frames,
        flagged_frames: batch.flagged_frames
      }
    }
  });
};

exports.approveAndRelease = (req, res) => {
  const { orderId } = req.params;
  const { note } = req.body;

  const order = mockDb.orders.find(o => o.order_id === orderId);
  if (order) {
    order.stage = 'COMPLETED';
    order.sla_hours_left = 0;
  }

  return res.status(200).json({
    success: true,
    message: `Kiểm định QC đơn ${orderId} thành công! Đã nạp ${mockDb.qcBatches[orderId]?.passed_frames || 72} file vào Digital Film Archive của khách hàng.`,
    data: {
      order_id: orderId,
      status: 'ARCHIVED',
      released_at: new Date().toISOString(),
      note: note || 'Phê duyệt xuất file scan chuẩn'
    }
  });
};

