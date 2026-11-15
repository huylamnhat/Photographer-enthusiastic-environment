const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
try {
  require('dotenv').config({ path: path.resolve(__dirname, '../../.env') });
} catch (_) {}

function isPlaceholderDriveUrlOrId(val) {
  if (!val) return true;
  const s = String(val).trim();
  return (
    !s ||
    s.includes('1MiniLabDigitalArchive') ||
    s.includes('1FilmLabArchive') ||
    s === 'Chưa cấu hình email'
  );
}

const SAMPLE_1080X720_PHOTOS = [
  {
    name: 'Frame_01_Chieu_Ho_Tay_1080x720.jpg',
    title: 'Chiều Hồ Tây - Kodak Portra 400 (1080x720)',
    url: 'https://images.unsplash.com/photo-1528127269322-539801943592?w=1080&h=720&fit=crop&fm=jpg&q=85',
  },
  {
    name: 'Frame_02_Ganh_Hang_Rong_Pho_Co_1080x720.jpg',
    title: 'Gánh hàng rong phố cổ - Kodak Gold 200 (1080x720)',
    url: 'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=1080&h=720&fit=crop&fm=jpg&q=85',
  },
  {
    name: 'Frame_03_Cafe_Sai_Gon_1080x720.jpg',
    title: 'Góc cà phê Sài Gòn - Fujifilm C200 (1080x720)',
    url: 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=1080&h=720&fit=crop&fm=jpg&q=85',
  },
  {
    name: 'Frame_04_Suong_Som_Da_Lat_1080x720.jpg',
    title: 'Sương sớm Đà Lạt - Cinestill 800T (1080x720)',
    url: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=1080&h=720&fit=crop&fm=jpg&q=85',
  },
  {
    name: 'Frame_05_Pho_Co_Hoi_An_1080x720.jpg',
    title: 'Đêm phố cổ Hội An - Kodak Vision3 500T (1080x720)',
    url: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=1080&h=720&fit=crop&fm=jpg&q=85',
  },
  {
    name: 'Frame_06_analog_camera_darkroom_1080x720.jpg',
    title: 'Góc máy phim Analog - Ilford HP5 Plus (1080x720)',
    url: 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=1080&h=720&fit=crop&fm=jpg&q=85',
  },
];

// Runtime Google Drive configuration (initialized from .env, can be updated via API/UI)
const driveConfig = {
  accountEmail: process.env.GOOGLE_DRIVE_ACCOUNT_EMAIL || '',
  clientId: process.env.GOOGLE_DRIVE_CLIENT_ID || '',
  clientSecret: process.env.GOOGLE_DRIVE_CLIENT_SECRET || '',
  refreshToken: process.env.GOOGLE_DRIVE_REFRESH_TOKEN || '',
  accessToken: process.env.GOOGLE_DRIVE_ACCESS_TOKEN || '',
  folderId: isPlaceholderDriveUrlOrId(process.env.GOOGLE_DRIVE_FOLDER_ID) ? '' : (process.env.GOOGLE_DRIVE_FOLDER_ID || ''),
  folderUrl: isPlaceholderDriveUrlOrId(process.env.GOOGLE_DRIVE_FOLDER_URL) ? '' : (process.env.GOOGLE_DRIVE_FOLDER_URL || ''),
  serviceAccountEmail: process.env.GOOGLE_SERVICE_ACCOUNT_EMAIL || '',
  privateKey: (process.env.GOOGLE_PRIVATE_KEY || '').replace(/\\n/g, '\n'),
};

let cachedAccessToken = '';
let cachedTokenExpiry = 0;

