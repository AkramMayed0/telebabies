const admin = require('../config/firebase');

/**
 * Send a push notification via FCM.
 *
 * @param {object} opts
 * @param {string|string[]} opts.token  - FCM registration token(s)
 * @param {string}          opts.title  - notification title
 * @param {string}          opts.body   - notification body
 * @param {object}          [opts.data] - optional string key-value payload
 * @returns {Promise<{successCount, failureCount, errors}>}
 */
async function sendNotification({ token, title, body, data = {} }) {
  const tokens = Array.isArray(token) ? token : [token];
  const valid   = tokens.filter(Boolean);

  if (!valid.length) return { successCount: 0, failureCount: 0, errors: [] };

  // stringify all data values — FCM requires string-only maps
  const stringData = Object.fromEntries(
    Object.entries(data).map(([k, v]) => [k, String(v)])
  );

  const notification = { title, body };

  if (valid.length === 1) {
    try {
      await admin.messaging().send({ token: valid[0], notification, data: stringData });
      return { successCount: 1, failureCount: 0, errors: [] };
    } catch (err) {
      return { successCount: 0, failureCount: 1, errors: [err.message] };
    }
  }

  // multicast for multiple tokens
  const result = await admin.messaging().sendEachForMulticast({
    tokens: valid,
    notification,
    data: stringData,
  });

  const errors = result.responses
    .map((r, i) => (!r.success ? `${valid[i]}: ${r.error?.message}` : null))
    .filter(Boolean);

  return {
    successCount: result.successCount,
    failureCount: result.failureCount,
    errors,
  };
}

module.exports = sendNotification;
