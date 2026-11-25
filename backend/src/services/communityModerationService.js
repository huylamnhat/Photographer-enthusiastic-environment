/**
 * Dịch vụ bổ trợ kiểm duyệt nội dung, tạo tóm tắt và đánh giá chất lượng
 * cho bài viết & bình luận thuộc phân hệ Cộng đồng nhiếp ảnh phim.
 */
const BLOCKED_KEYWORDS = [
  'lua dao',
  'cờ bạc',
  'co bac',
  'hack tai khoan',
  'link doc hai',
  'spam quang cao',
];
function normalizeText(rawText = '') {
  if (typeof rawText !== 'string') return '';
  return rawText
    .replace(/\r\n/g, '\n')
    .replace(/[ \t]+/g, ' ')
    .replace(/\n{3,}/g, '\n\n')
    .trim();
}
function checkContentSafety(content = '') {
  const normalized = normalizeText(content).toLowerCase();
  if (!normalized) {
    return { isValid: false, reason: 'Nội dung không được để trống', flaggedTerms: [] };
  }
  const flaggedTerms = BLOCKED_KEYWORDS.filter((term) => normalized.includes(term));
  const urlMatches = normalized.match(/https?:\/\/[^\s]+/g) || [];
  if (flaggedTerms.length > 0) {
    return {
      isValid: false,
      reason: 'Nội dung chứa từ khóa không phù hợp với tiêu chuẩn cộng đồng',
      flaggedTerms,
    };
  }
  if (urlMatches.length > 5) {
    return {
      isValid: false,
      reason: 'Bài viết chứa quá nhiều liên kết ngoài (nghi ngờ quảng cáo rác)',
      flaggedTerms: [],
    };
  }
  return { isValid: true, reason: null, flaggedTerms: [] };
}
function buildPostExcerpt(content = '', maxLength = 160) {
  const clean = normalizeText(content).replace(/\n+/g, ' ');
  if (clean.length <= maxLength) return clean;
  const sliced = clean.slice(0, maxLength);
  const lastSpace = sliced.lastIndexOf(' ');
  return `${sliced.slice(0, lastSpace > 80 ? lastSpace : maxLength).trim()}...`;
}
function estimateReadingMinutes(content = '', wordsPerMinute = 200) {
  const clean = normalizeText(content);
  if (!clean) return 1;
  const wordCount = clean.split(/\s+/).filter(Boolean).length;
  return Math.max(1, Math.ceil(wordCount / wordsPerMinute));
}
module.exports = {
  normalizeText,
  checkContentSafety,
  buildPostExcerpt,
  estimateReadingMinutes,
};