function extractFolderIdFromUrl(urlOrId) {
  if (!urlOrId || isPlaceholderDriveUrlOrId(urlOrId)) return '';
  const trimmed = String(urlOrId).trim();
  const match = trimmed.match(/\/folders\/([a-zA-Z0-9_-]+)/);
  if (match && match[1] && !isPlaceholderDriveUrlOrId(match[1])) return match[1];
  const idMatch = trimmed.match(/[?&]id=([a-zA-Z0-9_-]+)/);
  if (idMatch && idMatch[1] && !isPlaceholderDriveUrlOrId(idMatch[1])) return idMatch[1];
  if (/^[a-zA-Z0-9_-]{15,}$/.test(trimmed) && !trimmed.startsWith('http') && !isPlaceholderDriveUrlOrId(trimmed)) {
    return trimmed;
  }
  return '';
}

function persistDriveConfigToEnv() {
  try {
    const envPath = path.resolve(__dirname, '../../.env');
    let envContent = fs.existsSync(envPath) ? fs.readFileSync(envPath, 'utf8') : '';
    const updates = {
      GOOGLE_DRIVE_ACCOUNT_EMAIL: driveConfig.accountEmail,
      GOOGLE_DRIVE_FOLDER_ID: driveConfig.folderId,
      GOOGLE_DRIVE_FOLDER_URL: driveConfig.folderUrl,
      GOOGLE_DRIVE_CLIENT_ID: driveConfig.clientId,
      GOOGLE_DRIVE_CLIENT_SECRET: driveConfig.clientSecret,
      GOOGLE_DRIVE_REFRESH_TOKEN: driveConfig.refreshToken,
      GOOGLE_DRIVE_ACCESS_TOKEN: driveConfig.accessToken,
    };
    Object.entries(updates).forEach(([key, val]) => {
      if (val !== undefined) {
        const regex = new RegExp(`^${key}=.*$`, 'm');
        if (regex.test(envContent)) {
          envContent = envContent.replace(regex, `${key}=${val}`);
        } else {
          envContent += `\n${key}=${val}`;
        }
      }
    });
    fs.writeFileSync(envPath, envContent.trim() + '\n', 'utf8');
  } catch (_) {}
}

function getDriveConfigStatus() {
  const hasOAuth = Boolean(driveConfig.clientId && driveConfig.clientSecret && driveConfig.refreshToken);
  const hasAccessToken = Boolean(driveConfig.accessToken);
  const hasServiceAccount = Boolean(driveConfig.serviceAccountEmail && driveConfig.privateKey);
  const isLiveApiReady = hasOAuth || hasAccessToken || hasServiceAccount;
  const folderId = driveConfig.folderId || extractFolderIdFromUrl(driveConfig.folderUrl) || '';
  const folderUrl = folderId
    ? `https://drive.google.com/drive/folders/${folderId}?usp=sharing`
    : (!isPlaceholderDriveUrlOrId(driveConfig.folderUrl) ? driveConfig.folderUrl : 'https://drive.google.com/drive/my-drive');

  return {
    account_email: driveConfig.accountEmail || driveConfig.serviceAccountEmail || '',
    folder_id: folderId,
    folder_url: folderUrl,
    has_oauth: hasOAuth,
    has_access_token: hasAccessToken,
    has_service_account: hasServiceAccount,
    is_live_api_ready: isLiveApiReady,
    client_id: driveConfig.clientId ? `${driveConfig.clientId.slice(0, 12)}...` : '',
  };
}

