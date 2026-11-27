/**
 * Tiện ích tự động bóc tách tên cuộn phim (Film Stock), quy trình tráng rửa
 * và gợi ý chuyên mục cho bài chia sẻ kinh nghiệm chụp ảnh phim.
 */
const KNOWN_FILM_STOCKS = [
  { key: 'portra 400', label: 'Kodak Portra 400', process: 'C-41' },
  { key: 'portra 160', label: 'Kodak Portra 160', process: 'C-41' },
  { key: 'kodak gold', label: 'Kodak Gold 200', process: 'C-41' },
  { key: 'colorplus', label: 'Kodak ColorPlus 200', process: 'C-41' },
  { key: 'ultramax', label: 'Kodak UltraMax 400', process: 'C-41' },
  { key: 'c200', label: 'Fujifilm C200', process: 'C-41' },
  { key: 'superia', label: 'Fujifilm Superia X-TRA 400', process: 'C-41' },
  { key: 'ilford hp5', label: 'Ilford HP5 Plus 400', process: 'B&W' },
  { key: 'kentmere', label: 'Kentmere Pan 400', process: 'B&W' },
  { key: 'cinestill 800t', label: 'CineStill 800T', process: 'C-41 / ECN-2' },
  { key: 'vision3', label: 'Kodak Vision3', process: 'ECN-2' },
];
function extractHashtags(text = '') {
  if (typeof text !== 'string') return [];
  const matches = text.match(/#([\p{L}\p{N}_-]{2,30})/gu) || [];
  const unique = new Set(matches.map((tag) => tag.slice(1).toLowerCase()));
  return Array.from(unique);
}
function detectFilmMetadata(text = '') {
  if (typeof text !== 'string' || !text.trim()) {
    return { filmStocks: [], processes: [], format: null };
  }
  const lower = text.toLowerCase();
  const matchedStocks = KNOWN_FILM_STOCKS.filter((item) => lower.includes(item.key));
  const filmStocks = matchedStocks.map((item) => item.label);
  const processes = Array.from(new Set(matchedStocks.map((item) => item.process)));
  let format = null;
  if (/\b(120|medium format|6x6|6x7|645)\b/i.test(text)) {
    format = '120 Medium Format';
  } else if (/\b(135|35mm)\b/i.test(text)) {
    format = '35mm (135)';
  }
  return { filmStocks, processes, format };
}
function suggestCommunityTopic(title = '', content = '') {
  const combined = `${title} ${content}`.toLowerCase();
  if (/(workshop|photowalk|offline|giao lưu|triển lãm)/.test(combined)) {
    return 'Sự kiện & Photowalk';
  }
  if (/(tráng|scan|c-41|ecn-2|hóa chất|buồng tối|push|pull)/.test(combined)) {
    return 'Kỹ thuật tráng & Scan';
  }
  if (/(đánh giá|review|ống kính|lens|máy ảnh|body|đo sáng)/.test(combined)) {
    return 'Đánh giá thiết bị & Phim';
  }
  return 'Chia sẻ góc ảnh & Kinh nghiệm';
}
module.exports = {
  extractHashtags,
  detectFilmMetadata,
  suggestCommunityTopic,
};
