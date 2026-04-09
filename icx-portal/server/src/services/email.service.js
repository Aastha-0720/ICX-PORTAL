const nodemailer = require('nodemailer');

const EMAIL_FROM = process.env.EMAIL_FROM || 'support@iamsaif.ai';
const EMAIL_PROVIDER = (process.env.EMAIL_PROVIDER || 'smtp').toLowerCase();

// --- Transport setup ---

let transporter;

if (EMAIL_PROVIDER === 'resend') {
  // Resend uses SMTP under the hood — no separate SDK needed
  transporter = nodemailer.createTransport({
    host: 'smtp.resend.com',
    port: 465,
    secure: true,
    auth: {
      user: 'resend',
      pass: process.env.RESEND_API_KEY,
    },
  });
  console.log('[EMAIL] Using Resend SMTP transport');
} else {
  // Generic SMTP — works with Gmail, Outlook, Yahoo, AWS SES, etc.
  transporter = nodemailer.createTransport({
    host: process.env.SMTP_HOST,
    port: parseInt(process.env.SMTP_PORT) || 587,
    secure: process.env.SMTP_SECURE === 'true',
    auth: {
      user: process.env.SMTP_USER,
      pass: process.env.SMTP_PASS,
    },
  });
  console.log('[EMAIL] Using SMTP transport:', process.env.SMTP_HOST);
}

// Verify connection on startup
transporter.verify()
  .then(() => console.log('[EMAIL] Transport connection verified — ready to send'))
  .catch((err) => console.error('[EMAIL] Transport verification failed:', err.message));

// --- Core send function ---

const sendEmail = async (to, subject, html) => {
  try {
    const info = await transporter.sendMail({
      from: EMAIL_FROM,
      to,
      subject,
      html,
    });
    console.log('[EMAIL] Sent:', { to, subject, messageId: info.messageId });
    return info;
  } catch (err) {
    console.error('[EMAIL] Send failed:', { to, subject, error: err.message });
    throw new Error(`Email delivery failed: ${err.message}`);
  }
};

// --- Email templates ---

const sendOtpEmail = async (to, code) => {
  await sendEmail(to, 'ICX Portal — Your Verification Code', `
    <div style="font-family: Arial, sans-serif; max-width: 480px; margin: 0 auto; padding: 32px;">
      <h2 style="color: #1a1a2e;">ICX Portal</h2>
      <p>Your verification code is:</p>
      <div style="font-size: 32px; font-weight: bold; letter-spacing: 8px; text-align: center; padding: 24px; background: #f4f4f8; border-radius: 8px; margin: 24px 0;">
        ${code}
      </div>
      <p style="color: #666;">This code expires in 5 minutes. Do not share it with anyone.</p>
    </div>
  `);
};

const sendRegistrationConfirmation = async (to, role) => {
  await sendEmail(to, 'ICX Portal — Registration Received', `
    <div style="font-family: Arial, sans-serif; max-width: 480px; margin: 0 auto; padding: 32px;">
      <h2 style="color: #1a1a2e;">ICX Portal</h2>
      <p>Thank you for registering as a <strong>${role}</strong>.</p>
      <p>Your application is under review. You will receive an email once your account has been verified.</p>
    </div>
  `);
};

const sendKycApproved = async (to) => {
  await sendEmail(to, 'ICX Portal — Account Approved', `
    <div style="font-family: Arial, sans-serif; max-width: 480px; margin: 0 auto; padding: 32px;">
      <h2 style="color: #1a1a2e;">ICX Portal</h2>
      <p>Your account has been <strong>approved</strong>. You can now log in and start using the platform.</p>
      <a href="${process.env.CLIENT_URL}/login" style="display: inline-block; padding: 12px 24px; background: #1a1a2e; color: #fff; text-decoration: none; border-radius: 6px; margin-top: 16px;">Log In</a>
    </div>
  `);
};

const sendKycRejected = async (to, reason) => {
  await sendEmail(to, 'ICX Portal — Account Application Update', `
    <div style="font-family: Arial, sans-serif; max-width: 480px; margin: 0 auto; padding: 32px;">
      <h2 style="color: #1a1a2e;">ICX Portal</h2>
      <p>Unfortunately, your account application has been <strong>rejected</strong>.</p>
      ${reason ? `<p><strong>Reason:</strong> ${reason}</p>` : ''}
      <p>If you have questions, please contact our support team.</p>
    </div>
  `);
};

const sendRevisionRequested = async (to, flaggedFields) => {
  const fieldList = flaggedFields.map(f => `<li>${f}</li>`).join('');
  await sendEmail(to, 'ICX Portal — Revision Requested', `
    <div style="font-family: Arial, sans-serif; max-width: 480px; margin: 0 auto; padding: 32px;">
      <h2 style="color: #1a1a2e;">ICX Portal</h2>
      <p>Your submission requires revisions. Please update the following fields:</p>
      <ul>${fieldList}</ul>
      <a href="${process.env.CLIENT_URL}/login" style="display: inline-block; padding: 12px 24px; background: #1a1a2e; color: #fff; text-decoration: none; border-radius: 6px; margin-top: 16px;">Log In to Revise</a>
    </div>
  `);
};

module.exports = {
  sendOtpEmail,
  sendEmail,
  sendRegistrationConfirmation,
  sendKycApproved,
  sendKycRejected,
  sendRevisionRequested,
};