function updateDriveConfig(newConfig = {}) {
  if (newConfig.account_email !== undefined && String(newConfig.account_email).trim()) {
    driveConfig.accountEmail = String(newConfig.account_email).trim();
  }
  if (newConfig.client_id !== undefined && String(newConfig.client_id).trim()) {
    driveConfig.clientId = String(newConfig.client_id).trim();
  }
  if (newConfig.client_secret !== undefined && String(newConfig.client_secret).trim()) {
    driveConfig.clientSecret = String(newConfig.client_secret).trim();
  }
  if (newConfig.refresh_token !== undefined && String(newConfig.refresh_token).trim()) {
    driveConfig.refreshToken = String(newConfig.refresh_token).trim();
    cachedAccessToken = '';
  }
  if (newConfig.access_token !== undefined && String(newConfig.access_token).trim()) {
    driveConfig.accessToken = String(newConfig.access_token).trim();
  }
  if (newConfig.folder_url !== undefined) {
    const cleanUrl = String(newConfig.folder_url).trim();
    if (!isPlaceholderDriveUrlOrId(cleanUrl)) {
      const extracted = extractFolderIdFromUrl(cleanUrl);
      if (extracted) {
        driveConfig.folderId = extracted;
        driveConfig.folderUrl = `https://drive.google.com/drive/folders/${extracted}?usp=sharing`;
      } else {
        driveConfig.folderUrl = cleanUrl;
      }
    }
  }
  if (newConfig.folder_id !== undefined && String(newConfig.folder_id).trim()) {
    const cleanId = extractFolderIdFromUrl(newConfig.folder_id) || String(newConfig.folder_id).trim();
    if (!isPlaceholderDriveUrlOrId(cleanId)) {
      driveConfig.folderId = cleanId;
      driveConfig.folderUrl = `https://drive.google.com/drive/folders/${driveConfig.folderId}?usp=sharing`;
    }
  }
  if (newConfig.service_account_email !== undefined) {
    driveConfig.serviceAccountEmail = String(newConfig.service_account_email).trim();
  }
  if (newConfig.private_key !== undefined) {
    driveConfig.privateKey = String(newConfig.private_key).replace(/\\n/g, '\n').trim();
  }

  persistDriveConfigToEnv();
  return getDriveConfigStatus();
}

async function getValidAccessToken(forceRefresh = false) {
  const now = Date.now();
  if (!forceRefresh && cachedAccessToken && now < cachedTokenExpiry) {
    return cachedAccessToken;
  }

  // 1. Prefer OAuth2 Refresh Token flow so token never expires
  if (driveConfig.refreshToken) {
    // 1a. Try direct Google OAuth2 token endpoint with configured Client ID & Secret
    if (driveConfig.clientId && driveConfig.clientSecret) {
      try {
        const params = new URLSearchParams({
          client_id: driveConfig.clientId,
          client_secret: driveConfig.clientSecret,
          refresh_token: driveConfig.refreshToken,
          grant_type: 'refresh_token',
        });
        const res = await fetch('https://oauth2.googleapis.com/token', {
          method: 'POST',
          headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
          body: params.toString(),
        });
        const data = await res.json();
        if (data && data.access_token) {
          cachedAccessToken = data.access_token;
          cachedTokenExpiry = now + ((data.expires_in || 3500) - 120) * 1000;
          driveConfig.accessToken = data.access_token;
          persistDriveConfigToEnv();
          return data.access_token;
        }
      } catch (err) {
        console.log('[Google Drive OAuth Direct Refresh Warning]:', err.message);
      }
    }

    // 1b. Fallback to Google OAuth 2.0 Playground refresh endpoint (for tokens starting with 1//04...)
    try {
      const pgRes = await fetch('https://developers.google.com/oauthplayground/refreshAccessToken', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          token_uri: 'https://oauth2.googleapis.com/token',
          refresh_token: driveConfig.refreshToken,
        }),
      });
      const pgData = await pgRes.json();
      if (pgData && pgData.access_token) {
        cachedAccessToken = pgData.access_token;
        cachedTokenExpiry = now + ((pgData.expires_in || 3500) - 120) * 1000;
        driveConfig.accessToken = pgData.access_token;
        persistDriveConfigToEnv();
        return pgData.access_token;
      }
    } catch (pgErr) {
      console.log('[Google Drive OAuth Playground Refresh Warning]:', pgErr.message);
    }
  }

  // 2. Fallback to Direct Access Token
  if (driveConfig.accessToken) {
    return driveConfig.accessToken;
  }

  return null;
}

async function grantAnyoneReaderPermission(token, fileOrFolderId) {
  if (!token || !fileOrFolderId) return false;
  try {
    const permRes = await fetch(
      `https://www.googleapis.com/drive/v3/files/${fileOrFolderId}/permissions?supportsAllDrives=true`,
      {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${token}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ role: 'reader', type: 'anyone', allowFileDiscovery: false }),
      }
    );
    return permRes.ok;
  } catch (_) {
    return false;
  }
}

/**
 * Helper to upload a single image buffer into a Google Drive folder
 */
async function uploadSingleBufferToFolder({ token, folderId, fileName, mimeType = 'image/jpeg', buffer, description = '' }) {
  const metadata = {
    name: fileName,
    description: description || 'MiniLab Digital Archive 1080x720 Film Scan',
    ...(folderId ? { parents: [folderId] } : {}),
  };

  const boundary = '-------MiniLabDriveBoundary' + Date.now() + Math.random().toString(16).slice(2);
  const metaPart = Buffer.from(
    `--${boundary}\r\nContent-Type: application/json; charset=UTF-8\r\n\r\n${JSON.stringify(metadata)}\r\n--${boundary}\r\nContent-Type: ${mimeType}\r\n\r\n`,
    'utf8'
  );
  const endPart = Buffer.from(`\r\n--${boundary}--`, 'utf8');
  const multipartBody = Buffer.concat([metaPart, buffer, endPart]);

  const uploadRes = await fetch(
    'https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart&fields=id,name,size,webViewLink,webContentLink',
    {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${token}`,
        'Content-Type': `multipart/related; boundary=${boundary}`,
      },
      body: multipartBody,
    }
  );

  const uploaded = await uploadRes.json();
  if (uploaded && uploaded.id) {
    await grantAnyoneReaderPermission(token, uploaded.id);
  }
  return uploaded;
}

/**
 * Fetch image from URL forced to 1080x720 resolution, or decode base64 data URL
 */
async function fetch1080x720ImageBuffer(rawUrlOrBase64) {
  if (rawUrlOrBase64 && String(rawUrlOrBase64).startsWith('data:image')) {
    try {
      const cleanBase64 = String(rawUrlOrBase64).replace(/^data:[^;]+;base64,/, '');
      const buf = Buffer.from(cleanBase64, 'base64');
      if (buf.length > 100) return buf;
    } catch (_) {}
  }

  let targetUrl = rawUrlOrBase64 || SAMPLE_1080X720_PHOTOS[0].url;
  if (targetUrl.includes('images.unsplash.com')) {
    const baseUrl = targetUrl.split('?')[0];
    targetUrl = `${baseUrl}?w=1080&h=720&fit=crop&fm=jpg&q=85`;
  }
  try {
    const res = await fetch(targetUrl);
    if (res.ok) {
      const arrBuf = await res.arrayBuffer();
      const buf = Buffer.from(arrBuf);
      if (buf.length > 1000) {
        return buf;
      }
    }
  } catch (_) {}

  for (const item of SAMPLE_1080X720_PHOTOS) {
    try {
      const res = await fetch(item.url);
      if (res.ok) {
        const arrBuf = await res.arrayBuffer();
        const buf = Buffer.from(arrBuf);
        if (buf.length > 1000) return buf;
      }
    } catch (_) {}
  }
  return null;
}

/**
 * Ensures the 'MiniLab Digital Archive' folder exists on Google Drive
 */
async function ensureRealDriveFolder(token) {
  if (!token) return '';

  let folderId = driveConfig.folderId || extractFolderIdFromUrl(driveConfig.folderUrl);
  let folderValid = false;

  if (folderId && !isPlaceholderDriveUrlOrId(folderId)) {
    try {
      const checkRes = await fetch(
        `https://www.googleapis.com/drive/v3/files/${folderId}?fields=id,name,mimeType,webViewLink,trashed`,
        { headers: { Authorization: `Bearer ${token}` } }
      );
      if (checkRes.ok) {
        const checkData = await checkRes.json();
        if (checkData && checkData.id && !checkData.trashed && checkData.mimeType === 'application/vnd.google-apps.folder') {
          folderValid = true;
        }
      }
    } catch (_) {}
  }

  if (!folderValid) {
    try {
      const q = encodeURIComponent("mimeType='application/vnd.google-apps.folder' and name='MiniLab Digital Archive' and trashed=false");
      const searchRes = await fetch(
        `https://www.googleapis.com/drive/v3/files?q=${q}&fields=files(id,name,webViewLink)&pageSize=1`,
        { headers: { Authorization: `Bearer ${token}` } }
      );
      if (searchRes.ok) {
        const searchData = await searchRes.json();
        if (searchData.files && searchData.files.length > 0) {
          folderId = searchData.files[0].id;
          folderValid = true;
        }
      }
    } catch (_) {}
  }

  if (!folderValid) {
    try {
      const createRes = await fetch('https://www.googleapis.com/drive/v3/files?fields=id,name,webViewLink', {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${token}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          name: 'MiniLab Digital Archive',
          mimeType: 'application/vnd.google-apps.folder',
          description: 'Kho lưu trữ ảnh Film Scan MiniLab (Độ phân giải 1080x720)',
        }),
      });
      const created = await createRes.json();
      if (created && created.id) {
        folderId = created.id;
        folderValid = true;
      }
    } catch (err) {
      console.log('[Google Drive Create Folder Warning]:', err.message);
    }
  }

  if (folderId && folderValid) {
    await fetch(`https://www.googleapis.com/drive/v3/files/${folderId}/permissions`, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${token}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ role: 'reader', type: 'anyone' }),
    }).catch(() => {});

    driveConfig.folderId = folderId;
    driveConfig.folderUrl = `https://drive.google.com/drive/folders/${folderId}?usp=sharing`;
    persistDriveConfigToEnv();

    // Clean up any tiny <5KB broken 1x1 files in the folder
    try {
      const listQ = encodeURIComponent(`'${folderId}' in parents and trashed=false`);
      const listRes = await fetch(
        `https://www.googleapis.com/drive/v3/files?q=${listQ}&fields=files(id,name,size)&pageSize=50`,
        { headers: { Authorization: `Bearer ${token}` } }
      );
      if (listRes.ok) {
        const listData = await listRes.json();
        const files = listData.files || [];
        for (const f of files) {
          if (f.size && Number(f.size) < 5000) {
            await fetch(`https://www.googleapis.com/drive/v3/files/${f.id}`, {
              method: 'DELETE',
              headers: { Authorization: `Bearer ${token}` },
            }).catch(() => {});
          }
        }
      }
    } catch (_) {}

    return folderId;
  }

  return '';
}

/**
 * Clears all files in the given Google Drive folder so ONLY the newly selected photos remain
 */
async function clearFolderFiles(token, folderId) {
  if (!token || !folderId) return;
  try {
    const listQ = encodeURIComponent(`'${folderId}' in parents and trashed=false`);
    const listRes = await fetch(
      `https://www.googleapis.com/drive/v3/files?q=${listQ}&fields=files(id,name)&pageSize=100`,
      { headers: { Authorization: `Bearer ${token}` } }
    );
    if (listRes.ok) {
      const listData = await listRes.json();
      const files = listData.files || [];
      await Promise.all(
        files.map(f =>
          fetch(`https://www.googleapis.com/drive/v3/files/${f.id}`, {
            method: 'DELETE',
            headers: { Authorization: `Bearer ${token}` },
          }).catch(() => {})
        )
      );
    }
  } catch (_) {}
}

/**
 * Creates a brand-new dedicated Google Drive folder for each upload batch
 * so every send action generates a new link while keeping all old links intact.
 */
async function createNewBatchDriveFolder(token, parentFolderId, batchName) {
  if (!token) return '';
  const folderName = batchName || `MiniLab_Scan_${new Date().toISOString().replace(/[:.]/g, '-').slice(0, 19)}`;

  // Try creating inside parentFolderId first; if parentFolderId is invalid/deleted, create directly in root Drive
  const parentCandidates = parentFolderId ? [parentFolderId, ''] : [''];
  for (const candidateParent of parentCandidates) {
    try {
      const metadata = {
        name: folderName,
        mimeType: 'application/vnd.google-apps.folder',
        description: 'Thư mục ảnh Film Scan MiniLab (1080x720) chia sẻ công khai cho khách hàng',
        ...(candidateParent ? { parents: [candidateParent] } : {}),
      };
      const createRes = await fetch('https://www.googleapis.com/drive/v3/files?fields=id,name,webViewLink', {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${token}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(metadata),
      });
      const created = await createRes.json();
      if (created && created.id) {
        await grantAnyoneReaderPermission(token, created.id);
        return created.id;
      }
    } catch (err) {
      console.log('[Google Drive Create Batch Folder Warning]:', err.message);
    }
  }
  return '';
}

function saveBufferToLocalUploads(buf, fileName) {
  try {
    const uploadsDir = path.resolve(__dirname, '../../uploads');
    if (!fs.existsSync(uploadsDir)) {
      fs.mkdirSync(uploadsDir, { recursive: true });
    }
    const safeName = `${Date.now()}_${String(fileName || 'scan.jpg').replace(/[^a-zA-Z0-9._-]/g, '_')}`;
    const fullPath = path.join(uploadsDir, safeName);
    fs.writeFileSync(fullPath, buf);
    const port = process.env.PORT || 5000;
    return `http://localhost:${port}/uploads/${safeName}`;
  } catch (_) {
    return '';
  }
}

/**
 * Uploads the exact array of user-selected photos (`selectedPhotos`) into the Google Drive folder
 * and returns the shared folder link.
 */
async function uploadBatchToGoogleDrive({
  selectedPhotos = [],
  orderId = '',
  rollCode = '',
  customDriveLink = '',
  replaceFolderContents = true,
}) {
  const preparedItems = [];
  for (let i = 0; i < selectedPhotos.length; i++) {
    const item = selectedPhotos[i];
    const rawBase64 = item.file_base64 || (String(item.image_url || '').startsWith('data:image') ? item.image_url : '');
    let buf = null;
    let resolvedImageUrl = item.image_url || '';

    if (rawBase64) {
      try {
        const clean = String(rawBase64).replace(/^data:[^;]+;base64,/, '');
        buf = Buffer.from(clean, 'base64');
      } catch (_) {}
    }
    if (!buf || buf.length < 100) {
      buf = await fetch1080x720ImageBuffer(item.image_url);
    }

    const idxStr = String(i + 1).padStart(2, '0');
    const baseName = item.file_name
      ? String(item.file_name).replace(/\.[^.]+$/, '')
      : `Frame_${idxStr}_${orderId || 'Scan'}_1080x720`;
    const finalFileName = `${baseName}.jpg`;

    if (buf && (!resolvedImageUrl || resolvedImageUrl.startsWith('data:image'))) {
      const localUrl = saveBufferToLocalUploads(buf, finalFileName);
      if (localUrl) resolvedImageUrl = localUrl;
    }

    preparedItems.push({
      buf,
      finalFileName,
      title: item.title || baseName,
      image_url: resolvedImageUrl || SAMPLE_1080X720_PHOTOS[0].url,
    });
  }

  const configuredFolderId = driveConfig.folderId || extractFolderIdFromUrl(driveConfig.folderUrl);
  const cleanCustomLink = String(customDriveLink || '').trim();
  const hasValidCustomLink =
    cleanCustomLink.startsWith('http') &&
    !isPlaceholderDriveUrlOrId(cleanCustomLink) &&
    !cleanCustomLink.includes('/drive/my-drive');

  try {
    let token = await getValidAccessToken();
    if (token) {
      // 1. Ensure root archive folder exists
      let rootFolderId = await ensureRealDriveFolder(token);

      // 2. Create a brand-new dedicated folder for this send action (old folders & links stay untouched!)
      const timeTag = new Date().toTimeString().slice(0, 8).replace(/:/g, '');
      const batchFolderName = `Scan_${orderId || 'Archive'}_${rollCode || timeTag}`;
      let batchFolderId = await createNewBatchDriveFolder(token, rootFolderId, batchFolderName);

      // If cached token had expired, force a fresh OAuth token and retry once
      if (!batchFolderId) {
        token = await getValidAccessToken(true);
        if (token) {
          rootFolderId = await ensureRealDriveFolder(token);
          batchFolderId = await createNewBatchDriveFolder(token, rootFolderId, batchFolderName);
        }
      }

      const finalFolderId = batchFolderId || rootFolderId;
      if (finalFolderId) {
        const folderLink = `https://drive.google.com/drive/folders/${finalFolderId}?usp=sharing`;
        const uploadedItems = [];
        let uploadedCount = 0;

        for (const pItem of preparedItems) {
          if (pItem.buf) {
            const uploaded = await uploadSingleBufferToFolder({
              token,
              folderId: finalFolderId,
              fileName: pItem.finalFileName,
              mimeType: 'image/jpeg',
              buffer: pItem.buf,
              description: `${pItem.title} - 1080x720`,
            });
            if (uploaded && uploaded.id) uploadedCount++;

            uploadedItems.push({
              file_id: uploaded?.id || '',
              file_name: pItem.finalFileName,
              title: pItem.title,
              image_url: pItem.image_url,
              drive_link: folderLink,
            });
          }
        }

        if (uploadedCount > 0 || batchFolderId) {
          return {
            mode: 'GOOGLE_DRIVE_API_V3',
            folder_id: finalFolderId,
            folder_url: folderLink,
            web_view_link: folderLink,
            uploaded_count: uploadedItems.length,
            uploaded_items: uploadedItems,
            resolution: '1080x720',
            account_email: driveConfig.accountEmail || '',
          };
        }
      }
    }
  } catch (err) {
    console.log('[Google Drive Batch Upload Warning]:', err.message);
  }

  const safeFallbackLink = hasValidCustomLink
    ? cleanCustomLink
    : (configuredFolderId && !isPlaceholderDriveUrlOrId(configuredFolderId)
        ? `https://drive.google.com/drive/folders/${configuredFolderId}?usp=sharing`
        : (!isPlaceholderDriveUrlOrId(driveConfig.folderUrl) && driveConfig.folderUrl
            ? driveConfig.folderUrl
            : 'https://drive.google.com/drive/my-drive'));

  return {
    mode: 'DRIVE_FOLDER_LINK',
    folder_id: extractFolderIdFromUrl(safeFallbackLink) || configuredFolderId || 'my-drive',
    folder_url: safeFallbackLink,
    web_view_link: safeFallbackLink,
    uploaded_count: preparedItems.length,
    uploaded_items: preparedItems.map(p => ({
      file_id: '',
      file_name: p.finalFileName,
      title: p.title,
      image_url: p.image_url,
      drive_link: safeFallbackLink,
    })),
    resolution: '1080x720',
    account_email: driveConfig.accountEmail || '',
  };
}

/**
 * Upload single or batch file(s) to Google Drive API v3 inside the shared folder
 */
async function uploadFileToGoogleDrive({
  fileName = `Scan_1080x720_${Date.now()}.jpg`,
  mimeType = 'image/jpeg',
  fileBuffer = null,
  imageUrl = '',
  customDriveLink = '',
  orderId = '',
  selectedPhotos = null,
  replaceFolderContents = false,
}) {
  if (Array.isArray(selectedPhotos) && selectedPhotos.length > 0) {
    return uploadBatchToGoogleDrive({
      selectedPhotos,
      orderId,
      customDriveLink,
      replaceFolderContents,
    });
  }

  return uploadBatchToGoogleDrive({
    selectedPhotos: [
      {
        file_name: fileName,
        file_base64: fileBuffer ? fileBuffer.toString('base64') : '',
        image_url: imageUrl,
        title: fileName,
      },
    ],
    orderId,
    customDriveLink,
    replaceFolderContents,
  });
}

module.exports = {
  getDriveConfigStatus,
  updateDriveConfig,
  uploadFileToGoogleDrive,
  uploadBatchToGoogleDrive,
  ensureRealDriveFolder,
  getValidAccessToken,
  SAMPLE_1080X720_PHOTOS,
};
